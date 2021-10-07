Add-PSSnapin Microsoft.Sharepoint.PowerShell

$ap = Get-SPTrustedIdentityTokenIssuer "Okta" 

$uri = new-object System.Uri("https://okta.myApp.mydomain.com") 

$ap.ProviderRealms.Add($uri, "urn:okta:sharepoint:exkdojqhp1GZxLA520h7") 

$ap.Update()