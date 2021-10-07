##########################################
#add users to group based on Google OU
#site config
$org = "https://xxx.oktapreview.com"
$token="xxxxxx-xxxxxxxxxxxxxxxx"
$basicAuthValue = "SSWS $token"
$headers = @{}
$headers["Authorization"] = $basicAuthValue
$headers["Accept"] = "application/json"
$headers["Content-Type"] = "application/json"

#script parameters
$appId = "0oa3t3aszxgATMZoB0x7"   ##google
$GoogleOUName = "/ProServ"
$oktaGroupName = "Google_ProServ"
##########################################
#list users assigned to App


$uri = "$org/api/v1/apps/$appId/users/"

$result = Invoke-WebRequest -Uri $uri -Headers $headers -Method GET
#$result
$rContent = $result.Content | ConvertFrom-json

####################################################
#Filter user by google OU
$rContent 
$properties = @{ID='myID'; externalID = 'myExtID'; orgUnitPath = 'Default'}
$objectTemplate = New-Object -TypeName PSObject -Property $properties

$myArray = @()

foreach ($item in $rContent)
  {
	$objectCurrent = $objectTemplate.PSObject.Copy()
	$objectCurrent.ID = $item.id
	$objectCurrent.externalID = $item.externalId
    $objectCurrent.orgUnitPath = $item.profile.orgUnitPath
    $myArray += $objectCurrent
  }

$myFilteredArray = $myArray | Where-Object {$_.orgUnitPath -eq $GoogleOUName}


####################################################
#get groupId from group name
$uri = "$org/api/v1/groups?q=" + $oktaGroupName
$result = Invoke-WebRequest -Uri $uri -Headers $headers -Method GET
$groupInfo = $result.Content | ConvertFrom-json 
$groupId  = $groupInfo.id
Write-Host "GroupID= " $groupId

####################################################
#add filtered users into okta group

$myUsers = $myFilteredArray.id
foreach( $user in $myUsers)
{
    Write-Host "UserID= " $user
    $uri = "$org/api/v1/groups/" + $groupId + "/users/" + $user
    $result = Invoke-WebRequest -Uri $uri -Headers $headers -Method  PUT
}


