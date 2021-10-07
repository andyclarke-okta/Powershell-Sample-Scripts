Add-PSSnapin Microsoft.Sharepoint.PowerShell

New-SPClaimTypeEncoding -EncodingCharacter ([Convert]::ToChar(527)) -ClaimType "http://schemas.okta.com/claims/username" -Force

$usernameClaimMap = New-SPClaimTypeMapping -IncomingClaimType "http://schemas.okta.com/claims/username" -IncomingClaimTypeDisplayName "UserName" -SameAsIncoming 

$upnClaimMap = New-SPClaimTypeMapping -IncomingClaimType "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn" -IncomingClaimTypeDisplayName "UPN" -SameAsIncoming 

$roleClaimMap = New-SPClaimTypeMapping -IncomingClaimType "http://schemas.microsoft.com/ws/2008/06/identity/claims/role" -IncomingClaimTypeDisplayName "Role" -SameAsIncoming 

$emailClaimMap = New-SPClaimTypeMapping -IncomingClaimType "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress" -IncomingClaimTypeDisplayName "EmailAddress" -SameAsIncoming