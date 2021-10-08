
#config home folder
$homeFolder = "C:\OktaUsers\TestUsers";

#setup output file headers
$myFile = "$homeFolder\Test_User_import_100.csv";
"uid,givenname,sn,mail," |Out-File $myFile


write-host "script start " (get-date).ToString()



For ($x=1; $x -le 100; $x++)
{

$A = "test.okta" + $x + "@mailinator.com";
$B = "okta" + $x;
$C = "oktatest"+ $x;
$D = "test.okta" + $x +  "@mailinator.com";

$wrapper = New-Object PSObject -Property @{ uid = $A; givenname = $B;sn =$C;mail=$D }
Export-Csv -InputObject $wrapper -Path $myFile -Append -Force
}


write-host "script end " (get-date).ToString()