# Filename:    CreateSPTrustedTokenIssuer.ps1
# Disclaimer:  
# Copyright (c) Okta.  All rights reserved.

<#

.SYNOPSIS
This is a Powershell script to create Sharepoint trusted token issuer.

.DESCRIPTION
This script configures the SharePoint STS to trust the Okta issuer, and map the incoming claims from Okta to claims that your SharePoint applications will use.
More details:
    - Creates a new SharePoint trusted root authority. Okta signs the tokens that it issues with a token signing certificate. 
    - Imports into SharePoint an Okta Identity Provider certificate that SharePoint can use to validate the token from Okta.
    - To map the incoming claims from Okta to claims that SharePoint uses, creates some mapping rules.
    - Creates a SPTrustedIdentityTokenIssuer that can be used with your SharePoint web application.
 
.PARAMETER identifierClaimType 
Claim type to be used as the Identifier claim in SharePoint. It should be either "Email" or "UserName".

.PARAMETER certPath
Path to downloaded Okta's certificate. 

.PARAMETER realm
SharePoint Trusted Identity Provider Realm in Okta.

.PARAMETER signInURL
Url that users should be redirected to in order to authenticate with Okta.

.PARAMETER encodingCharacterCode 
Character code (Int32) used for encoding if IdentifierClaimType is specified as "UserName". 
Leave this unspecified so that default encoding of 527 is used. In case you leave it unspecified, make sure 527 is not used in another encoding.
If specified, however, then make sure that your chosen character is not used in another encoding, and it is above 500 (0x01F5) and not an uppercase or whitespace character.
Note: Not all characters above 500 works. Here are few examples for you to use: 509, 517, 519 and 525.
You can find more details on the blog here: http://www.wictorwilen.se/introducing-the-sharepoint-2010-get-spclaimtypeencoding-and-new-spclaimtypeencoding-cmdlets

.PARAMETER skipCreatingTrustedRootAuthority
Whether you want to skip creating trusted root authority if it already exists.

.EXAMPLE 

.\CreateSPTrustedTokenIssuer.ps1 -identifierClaimType "UserName" -certPath "C:\Okta.cert" -realm "urn:okta:sharepoint:exk5rz1t5f50J447m0h7" -signInURL "https://sp.okta.com/app/sharepoint_onpremise/sso/wsfed/passive" -skipCreatingTrustedRootAuthority

Assurant specific parameters
.\CreateSPTrustedTokenIssuer.ps1 -identifierClaimType "UserName" -certPath "\\\okta.cert" -realm "urn:okta:sharepoint:exkdojqhp1GZxLA520h7" -signInURL "https://poc-st-assurant.oktapreview.com/app/sharepoint_onpremise/sso/wsfed/passive" -skipCreatingTrustedRootAuthority




#>

[CmdletBinding()]
param (
  [Parameter(Mandatory=$true)]
  [string]$identifierClaimType,

  [Parameter(Mandatory=$true)]
  [string]$certPath,
  
  [Parameter(Mandatory=$true)]
  [string]$realm,

  [Parameter(Mandatory=$true)]
  [string]$signInURL,
  
  [Parameter(Mandatory=$false)]
  [int]$encodingCharacterCode = 527,
    
  [Parameter(Mandatory=$false)]
  [switch]$skipCreatingTrustedRootAuthority = $false
)

function handle_error($exception) {
  Write-Host "Error: failed to create the trusted token issuer, Exception: $exception" -ForegroundColor Red
  exit
}

function validate_trusted_provider
{
    try {
        $ap = Get-SPTrustedIdentityTokenIssuer -Identity "Okta"
        if ($ap -ne $null) 
        {
            Write-Host "There is already a trusted provider 'Okta' in use. Please remove the existing trusted provider and then try running the script again." -ForegroundColor Red
            exit
        }
    }
    catch [System.Exception] {
        if ($_.Exception.Message -ne "A valid object could not be read from the provided pipebind parameter."){
            handle_error $_.Exception.ToString()
        }
    }
}

$ErrorActionPreference = "Stop"
$snapin = "Microsoft.SharePoint.PowerShell"

$upnClaim = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn"
$roleClaim = "http://schemas.microsoft.com/ws/2008/06/identity/claims/role"
$emailClaim = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
$usernameClaim = "http://schemas.okta.com/claims/username"

$upn = "UPN"
$role = "Role"
$emailAddress = "EmailAddress"
$userName = "UserName"

$identifierEmail = "Email"
$identifierUsername = "UserName"

$certName = "Token Signing Cert"
$trustName = "Okta"
$trustDescription = "Okta Trusted Identity Provider"

if ($identifierClaimType -ne $identifierEmail -and $identifierClaimType -ne $identifierUsername)
{
    Write-Host "An Identifier type other than '$identifierEmail' or '$identifierUsername' was specified. These are the only supported values." -ForegroundColor Red
    exit
}

if (Get-PSSnapin $snapin -ea "silentlycontinue") {
    Write-Host "PSsnapin $snapin is already loaded..." -ForegroundColor Green
}
elseif (Get-PSSnapin $snapin -registered -ea "silentlycontinue") {
    Write-Host "PSsnapin $snapin is registered but not loaded, loading..." -ForegroundColor Green
    Add-PSSnapin $snapin
}
else {
    Write-Host "PSSnapin $snapin not found, please make sure the script is run on a SharePoint server with the SharePoint PowerShell snapin installed." -ForegroundColor Red
    exit
}

try {
    Write-Host "Trying to import the Okta token signing certificate..." -ForegroundColor Green
    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certPath)
}
catch [System.Exception] {
    Write-Host "Error importing the certificate from the specified path to downloaded Okta certificate. Make sure the path specified is correct and the certificate is valid." -ForegroundColor Red
    exit
}

