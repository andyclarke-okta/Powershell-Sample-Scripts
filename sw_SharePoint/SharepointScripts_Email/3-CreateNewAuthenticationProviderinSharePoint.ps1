Add-PSSnapin Microsoft.Sharepoint.PowerShell

$realm = "urn:okta:sharepoint:exkdojqhp1GZxLA520h7"
$signInURL = "https://subdomain.oktapreview.com/app/sharepoint_onpremise/sso/wsfed/passive"

$ap = New-SPTrustedIdentityTokenIssuer -Name "Okta" -Description "Okta Trusted Identity Provider" -realm $realm -ImportTrustCertificate $cert -ClaimsMappings $emailClaimMap, $upnClaimMap, $roleClaimMap -SignInUrl $signInURL -IdentifierClaim $emailClaimmap.InputClaimType