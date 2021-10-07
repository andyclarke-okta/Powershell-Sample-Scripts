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

$app1 = Get-SPWebApplication 'Assurant Solutions Okta Sites'
$app1
$app1.Sites

 
$wa = Get-SPWebApplication "https://okta.myApp.mydomain.com"
$wa.UseClaimsAuthentication
$wa.ApplicationPool.Name
$wa.ApplicationPool.Username
$wa.ApplicationPool.ProcessAccount
$wa.properties

#get service application info
$sa = Get-SPServiceApplication
$sa.DisplayName
##$sa|Format-Table -Wrap -AutoSize
$spapp1 = Get-SPServiceApplication -Name "SQL Reporting Services - AIZ"
$spguid1 = $spapp1.id
$spapp1.ApplicationPool.ProcessAccount
$security1 = Get-SPServiceApplicationSecurity $spguid1
$security1.NamedAccessRights
$spapp2 = Get-SPServiceApplication -Name "SQL Reporting Services - AS"
$spguid2 = $spapp2.id
$spapp2.ApplicationPool.ProcessAccount
$security2 = Get-SPServiceApplicationSecurity $spguid2
$security2.NamedAccessRights
$spapp3 = Get-SPServiceApplication -Name "SQL Reporting Services - ASP"
$spguid3 = $spapp3.id
$spapp3.ApplicationPool.ProcessAccount
$security3 = Get-SPServiceApplicationSecurity $spguid3
$security3.NamedAccessRights


Get-SPSolution

#root site collection
$site = Get-SPSite -Identity "http://as-sites-okta/"
$site

$site1 = Get-SPSite -Identity "http://okta.myApp.mydomain.com/as/preneedtest"
$site1

#check url is using zone configured with Okta
$url = Get-SPSiteURL -Identity (Get-SPSite -Identity "http://okta.myApp.mydomain.com/as/preneedtest")
$url

$path = Get-SPManagedPath -WebApplication http://as-sites-okta 
$path

#these have same result
$app = Get-SPWebApplication http://as-sites-okta
$app
$app.Sites

$app1 = Get-SPWebApplication 'My Solutions Okta Sites'
$app1
$app1.Sites

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


#check token lifetime
$sptokensvc= Get-SPSecurityTokenServiceConfig
$sptokensvc

