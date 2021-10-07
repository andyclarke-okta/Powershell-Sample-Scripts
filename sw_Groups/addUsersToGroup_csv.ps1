#read okta login from csv file and add to specified group
#site config
$org = "https://xxxxxxxxxxxxx.oktapreview.com"
$token="xxxxxxxxxxx-xxxxxxxxxxxxxxxxx"
$basicAuthValue = "SSWS $token"
$headers = @{}
$headers["Authorization"] = $basicAuthValue
$headers["Accept"] = "application/json"
$headers["Content-Type"] = "application/json"


#get group id by name
#get groupId from group name
$groupName = "Operations"
$uri = $org +  "/api/v1/groups?q=" + $groupName
$result = Invoke-WebRequest -Uri $uri -Headers $headers -Method GET
$groupInfo = $result.Content | ConvertFrom-json 
$groupId  = $groupInfo.id
write-host $groupId


###############################################################
##import from user file
$myCsv = import-csv "C:\temp\UserList.csv"
##import from user file
$countAll = 0;
$countProcessed  = 0;

#########################################################################
##query org to get okta id  
foreach($i in $myCsv)
{
    $countAll = $countAll +1;
    #get okta username  from file
    $oktaLogin = $i.Login;

    ##for debug only
   # write-host $oktaLogin  

     ##use oktaLogin to get oktaId
    $uri1 = $org + "/api/v1/users/" + $oktaLogin
    $result1 = Invoke-WebRequest -Uri $uri1  -Headers $headers -Method GET
    $myOut1 =  $result1.Content | ConvertFrom-json 
    $oktaId = $myOut1.id
 
	if($result1.StatusCode -eq 200)
	{
		##use okta internal id and group add, to add group membership
		$uri2 = $org + "/api/v1/groups/" + $groupId + "/users/" + $oktaId
		$result2 = Invoke-WebRequest -Uri $uri2 -Headers $headers -Method  PUT
		$myOut2 =  $result2.Content | ConvertFrom-json 

		write-host $oktaLogin  " add as member of " $groupName
		
		$result1 = "";
		$myOut1 =  "";
		$oktaId = "";
		$result2 = "";
		$myOut2 = "";
	} # end if
	else
	{
	    $myOutput =  "$oktaLogin, $oktaId, $groupName, $groupId" |Out-File C:\temp\failed_group_membership.csv -Append
	}
	
	
	
 }  # end foreach
 write-host $countProcessed  $countAll
 $result1 = "";
 $result2 = "";