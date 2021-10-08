#delete all users in group
#site config
$org = "https://subdomain.oktapreview.com"
$token="00HqKUJ2TXqHP_wvkvanxxxxxxxxxxxxxxx"
$basicAuthValue = "SSWS $token"
$headers = @{}
$headers["Authorization"] = $basicAuthValue
$headers["Accept"] = "application/json"
$headers["Content-Type"] = "application/json"

write-host "script start " (get-date).ToString()


#get groupId from group name
$groupName = "bulk_import"

$uri1 = "$org/api/v1/groups?q=" + $groupName + "&limit=500"
$result1 = Invoke-WebRequest -Uri $uri1 -Headers $headers -Method GET
$groupInfo = $result1.Content | ConvertFrom-json 
$groupId  = $groupInfo.id
$groupId

#get users for named group
$uri2 = "$org/api/v1/groups/" + $groupId + "/users/"
$result2 = Invoke-WebRequest -Uri $uri2 -Headers $headers -Method GET
 
$rContent2 = $result2.Content | ConvertFrom-json 




##loop through each user and get oktaLogin
$countAll = 0;
$countProcessed  = 0;

foreach($i in $rContent2)
{
    $countAll = $countAll +1;
    if($countAll % 100 -eq 0)
    {
        Write-Host $countAll
    }

    $oktaId = $i.id;

    ##for debug only
    write-host $oktaId  

	##change profile attributes
	$countProcessed = $countProcessed +1;

	#API parameters
	$uri4 = $org + "/api/v1/users/" + $oktaId;
	$result4 = Invoke-WebRequest -Uri $uri4  -Headers $headers -Method DELETE
	$myOut4 =  $result4.Content | ConvertFrom-json

	if($result4.StatusCode -eq 204)
	{
		Write-Host $oktaLogin  "Delete/Deactivate Succesfull"
	}
	else
	{
		Write-Host $oktaLogin  "Delete/Deactivate Failed"
	}




	$uri1 = "";
	$uri2 = "";
	$uri3 = "";
	$uri4 = "";
	$result1 = "";
	$result2 = "";
	$result3 = "";
	$result4 = "";
	$rContent1 = "";
	$rContent2 = "";
	$rContent3 = "";
	$rContent4 = "";
	$myOut1 ="";
	$myOut2 = "";
	$myOut3 = "";
	$myOut4 = "";


    $oktaId = "";

 
 }#end foreach entry in input file
 write-host $countProcessed  $countAll
 write-host "Script must be run twice";
 write-host "script end " (get-date).ToString()
