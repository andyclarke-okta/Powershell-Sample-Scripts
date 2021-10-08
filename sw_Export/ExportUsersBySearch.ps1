# Export users of designated group to CSV file


#Requires -Module OktaAPI
Import-Module OktaAPI
write-host "script start " (get-date).ToString()


# Site config
$org = "https://subdomain.oktapreview.com"
$token="00oZO57fOmgFZlHQxxxxxxxxxxxxxxxxxxxx"
#config home folder
$homeFolder = "c:\\Report_Output";
#setup output file and headers
$timestamp = Get-Date -uFormat "%Y%m%d%H%M%S";
$exportLocation = "$homeFolder\Export_Users_$timestamp.csv";



# Call this before calling Okta API functions. 
Connect-Okta $token $org



# define group functions
function Export-PagedGroupMembers($groupId) {
    $totalUsers = 0
    $exportedUsers = @()
    $params = @{search = "lastUpdated%20lt%20%222021-10-09T00:00:00.000Z%22";limit = 200}

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
           ## Write-Host "NextUrl", $page.nextUrl
        }

    } while ($page.nextUrl)

    $exportedUsers | Export-Csv $exportLocation -notype
    Write-Host "$totalUsers users exported."
}










#make call to function
Export-PagedGroupMembers($groupId);
write-host "script end " (get-date).ToString()
