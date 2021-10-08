#import users from csv file
#site config
$org = "https://subdomain.oktapreview.com"
$token="00ZZed896xgjEPUWP3TgGkF1o0Mxxxxxxxxxxxxx"
$basicAuthValue = "SSWS $token"
$headers = @{}
$headers["Authorization"] = $basicAuthValue
$headers["Accept"] = "application/json"
$headers["Content-Type"] = "application/json"

##import from user file
$myCsv = import-csv "C:\temp\ImportUser.csv "
##loop through each user and get oktaLogin
$countAll = 0;
$countProcessed  = 0;
##query org to get okta id  
foreach($i in $myCsv)
{
    $countAll = $countAll +1;
    #get okta username  from file
    $oktaLogin = $i.Login;
	$oktaEmail =   $i.Email;
    $oktaFirst =   $i.First;
    $oktaLast =   $i.Last;
    $oktaPassword = $i.Password;
	$oktaMiddle = $i.Middle;
	$oktaRoles  = $i.Roles;
	

    ##for debug only
    write-host $oktaLogin  


	##create okta account based on attributes
	$countProcessed = $countProcessed +1;

		##collect roles into local array
        ##clean up any anomalies with input to array
        $mod1OktaRoles = $oktaRoles.Replace(" ","");
        $modOktaRoles = $mod1OktaRoles.Trim(";"," ");
	
        $myRolesArray = $modOktaRoles -split ";";

	#API parameters
	$body2 =@{
				"profile" = @{"login" = $oktaLogin;
							  "firstName" = $oktaFirst;
							  "middleName" = $oktaMiddle;
							  "lastName" =  $oktaLast;
							  "email" =    $oktaEmail;
                               "roles" = $myRolesArray;
							   };
				"credentials" = @{
					"password" = @{
						"value" = $oktaPassword;
					};
				};
			}
	$json_body2 = $body2 | ConvertTo-Json 

	$uri2 = "$org/api/v1/users?activate=true";
	$result2 = Invoke-WebRequest -Uri $uri2  -Headers $headers -Method POST   -Body $json_body2
	$myOut2 =  $result2.Content | ConvertFrom-json 
	$oktaId = $myOut2.Id;


	if($result2.StatusCode -eq 200)
	{
		Write-Host $oktaLogin  "User Creation Succesfull"	
		
	}
	else
	{
		Write-Host $oktaLogin  "User Creation Failed"
	}
	
	$body2 = "";

	$json_body2 = "";

	$result2 = "";

	$myOut2 = "";



    $oktaLogin =   "";
	$oktaEmail =     "";
    $oktaFirst =     "";
    $oktaLast =     "";
    $oktaPassword =   "";
	$oktaMiddle =   "";
	$oktaRoles  =   "";
    $oktaId = "";

 }#end foreach entry in input file
 write-host $countProcessed  $countAll
 $result1 = "";
