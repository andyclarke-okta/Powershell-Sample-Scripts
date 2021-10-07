#list eligible factors
#site config
$org = "https://xxxxx.okta.com"
$token="xxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxx"
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

####################

$uri2 = "$org/api/v1/users/" + $OktaId + "/factors/catalog"

$result2 = Invoke-WebRequest -Uri $uri2 -Headers $headers -Method GET
$result2.StatusCode
#$result2
#$result2.Content
#NOTE: this provides all response header fields
$rContent2 = $result2.Content | ConvertFrom-json 
$rContent2