if ($skipCreatingTrustedRootAuthority -eq $False)
{
    try {
        Write-Host "Creating trusted root authority with the Okta token signing certificate..." -ForegroundColor Green
        New-SPTrustedRootAuthority -Name $certName -Certificate $cert
    }
    catch [System.Exception] {
        Write-Host "If a trusted root authority named '$certName' already exists under the parent trusted root authority manager, delete the existing object." -ForegroundColor Red
        exit
    }
}
else
{
    Write-Warning "Skipping creating trusted root authority with the Okta token signing certificate..."
}

if ($identifierClaimType -eq $identifierEmail)
{
    validate_trusted_provider

    try {
        Write-Host "Trying to create trusted Identity token issuer with '$identifierEmail' as the Identifier claim type..." -ForegroundColor Green

        $upnClaimMap = New-SPClaimTypeMapping -IncomingClaimType  $upnClaim -IncomingClaimTypeDisplayName $upn -SameAsIncoming
        $roleClaimMap = New-SPClaimTypeMapping -IncomingClaimType  $roleClaim -IncomingClaimTypeDisplayName $role -SameAsIncoming 
        $emailClaimMap = New-SPClaimTypeMapping -IncomingClaimType $emailClaim -IncomingClaimTypeDisplayName $emailAddress -SameAsIncoming

        New-SPTrustedIdentityTokenIssuer -Name $trustName -Description $trustDescription -realm $realm -ImportTrustCertificate $cert -ClaimsMappings $upnClaimMap, $roleClaimMap, $emailClaimMap -SignInUrl $signInURL -IdentifierClaim $emailClaimMap.InputClaimType
    }
    catch [System.Exception] {
        handle_error $_.Exception.ToString()
    }
}

if ($identifierClaimType -eq $identifierUsername)
{  
    validate_trusted_provider
	
    try {
        Write-Host "Trying to create trusted Identity token issuer with '$identifierUsername' as the Identifier claim type..." -ForegroundColor Green  
        try {
            $usernameEncoding = Get-SPClaimTypeEncoding -ClaimType $usernameClaim
        }
        catch [System.Exception] {
            # indicates currently there is no encoding for username claim.
            # Check if specified encoding character has any other claim associated with it.
            try {
                $usernameEncoding = Get-SPClaimTypeEncoding -EncodingCharacter $encodingCharacterCode
            }
            catch [System.Exception] {
                # means currently there is no encoding with this character code. We are good to go.
                Write-Host "Trying to create claim type encoding for 'UserName' claim with encoding character code '$encodingCharacterCode' ..." -ForegroundColor Green
                New-SPClaimTypeEncoding -EncodingCharacter ([Convert]::ToChar($encodingCharacterCode)) -ClaimType $usernameClaim -Force
            }
            
            if ($usernameEncoding -ne $null -and $usernameEncoding.EncodingCharacter -eq $encodingCharacterCode -and $usernameEncoding.ClaimType -ne $usernameClaim)
            {
                $claimType = $usernameEncoding.ClaimType
                Write-Host "Encoding character code specified is already used for a different claim '$claimType' , please specify another encoding character." -ForegroundColor Red
                exit
            }
        }

        if ($usernameEncoding -ne $null -and $usernameEncoding.EncodingCharacter -ne $encodingCharacterCode -and $usernameEncoding.ClaimType -eq $usernameClaim)
        {
            $charCode = [Convert]::ToInt32($usernameEncoding.EncodingCharacter) 
            Write-Warning "There is a different encoding for the UserName claim already - '$charCode', skipping creating a new encoding for the claim type 'UserName'."
        }
        elseif ($usernameEncoding -ne $null -and $usernameEncoding.EncodingCharacter -eq $encodingCharacterCode -and $usernameEncoding.ClaimType -eq $usernameClaim)
        {
            Write-Warning "The specified encoding character code '$encodingCharacterCode' for the UserName claim already exists, skipping creating a new encoding for the claim type 'UserName'."
        }
    }
    catch [System.Exception] {
        Write-Host "Invalid encoding character code $encodingCharacterCode specified for encoding UserName claim. Make sure this character is not used in another encoding, it is above 500 (0x01F5) and not an uppercase or whitespace character. Note that not all codes above 500 work, here are few examples to use: 509, 517, 519 and 525." -ForegroundColor Red
        exit            
    }
    
    try {
        $usernameClaimMap = New-SPClaimTypeMapping -IncomingClaimType $usernameClaim -IncomingClaimTypeDisplayName $userName -SameAsIncoming
        $upnClaimMap = New-SPClaimTypeMapping -IncomingClaimType $upnClaim -IncomingClaimTypeDisplayName $upn -SameAsIncoming
        $roleClaimMap = New-SPClaimTypeMapping -IncomingClaimType $roleClaim -IncomingClaimTypeDisplayName $role -SameAsIncoming 
        $emailClaimMap = New-SPClaimTypeMapping -IncomingClaimType $emailClaim -IncomingClaimTypeDisplayName $emailAddress -SameAsIncoming

        New-SPTrustedIdentityTokenIssuer -Name $trustName -Description $trustDescription -realm $realm -ImportTrustCertificate $cert -ClaimsMappings $usernameClaimMap, $upnClaimMap, $roleClaimMap, $emailClaimMap -SignInUrl $signInURL -IdentifierClaim $usernameClaimMap.InputClaimType
    }
    catch [System.Exception] {
        handle_error $_.Exception.ToString()
    }
}