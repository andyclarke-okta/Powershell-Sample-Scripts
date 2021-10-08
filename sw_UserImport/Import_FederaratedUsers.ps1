#create federated users from csv file
#site config
$org = "https://subdomain.oktapreview.com"
$token="00_Pv8xml"
$basicAuthValue = "SSWS $token"
$headers = @{}
$headers["Authorization"] = $basicAuthValue
$headers["Accept"] = "application/json"
$headers["Content-Type"] = "application/json"

##import from user file
$myCsv = import-csv "C:\temp\ImportUsers.csv"
##loop through each user and get oktaLogin
$countAll = 0;
$countProcessed  = 0;
##query org to get okta id  
foreach($i in $myCsv)
{
    $countAll = $countAll +1;
    #get okta username  from file
    $oktaLogin = $i.UserID;
    $oktaEmail =   $i.UserID;
    $oktaFirst =   $oktaLogin.split(".")[0];
    $oktaremainder = $oktaLogin.split(".")[1];
    $oktaLast = $oktaremainder.split("@")[0];
	$IsAdmin = $i.IsAdmin;
	$brokerId = $i.BrokerID;
	

    ##for debug only
    write-host "Process User " $oktaLogin  


	##create okta account based on attributes
	$countProcessed = $countProcessed +1;


	#check and create user if needed
	$uri1 = $org +  "/api/v1/users?q=" + $oktaLogin
	$result1 = Invoke-WebRequest -Uri $uri1 -Headers $headers -Method GET
	$myOut1 = $result1.Content | ConvertFrom-json 
    $IsFederated = $myOut1.credentials.provider.type
    $oktaId = $myOut1.Id;

	if([string]::IsNullOrEmpty($oktaId))
	{
	#API parameters
	$body2 =@{
				"profile" = @{"login" = $oktaLogin;
							  "firstName" = $oktaFirst;
							  "lastName" =  $oktaLast;
							  "email" =    $oktaEmail
							   };
				"credentials" = @{
					"password" = @{
						"value" = "QWerhghfhfruhfh001";
					};
				};
			}
	$json_body2 = $body2 | ConvertTo-Json 

	$uri2 = "$org/api/v1/users?activate=true";
	$result2 = Invoke-WebRequest -Uri $uri2  -Headers $headers -Method POST   -Body $json_body2
	$myOut2 =  $result2.Content | ConvertFrom-json 
    $IsFederated = $myOut2.credentials.provider.type
	$oktaId = $myOut2.Id;
	}
	write-host "Confirmed User " $oktaEmail

	if(-not [string]::IsNullOrEmpty($oktaId) -and $IsFederated -ne "FEDERATION")
	#if($result2.StatusCode -eq 20
	{
	
		##update user partial profile
		$uri3 = $org + "/api/v1/users/" + $oktaId + "/lifecycle/reset_password?provider=FEDERATION&sendEmail=false";
		$result3 = Invoke-WebRequest -Uri $uri3  -Headers $headers -Method POST
		$myOut3 =  $result3.Content | ConvertFrom-json

		if($result3.StatusCode -eq 200)
		{
			Write-Host $oktaLogin  "User Federation Succesfull"
		}
		else
		{
			Write-Host $oktaLogin  "User Federation Failed"
		}	
		
	}
	else
	{
        if([string]::IsNullOrEmpty($oktaId))
        {
		        Write-Host $oktaLogin  "User Creation Failed"
        }
	}
	$uri1="";
	$uri2="";
	$uri3="";
	$body2 = "";
	$body3 = "";
	$json_body2 = "";
	$json_body3 = "";
	$result1 = "";
	$result2 = "";
	$result3 = "";
	$myOut1 = "";
	$myOut2 = "";
	$myOut3 = "";


    $oktaLogin =   "";
	$oktaEmail =     "";
    $oktaFirst =     "";
    $oktaLast =     "";
    $IsFederated = "";
    $oktaId = "";

 }#end foreach entry in input file
 write-host $countProcessed  $countAll
 $result1 = "";
