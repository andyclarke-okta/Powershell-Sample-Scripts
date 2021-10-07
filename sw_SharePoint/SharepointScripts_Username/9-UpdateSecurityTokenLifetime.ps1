Set-ExecutionPolicy Unrestricted

if((Get-PSSnapin "Microsoft.SharePoint.PowerShell") -eq $null)
{
      Add-PSSnapin Microsoft.SharePoint.PowerShell
}

##effective token lifetime is;
##WindowsTokenLifetime - LogonTokenCacheExpirationWindows = duration since creation that token is valid

#check token lifetime
$sptokensvc= Get-SPSecurityTokenServiceConfig
$sptokensvc
#set token lifetime for short refresh turnaround
 $sptokensvc.FormsTokenLifetime = (New-TimeSpan -minutes 2)
 $sptokensvc.WindowsTokenLifetime = (New-TimeSpan -minutes 2)
 $sptokensvc.LogonTokenCacheExpirationWindow = (New-TimeSpan -minutes 1)
 $sptokensvc.Update()