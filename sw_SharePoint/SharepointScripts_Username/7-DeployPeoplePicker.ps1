Add-PSSnapin Microsoft.Sharepoint.PowerShell

Add-SPSolution -LiteralPath C:\Users\fz6302\Documents\SharepointScripts_Username\OktaClaimsProvider2013-2.3.0.0-48-355ec5a.wsp
Install-SPSolution -Identity OktaClaimsProvider2013-2.3.0.0-48-355ec5a.wsp –GACDeployment

##execute to check deployment completion
Get-SPSolution

##execute to check claim provider
Get-SPClaimProvider
