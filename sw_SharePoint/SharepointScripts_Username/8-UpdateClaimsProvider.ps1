﻿Add-PSSnapin Microsoft.Sharepoint.PowerShell

$trust = Get-SPTrustedIdentityTokenIssuer "Okta"
$trust.ClaimProviderName = "OktaClaimsProvider"
$trust.Update()

