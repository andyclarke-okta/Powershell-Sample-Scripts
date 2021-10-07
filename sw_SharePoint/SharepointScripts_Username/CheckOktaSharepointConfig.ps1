Set-ExecutionPolicy Unrestricted

if((Get-PSSnapin "Microsoft.SharePoint.PowerShell") -eq $null)
{
      Add-PSSnapin Microsoft.SharePoint.PowerShell
}


#Okta sharepoint integration
#check trusted root as a valid cert 
$rootauthority=Get-SPTrustedRootAuthority -Identity "Token Signing Cert"
$rootauthority

#check claims added (upn,email,role,username)
$claimType = Get-SPClaimTypeEncoding
$claimType |Format-Table -Wrap -AutoSize

#check okta integration
$sts =  Get-SPTrustedIdentityTokenIssuer  -Identity "Okta"
$sts
#should match claims provider for peope picker if configured
$sts.ClaimProviderName

#check claims registered with Token Issuer
$sts.ClaimTypeInformation
#short list for claims registered
$sts.ClaimTypes
#ties okta realm to sharepoint app
$sts.ProviderRealms


$claimprov = Get-SPClaimProvider -Identity "OktaClaimsProvider"


#check encoding of okta username claim
Get-SPClaimTypeEncoding -ClaimType "http://schemas.okta.com/claims/username"
#more generic search
Get-SPClaimTypeEncoding | ? { $_.ClaimType -like '*Okta*' };


#sharepoint people picker config
#check farm level properties supporting Okta
$farm = Get-SPFarm
$farm.Properties

#check that web app is configured to use okta

$wa = Get-SPWebApplication "http://okta.myApp.mydomain.com"
$wa.UseClaimsAuthentication
$wa.properties

#check peoplepicker deployment completion
$solution = Get-SPSolution
$solution|Format-Table -Wrap -AutoSize

#added to Trusted Identity Token Provider for People Picker
$claimProvider = Get-SPClaimProvider -Identity OktaClaimsProvider.OktaClaimsProviderReceiver 
$claimProvider

#check user group attributes set by Site permissions
$myWeb = Get-SPWeb -site "http://okta.myApp.mydomain.com/as/preneedtest"
$myWeb.SiteUsers
$myWeb.AllUsers | Select-Object -Property DisplayName
$myWeb.AllUsers | format-list
$myWeb.AllUsers | Where-Object -Property Name -eq -Value "AdminTest" | format-list
$myWeb.AllUsers | Where-Object -Property Name -eq -Value "PRODCEAD\gl-enterprise-ais" | format-list
$myWeb.SiteUsers | Where-Object -Property Name -eq -Value "okta01 spuser (okta01.spuser@gmail.com)" | format-list
