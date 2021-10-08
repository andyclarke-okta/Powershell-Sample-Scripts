#set appLevel Username
#site config
$org = "https://xxx.oktapreview.com"
$token="xxxxx-xxxxx"
$basicAuthValue = "SSWS $token"
$headers = @{}
$headers["Authorization"] = $basicAuthValue
$headers["Accept"] = "application/json"
$headers["Content-Type"] = "application/json"

#set up constants
$appID  ="0oa1ntujben3yZ9FW0x7"   ##zendesk

##import from user file
$myCsv = import-csv "C:\temp\gc_import_csv_forScript.csv"
#$myCsv  | get-member

##loop through each user
##get oktaLogin and  jiveLogin from file
##query org to get okta id  
foreach($i in $myCsv)
{
    $oktaLogin = $i.login;
    $jiveLogin = $i.jiveusername;

    ##use oktaLogin to get oktaId
    #get one user
    $uri1 = "$org/api/v1/users/$oktaLogin"
    $result1 = Invoke-WebRequest -Uri $uri1  -Headers $headers -Method GET
    $rContent1 =  $result1.Content | ConvertFrom-json 
   # write-host $result.Content | ConvertFrom-json | select -Property id
    $oktaId = $rContent1.id

    ##for debug only
    write-host $oktaLogin $jiveLogin $oktaId

#################################################################################
    ##set parameters for each user to add App
    $body =@{"credentials"= @{
                           "userName" = $jiveLogin
                             }
            }

    $json_body = $body | ConvertTo-Json
    $uri2 = "$org/api/v1/apps/$appID/users/$oktaId"

    $result2 = Invoke-WebRequest -Uri $uri2 -Headers $headers -Method POST  -Body $json_body
    #for debug only
    $rContent2 = $result2.Content | ConvertFrom-json
    write-host $rContent2.credentials
} 

  
 