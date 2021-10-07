#create csv of user in group
#site config
$org = "https://subdomain.oktapreview.com"
$token="00UU2ks286RunK_8JqBxxxxxxxxxxxxxxxxxx"

$basicAuthValue = "SSWS $token"
$headers = @{}
$headers["Authorization"] = $basicAuthValue
$headers["Accept"] = "application/json"
$headers["Content-Type"] = "application/json"

$countProcessed = 0;  
$countAll = 0;

#get groupId from group name
$groupName = "AcmeInc"
$contains = "*beach*";

$uri1 = "$org/api/v1/groups?q=" + $groupName
$result1 = Invoke-WebRequest -Uri $uri1 -Headers $headers -Method GET
$groupInfo = $result1.Content | ConvertFrom-json 
$groupId  = $groupInfo.id
write-host "Group Id " $groupId

#get users for named group
$uri2 = "$org/api/v1/groups/" + $groupId + "/users/"
$result2 = Invoke-WebRequest -Uri $uri2 -Headers $headers -Method GET
 
$rContent2 = $result2.Content | ConvertFrom-json 
##$rContent2


	if($result2.StatusCode -eq 200)
	{


        foreach($i in $rContent2)
        {
            $i.profile.email;
    
            ##$profile = $rContent2.profile;
            

            $oktaLogin = $i.profile.login;
            $email = $i.profile.email;
            $firstName = $i.profile.firstName;
            $lastName = $i.profile.firstName;

            #check if user belongs in admin or user group
	        if($email -like $contains)
	        { 
		        $myOutput =  "$oktaLogin, $email, $firstName, $lastName " |Out-File C:\temp\group_members.csv -Append
		        write-host $email  " add as member of " $groupName
                $countProcessed = $countProcessed +1;
	        }

            $profile = "";
            $oktaLogin = "";
            $email = "";
            $firstName = "";
            $lastName = "";
            $countAll = $countAll + 1;
        } # end foreach

	} # end if
	else
	{
	
        write-host   "failed acquiring group members";
	}
 write-host $countProcessed  $countAll