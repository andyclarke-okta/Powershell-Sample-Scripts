Add-PSSnapin Microsoft.Sharepoint.PowerShell

Add-SPSolution -LiteralPath "C:\\Okta_Sharepoint\SharepointScripts\OktaClaimsProvider2013-2.3.0.0-48-355ec5a.wsp"
Install-SPSolution -Identity "OktaClaimsProvider2013-2.3.0.0-48-355ec5a.wsp" –GACDeployment

##execute to check deployment completion
Get-SPSolution
