#delete users from csv file
#site config
$org = "https://subdomain.oktapreview.com"
$token="00A1_WGf6ZThINEvVaK-tlM_Pxxxxxxxxxx"
$basicAuthValue = "SSWS $token"
$headers = @{}
$headers["Authorization"] = $basicAuthValue
$headers["Accept"] = "application/json"
$headers["Content-Type"] = "application/json"


write-host "script start " (get-date).ToString()

##import from user file
$myCsv = import-csv "C:\OktaUsers\Preview_Import_test.csv"
##loop through each user and get oktaLogin
$countAll = 0;
$countProcessed  = 0;

foreach($i in $myCsv)
{
    $countAll = $countAll +1;
    if($countAll % 100 -eq 0)
    {
        Write-Host $countAll
    }
    #get okta username  from file
    $loginPrefix = "AP3__";
    $oktaFirst =   $i.firstName;
    $oktaLast =   $i.lastName;
	$oktaEmail  = $i.email;
    ##apply custom logic to create okta login based on userId.
    $oktaLogin = $loginPrefix + $i.userID;

    ##for debug only
    write-host $oktaLogin  

	##change profile attributes
	$countProcessed = $countProcessed +1;

	#API parameters
	$uri2 = "$org/api/v1/users/" + $oktaLogin;
	$result2 = Invoke-WebRequest -Uri $uri2  -Headers $headers -Method GET
	$myOut2 =  $result2.Content | ConvertFrom-json 
	$oktaId = $myOut2.id
	
	if($result2.StatusCode -eq 200)
	{
		$uri3 = $org + "/api/v1/users/" + $oktaId;
		$result3 = Invoke-WebRequest -Uri $uri3  -Headers $headers -Method DELETE
		$myOut3 =  $result3.Content | ConvertFrom-json

		if($result3.StatusCode -eq 204)
		{
			Write-Host $oktaLogin  "Delete/Deactivate Succesfull"
		}
		else
		{
			Write-Host $oktaLogin  "Delete/Deactivate Failed"
		}
	}
    else
    {
    Write-Host $oktaLogin  "User could not be found"
    }

	$uri2 = "";
	$uri3 = "";
	$result2 = "";
	$result3 = "";
	$myOut2 = "";
	$myOut3 = "";

    $oktaFirst = "";
    $oktaLast =  "";
	$oktaEmail  = "";
    $oktaLogin = "";
    $oktaId = "";

 
 }#end foreach entry in input file
 write-host $countProcessed  $countAll
 write-host "Script must be run twice";
 write-host "script end " (get-date).ToString()
