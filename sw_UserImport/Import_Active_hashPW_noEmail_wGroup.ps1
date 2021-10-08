# Import users from csv file in ACTIVE state with hashed password and Security Question

# Site config
$org = "https://subdomain.oktapreview.com"
$token="00FTs0L6e_TtBh7oWqVxxxxxxxxxxxxxxxxxxx"
$basicAuthValue = "SSWS $token"
$headers = @{}
$headers["Authorization"] = $basicAuthValue
$headers["Accept"] = "application/json"
$headers["Content-Type"] = "application/json"


#config home folder
$homeFolder = "C:\UserImport";
#setup input file
$inputFile = "$homeFolder\SampleImport_SHA256_10.csv";


#setup output file headers
$timestamp = Get-Date -uFormat "%Y%m%d%H%M%S";
$success = "$homeFolder\Successfull_ProcessUser_$timestamp.csv";
$failCreate = "$homeFolder\Failed_CreateUser_$timestamp.csv";
$failUpdate = "$homeFolder\Failed_UpdateUser_$timestamp.csv";
"email,firstName,lastName,customId,city,dateOfBirth,hashPassword,hashSalt" |Out-File $success
"email,firstName,lastName,customId,city,dateOfBirth,hashPassword,hashSalt" |Out-File $failCreate
"email,firstName,lastName,customId,city,dateOfBirth,hashPassword,hashSalt" |Out-File $failUpdate

write-host "script start " (get-date).ToString()


# pre set config values
$groupId = "00grgk9kr8XzWtxTh0h7";
$saltOrder = "PREFIX"
$algorithm = "SHA-256";


# Import from user file
$myCsv = import-csv $inputFile
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
    $userLogin = $i.email;
    $userEmail  = $i.email;
    $userFirst =   $i.firstName;
    $userLast =   $i.lastName;
    $userCustomId = $i.customId;
    $userCity = $i.city;
    $userDateOfBirth = $i.dateOfBirth;
    $pswHashValue = $i.hashedPassword;
    $pswHashSalt = $i.hashSalt;

	##see if user already exists
    ## this allows script to process list recursively
    ## can be omitted on clean run
    $statusCode = "";
	$uri4 = $org + "/api/v1/users/" + $userLogin
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
        write-host "user exists " + $userLogin

        
        $statusCode = "";

		$body5 =@{

					"profile" = @{
                                  "login" =        $userLogin;
								  "email" =        $userEmail;
								  "firstName" =    $userFirst;
								  "lastName" =     $userLast;
                                  "customId" =     $userCustomId;
                                  "city" =         $userCity;
                                   "dateOfBirth" = $userDateOfBirth;
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
            write-host "Updated User "  $userLogin
            $countUpdated++;
        }
        else
        {
            Export-csv -Path $failUpdate -InputObject $i -Append -Force
            write-host "Failed to Update User "  $userLogin
        }

	}
	else
	{
		# user does not exist, add

        $statusCode = "";

		$body2 =@{
                    "credentials" = @{
                                        "password" = @{
                                            "hash" =@{
                                            		 "algorithm" = $algorithm;
		                                             "salt" =      $pswHashSalt;
		                                             "saltOrder" = $saltOrder;
		                                             "value" =     $pswHashValue;
                                            };
                                        };
                                    };
					"profile" = @{
                                  "login" =       $userLogin;
								  "email" =       $userEmail;
								  "firstName" =   $userFirst;
								  "lastName" =    $userLast;
                                  "customId" =    $userCustomId;
                                  "city" =        $userCity;
                                  "dateOfBirth" = $userDateOfBirth;
								 };
                    "groupIds" = @(
                                    $groupId
                                 )

				};
		$json_body2 = $body2 | ConvertTo-Json -Depth 4
		
		$uri2 = "$org/api/v1/users?activate=true";
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
            ##create okta account based on attributes
	        $countCreated = $countCreated +1;

		}
        else
        {
            Export-csv -Path $failCreate -InputObject $i -Append -Force
            write-host "Failed to Create User " + $userLogin
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

	$result2 = "";
	$result4 = "";
	$result5 = "";
	$myOut2 = "";
	$myOut4 = "";
	$myOut5 = "";

    $userLogin =   "";
	$userEmail =     "";
    $userFirst =     "";
    $userLast =     "";
    $userCustomId = "";
    $userCity = "";
    $userDateOfBirth = "";
    $pswHashValue = "";
    $pswHashSalt = "";

    $oktaId = "";



 }#end foreach entry in input file
 write-host "Users Create: "$countCreated
 write-host "Users Updated: " $countUpdated
 write-host "Total Users: " $countAll
 write-host "script end " (get-date).ToString()