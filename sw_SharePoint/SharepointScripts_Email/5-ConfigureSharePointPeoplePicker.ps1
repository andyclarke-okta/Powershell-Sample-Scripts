Add-PSSnapin Microsoft.Sharepoint.PowerShell

$farm = Get-SPFarm

$farm.Properties["OktaApiKey"] = "00WL7eECA5AOMYYxxxxxxxxxxxxxxxxxxx"

$farm.Properties["OktaBaseUrl"] = "https://subdomain.oktapreview.com" 

$farm.Properties["OktaLoginProviderName"] = "Okta" 

$farm.Properties["OktaClaimProviderDisplayName"] = "Okta"

##If C2WTS is to be enabled, also execute the following command:
$farm.Properties["MapUpnToWindowsUser"] = $true

$farm.Properties["UniqueUserIdentifierClaimType"] = "Email"

$farm.Update()