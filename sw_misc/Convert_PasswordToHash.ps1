#Here is a simple script to hash a string using your chosen cryptography algorithm.
#Usage Examples:
#Get-StringHash "My String to hash" "MD5"
#Get-StringHash "My String to hash" "RIPEMD160"
#Get-StringHash "My String to hash" "SHA1"
#Get-StringHash "My String to hash" "SHA256"
#Get-StringHash "My String to hash" "SHA384"
#Get-StringHash "My String to hash" "SHA512"

#http://jongurgul.com/blog/#Get-StringHash-get-filehash/
#https://gallery.technet.microsoft.com/scriptcenter/Get-StringHash-aa843f71

##set hash algorithm
$algo = 'SHA256';




Function Get-StringHash([String] $String,$HashName)
{
$StringBuilder = New-Object System.Text.StringBuilder
[System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))|%{
[Void]$StringBuilder.Append($_.ToString("x2"))
}
$StringBuilder.ToString()
}

$myvar = Read-Host 'Enter string to convert to hash using ' $algo 'algorithm'
Get-StringHash $myvar $algo
