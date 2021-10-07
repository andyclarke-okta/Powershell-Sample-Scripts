#reset all MFA factors for single user
#site config
$org = "https://xxxxxxxxxxx.oktapreview.com"
$token="xxxxxxxxxxxxxxxxxxxx"
$basicAuthValue = "SSWS $token"
$headers = @{}
$headers["Authorization"] = $basicAuthValue
$headers["Accept"] = "application/json"
$headers["Content-Type"] = "application/json"


#API parameters
$user = "test.testuser1@mydomain.com"
$uri1 = "$org/api/v1/users/" + $user

$result1 = Invoke-WebRequest -Uri $uri1 -Headers $headers -Method GET
#NOTE: this provides all response header fields
$result1
#NOTE: this provides body payload
$rContent1 = $result1.Content | ConvertFrom-json
$rContent1
#$rContent.credentials
$rContent1._links
$rContent1.profile
$OktaId = $rContent1.id

######################################################
#API parameters

$uri2 = "$org/api/v1/users/" + $OktaId + "/lifecycle/reset_factors"
$result2 = Invoke-WebRequest -Uri $uri2 -Headers $headers -Method POST
#NOTE: this provides all response header fields
$result2
#NOTE: this provides body payload
$rcContent2 = $result2.Content | ConvertFrom-json
$rContent2
$rContent2.credentials