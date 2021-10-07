Set-ExecutionPolicy Unrestricted

if((Get-PSSnapin "Microsoft.SharePoint.PowerShell") -eq $null)
{
      Add-PSSnapin Microsoft.SharePoint.PowerShell
}

#Remove Okta People picker integration

#Step1; disable peoplepicker
#from SP Central Admin console, Security->Specify Authentication providers->Zone (default)
# look for okta integration and disable
#iisreset on all servers

#Step2; remove claims provider
#get people picker solution name
#from SP Central Admin console, System Settings->Manage Farm Solutions
#SP Solution Management console
$name = 'OktaClaimsProvider.OktaClaimsProvider'
$cp = Get-SPClaimProvider | Where-Object {$_.TypeName -eq $name}
$cp
Remove-SPClaimProvider $cp
#verify people picker has been removed
Get-SPClaimProvider

#Step3; Unistall the Okta peoplepicker solution (wsp)
$solution = Get-SPSolution
$solution|Format-Table -Wrap -AutoSize
#locate and copy solution name into following command
Uninstall-SPSolution  -Identity  "oktaclaimsprovider2013-2.3.0.0-48-355ec5a.wsp"
Remove-SPSolution  -Identity  "oktaclaimsprovider2013-2.3.0.0-48-355ec5a.wsp"

#Remove Okta Sharepoint Authnetication Integration

#Step4; Remove username claim mapping since it is Okta specific let others remain
Get-SPClaimTypeEncoding -ClaimType "http://schemas.okta.com/claims/username"
Remove-SPClaimTypeMapping "UserName" | Get-SPTrustedIdentityTokenIssuer  -Identity "Okta"


#Step5; Remove Okta Identity Integration
$sts =  Get-SPTrustedIdentityTokenIssuer  -Identity "Okta"
$sts
#Note: special; remove just ProviderRealms from SPTrustedIdentityTokenIssuer

Remove-SPTrustedIdentityTokenIssuer –Identity "Okta"

#Step6; Remove cert
$rootauthority=Get-SPTrustedRootAuthority -Identity "Token Signing Cert"
$rootauthority
Remove-SPTrustedRootAuthority -Identity "Token Signing Cert"