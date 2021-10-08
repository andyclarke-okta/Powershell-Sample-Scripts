# Import users from csv file in STAGED state without password or security
#user will need to have password set and be activated

# Site config
$org = "https://subdomain.oktapreview.com"
$token="00HqKUJ2TXqHP_wvkvanxxxxxxxxxxxxxxxxxxxxxxxxx"
$basicAuthValue = "SSWS $token"
$headers = @{}
$headers["Authorization"] = $basicAuthValue
$headers["Accept"] = "application/json"
$headers["Content-Type"] = "application/json"

#config home folder
$homeFolder = "C:\UserImport";
#setup input file
$inputFile = "$homeFolder\SampleImport_noPW_1000.csv";
#$inputFile = "$homeFolder\Failed_CreateUser_20180320090436.csv";

#setup output file headers
$timestamp = Get-Date -uFormat "%Y%m%d%H%M%S";
$success = "$homeFolder\Successfull_ProcessUser_$timestamp.csv";
$failCreate = "$homeFolder\Failed_CreateUser_$timestamp.csv";
$failUpdate = "$homeFolder\Failed_UpdateUser_$timestamp.csv";
"login,email,firstName,lastName,userId,dateOfBirth" |Out-File $success
"login,email,firstName,lastName,userId,dateOfBirth" |Out-File $failCreate
"login,email,firstName,lastName,userId,dateOfBirth" |Out-File $failUpdate

write-host "script start " (get-date).ToString()


###  login,email,firstName,lastName,userId,dateOfBirth



# Get groupId from group name for user membership
$groupName = "bulk_import"
$uri1 = $org +  "/api/v1/groups?q=" + $groupName
$result1 = Invoke-WebRequest -Uri $uri1 -Headers $headers -Method GET
$groupInfo = $result1.Content | ConvertFrom-json 
$groupId  = $groupInfo.id



# Import from user file
$myCsv = import-csv  $inputFile
##loop through each user and get oktaLogin
$countAll = 0;
$countCreated  = 0;
$countUpdated  = 0;
##query org to get okta id
foreach($i in $myCsv)
{
    $countAll = $countAll +1;
    if($countAll % 100 -eq 0)
    {
        Write-Host $countAll
    }
    #get okta username  from file

    $oktaLogin = $i.login;
    $oktaFirst =   $i.firstName;
    $oktaLast =   $i.lastName;
	$oktaEmail  = $i.email;
    $customId = $i.userId;
	$activation_setDate = $i.dateOfBirth;




	##see if user already exists
    ## this allows script to process list recursively
    ## can be omitted on clean run
    $statusCode = "";
	$uri4 = $org + "/api/v1/users/" + $oktaLogin
	try 
	{ $result4 = Invoke-WebRequest -Uri $uri4 -Headers $headers -Method  GET }
	catch 
	{ $statusCode = $_.Exception.Response.StatusCode.Value__}	

	[bool]$statusCode |out-null
	if(!$statusCode)
	{
		$myOut4 =  $result4.Content | ConvertFrom-json 
        $oktaId = $myOut4.id;
	}
	
	$statusCode = "";
	if($result4.StatusCode -eq 200)
	{
        write-host "User Exists "  $oktaLogin

        
        $statusCode = "";

		$body5 =@{
					"profile" = @{"login" = $oktaLogin;
								  "firstName" = $oktaFirst;
								  "lastName" =  $oktaLast;
								  "email" =    $oktaEmail;
                                    "customId" = $customId;
                                    "activation_setDate" = $activation_setDate;
								   };
				}
		$json_body5 = $body5 | ConvertTo-Json 
		
		$uri5 = "$org/api/v1/users/" + $oktaId;
	    try 
	    { $result5 = Invoke-WebRequest -Uri $uri5  -Headers $headers -Method POST   -Body $json_body5 }
	    catch 
	    { $statusCode = $_.Exception.Response.StatusCode.Value__}
		
	    [bool]$statusCode |out-null
	    if(!$statusCode)
	    {
		    $myOut5 =  $result5.Content | ConvertFrom-json 
	    }

        if($result5.StatusCode -eq 200)
		{
            Export-csv -Path $success -InputObject $i -Append -Force
            write-host "Updated User "  $oktaLogin
            $countUpdated++;
        }
        else
        {
            Export-csv -Path $failUpdate -InputObject $i -Append -Force
            write-host "Failed to Update User "  $oktaLogin
        }

	}
	else
	{
		# user does not exist, add

        $statusCode = "";

		$body2 =@{
					"profile" = @{"login" = $oktaLogin;
								  "firstName" = $oktaFirst;
								  "lastName" =  $oktaLast;
								  "email" =    $oktaEmail;
                                    "customId" = $customId;
                                    "activation_setDate" = $activation_setDate;
								   };

				}
		$json_body2 = $body2 | ConvertTo-Json 
		
		$uri2 = "$org/api/v1/users?activate=false";
	    try 
	    { $result2 = Invoke-WebRequest -Uri $uri2  -Headers $headers -Method POST   -Body $json_body2 }
	    catch 
	    { $statusCode = $_.Exception.Response.StatusCode.Value__}
		
	    [bool]$statusCode |out-null
	    if(!$statusCode)
	    {
		    $myOut2 =  $result2.Content | ConvertFrom-json 
		    $oktaId = $myOut2.Id;
	    }

		if($result2.StatusCode -eq 200)
		{
            Export-csv -Path $success -InputObject $i -Append -Force
            write-host "Created User "  $oktaLogin
            $statusCode = "";

			# add to group
            # this can be done in user create api
            # kept seperate for clarity
			$uri3 = $org + "/api/v1/groups/" + $groupId + "/users/" + $oktaId						
	        try 
	        { $result3 = Invoke-WebRequest -Uri $uri3 -Headers $headers -Method  PUT }
	        catch 
	        { $statusCode = $_.Exception.Response.StatusCode.Value__}
		
	        [bool]$statusCode |out-null
	        if(!$statusCode)
	        {
		        $myOut3 =  $result3.Content | ConvertFrom-json 
	        }
            if($result3.StatusCode -eq 204)
            {
                Write-Host "Added User to Group"
            }
            else
            {
                write-host "Failed to Add User to Group"
                
            }
            ##create okta account based on attributes
	        $countCreated = $countCreated +1;

		}
        else
        {
            Export-csv -Path $failCreate -InputObject $i -Append -Force
            write-host "Failed to Create User "  $oktaLogin
        }
	}	


    #Write-Host "."

	
	$body2 = "";
	$body3 = "";
	$body4 = "";
	$body5 = "";
	$json_body2 = "";
	$json_body3 = "";
	$json_body4 = "";
	$json_body5 = "";
	$result1 = "";
	$result2 = "";
	$result3 = "";
	$result4 = "";
	$result5 = "";
	$myOut2 = "";
	$myOut3 = "";
	$myOut4 = "";
	$myOut5 = "";


    $oktaLogin =   "";
	$oktaEmail =     "";
    $oktaFirst =     "";
    $oktaLast =     "";
    $oktaId = "";

    $userDefined1 = "";
    $userDefined2 = "";
    $userDefined3 = "";
    $userDefined4 = "";
    $userDefined5 = "";
    $userDefined6 = "";
    $userDefined7 = "";
    $userDefined8 = "";
    $userDefined9 = "";
    $userDefined10 = "";
    $startDate = "";
    $endDate = "";
    $branch = "";
    $alternateUserID = "";




 }#end foreach entry in input file
 write-host "Users Create: "$countCreated
 write-host "Users Updated: " $countUpdated
 write-host "Total Users: " $countAll
 write-host "script end " (get-date).ToString()