Add-PSSnapin Microsoft.Sharepoint.PowerShell

$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("C:\\Okta_SharePoint\SharepointScripts\okta.cert")
New-SPTrustedRootAuthority -Name "Token Signing Cert" -Certificate $cert