Add-PSSnapin Microsoft.Sharepoint.PowerShell

$WebAppName = "https://okta.myApp.mydomain.com" 
$wa = get-SPWebApplication $WebAppName 
$wa.UseClaimsAuthentication = $true 
$wa.Update()

##optional steps to set search scope to Okta App Level
#$wa.properties["UserSearchScope"] = "APP";
##Application Id from Okta integration
#$wa.properties["UserSearchScopeAppId"] = "0oadojqhp2kYP6MJD0h7";
#$wa.Update()

##optional steps to set search scope to Okta Org Level
#$wa.properties["UserSearchScope"] = "OKTA";
#$wa.Update()
