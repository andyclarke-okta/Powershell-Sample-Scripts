#reset users password using csv
#site config
$org = "https://xxxxx.oktapreview.com"
$token="xxxxxxxxxxxx-xxxxxxxxxxxxxxxxxx"
$basicAuthValue = "SSWS $token"
$headers = @{}
$headers["Authorization"] = $basicAuthValue
$headers["Accept"] = "application/json"
$headers["Content-Type"] = "application/json"


##import from user file
$myCsv = import-csv "C:\temp\UserList.csv"
##loop through each user and get oktaLogin
$countAll = 0;
$countProcessed  = 0;
##query org to get okta id  
foreach($i in $myCsv)
{
    $countAll = $countAll +1;
    #get okta username  from file
    $oktaLogin = $i.Login;

    ##for debug only
    #write-host $oktaLogin  

    ##use oktaLogin to get oktaId
    $uri1 = "$org/api/v1/users/$oktaLogin"
    $result1 = Invoke-WebRequest -Uri $uri1  -Headers $headers -Method GET
    $rContent1 =  $result1.Content | ConvertFrom-json 
    $oktaId = $rContent1.id
    $provider = $rContent1.credentials.provider.type

    ##for debug only
    write-host $oktaLogin  $oktaId $provider

    if($provider -eq "okta")
    {
    $countProcessed = $countProcessed +1;
        ##reset password
      #  $uri2 = "$org/api/v1/users/" + $oktaId + "/lifecycle/reset_password?sendEmail=false"
        $uri2 = "$org/api/v1/users/" + $oktaId + "/lifecycle/reset_password?sendEmail=true"
		
        $result2 = Invoke-WebRequest -Uri $uri2 -Headers $headers -Method POST  
        $rContent2 = $result2.Content | ConvertFrom-Json
		#$rContent2 
		#write-host " state token  " $rContent2.stateToken
		#$rContent2.status
		#$rContent2._links
		#$rcLinks  = $rContent2._links
		#$rcLinks | Get-Member
		#$rclCancel = $rcLinks.cancel
		#$rclNext = $rcLinks.next
		#$rclResend = $rcLinks.resend
		#$rclNext | Get-Member
		#$rclNext.name
		$rclNext.href
        ##for debug only
        write-host $oktaLogin  $oktaId $result2.StatusCode
    }
 }
 write-host $countProcessed  $countAll
 $result1 = "";
 $result2 = "";