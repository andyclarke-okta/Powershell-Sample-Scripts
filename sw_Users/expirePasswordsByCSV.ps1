# expire passwords for list of users

# Site config
$org = "https://subdomain.oktapreview.com"
$token="00dSM4wW3kmaxoBz-KjrUxxxxxxxxxxxxxxxx"
$basicAuthValue = "SSWS $token"
$headers = @{}
$headers["Authorization"] = $basicAuthValue
$headers["Accept"] = "application/json"
$headers["Content-Type"] = "application/json"


#config home folder
$homeFolder = "c:\OktaUsers";
#setup input file
$inputFile = "$homeFolder\expire_password_users.csv";
#$inputFile = "$homeFolder\Failed_ExpireUser_20180606174922.csv";

#setup output file headers
$timestamp = Get-Date -uFormat "%Y%m%d%H%M%S";
$success = "$homeFolder\Successfull_ExpireUser_$timestamp.csv";
$failExpire = "$homeFolder\Failed_ExpireUser_$timestamp.csv";
"appName,userID,firstName,lastName,password,email,udf1,udf2,udf3,udf4,udf5,udf6,udf7,udf8,udf9,udf10,startDate,endDate,branch,alternateUserID,secQuestion,secAnswer" |Out-File $success
"appName,userID,firstName,lastName,password,email,udf1,udf2,udf3,udf4,udf5,udf6,udf7,udf8,udf9,udf10,startDate,endDate,branch,alternateUserID,secQuestion,secAnswer" |Out-File $failExpire

write-host "script start " (get-date).ToString()


# Set suffix or prefix to append to username
##$loginSuffix = ""
##$loginPrefix = "AJC__"

# Import from user file
$myCsv = import-csv $inputFile
##loop through each user and get oktaLogin
$countAll = 0;
$countExpired  = 0;
##query org to get okta id
foreach($i in $myCsv)
{
    $countAll = $countAll +1;
    if($countAll % 100 -eq 0)
    {
        Write-Host $countAll
    }
    #get okta username  from file
    $loginPrefix = $i.appName + "__";
    ##$oktaLogin = $i.userID;
    $oktaFirst =   $i.firstName;
    $oktaLast =   $i.lastName;
    $oktaPassword = $i.password;
	$oktaEmail  = $i.email;
    $userDefined1 = $i.udf1;
    $userDefined2 = $i.udf2;
    $userDefined3 = $i.udf3;
    $userDefined4 = $i.udf4;
    $userDefined5 = $i.udf5;
    $userDefined6 = $i.udf6;
    $userDefined7 = $i.udf7;
    $userDefined8 = $i.udf8;
    $userDefined9 = $i.udf9;
    $userDefined10 = $i.udf10;
	$startDate = $i.startDate;
    $endDate = $i.endDate;
    $branch = $i.branch;
    $alternateUserID = $i.alternateUserID;


    ##apply custom logic to create okta login based on previous username.
    $oktaLogin = $loginPrefix + $i.userID;

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
        write-host "user exists " + $oktaLogin

             
$uri5 = "$org/api/v1/users/" + $oktaId + "/lifecycle/expire_password"
#$uri5 = "$org/api/v1/users/" + $oktaId + "/lifecycle/expire_password?tempPassword=true"
	    try 
	    { $result5 = Invoke-WebRequest -Uri $uri5  -Headers $headers -Method POST    }
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
            write-host "Expired User "  $oktaLogin
            $countExpired++;
        }
        else
        {
            Export-csv -Path $failExpire -InputObject $i -Append -Force
            write-host "Failed to Expire User "  $oktaLogin
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


    $oktaLogin =   "";
	$oktaEmail =     "";
    $oktaFirst =     "";
    $oktaLast =     "";
    $oktaPassword =   "";
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
    $secQuestion = "";
    $secAnswer = "";


 }#end foreach entry in input file

 write-host "Users Expired: " $countExpired
 write-host "Total Users: " $countAll
 write-host "script end " (get-date).ToString()