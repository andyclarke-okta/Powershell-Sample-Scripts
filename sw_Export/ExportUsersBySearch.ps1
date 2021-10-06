# Export users of designated group to CSV file


#Requires -Module OktaAPI
Import-Module OktaAPI
write-host "script start " (get-date).ToString()


# Site config
$org = "https://aclarkeImport.oktapreview.com"
$token="00oZO57fOmgFZlHQy0WCOIpkLD0oL6PshJyiOfR3-l"
#config home folder
$homeFolder = "c:\\Report_Output";
#setup output file and headers
$timestamp = Get-Date -uFormat "%Y%m%d%H%M%S";
$exportLocation = "$homeFolder\Export_Users_$timestamp.csv";
##"userID,firstName,lastName,password,email,udf1,udf2,udf3,udf4,udf5,udf6,udf7,udf8,udf9,udf10,startDate,endDate,branch,alternateUserID,secQuestion,secAnswer" |Out-File $exportLocation


# Call this before calling Okta API functions. 
Connect-Okta $token $org



# define group functions
function Export-PagedGroupMembers($groupId) {
    $totalUsers = 0
    $exportedUsers = @()
    $params = @{search = "lastUpdated%20gt%20%222021-10-01T00:00:00.000Z%22";limit = 200}

    do {
        $page = Get-OktaUsers @params
        $users = $page.objects
        foreach ($user in $users) {
            ##for debug only
            ##Write-Host $user.profile.login
            $exportedUsers += [PSCustomObject]@{id = $user.id;
                                                Status = $user.status;
                                                LastLogin = $user.lastLogin;
                                                LastPWSet = $user.passwordChanged;
                                                CreateDate = $user.created;
                                                Activated = $user.activated;
                                                Login = $user.profile.login;
                                                First =   $user.profile.firstName;
                                                Last =   $user.profile.lastName;
	                                            Email  = $user.profile.email;
                                                }
        }
        $totalUsers += $users.count
        $params = @{url = $page.nextUrl; paged = $true}

        ##for debug only
        if($page.nextUrl -ne $null)
        {
            Write-Host "NextUrl", $page.nextUrl
        }

    } while ($page.nextUrl)

    $exportedUsers | Export-Csv $exportLocation -notype
    Write-Host "$totalUsers users exported."
}










#make call to function
Export-PagedGroupMembers($groupId);
write-host "script end " (get-date).ToString()
