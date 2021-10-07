Set-ExecutionPolicy Unrestricted

if((Get-PSSnapin "Microsoft.SharePoint.PowerShell") -eq $null)
{
      Add-PSSnapin Microsoft.SharePoint.PowerShell
}



#web application for host named site collections
#these have same result
$app = Get-SPWebApplication http://as-sites-okta
$app
$app.Sites

$app1 = Get-SPWebApplication 'My Solutions Okta Sites'
$app1
$app1.Sites

 
$wa = Get-SPWebApplication "https://okta.myApp.mydomain.com"
$wa.UseClaimsAuthentication
$wa.properties

#root site collection
$site = Get-SPSite -Identity "http://as-sites-okta/"
$site

$site1 = Get-SPSite -Identity "http://okta.myApp.mydomain.com/as/mybusiness"
$site1

$url = Get-SPSiteURL -Identity (Get-SPSite -Identity "http://okta.myApp.mydomain.com/as/mybusiness")
$url

$path = Get-SPManagedPath -WebApplication http://as-sites-okta 
$path

$webApp = Get-SPWebapplication 'http://as-sites-okta'
foreach($spSite in $webApp.Sites)
{
if ($spSite.HostHeaderIsSiteName) 
{ Write-Host $spSite.Url 'is host-named' }
else
{ Write-Host $spSite.Url 'is path based' }
}



