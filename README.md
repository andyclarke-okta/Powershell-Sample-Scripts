# Powershell-Sample-Scripts

## Sample Powershell scripts for Identity Management on the Okta Platform

These scripts are Unofficial code designed to get you started with managing your Okta tenent via PowerShell

## System Requirements
Powershell can be installed on Windows, Linux and macOS.

Windows users can execute version 5.1 or version 7.1. Windows Powershell ISE is compatible with version 5.1
Linux and macOS require version 7.1

Installing PowerShell on Windows, macOS or Linux use version 7
* https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1

If you want to execute PowerShell ISE on Windows use version 5
* https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-5.1

To determine which version of PowerShell you're running, see PSVersion under `$PSVersionTable`.

## Getting Started
Most of the scripts are self contained and don't require external libraries. 
A few scripts leverage an external library. See "Other Resources". 
You can determine which code model works best for your needs.

The scripts require that you specify;
* Your Okta tenent; $org
* Your Okta tenent apiToken with the proper permissions; $token
	* https://developer.okta.com/docs/guides/create-an-api-token/overview/
* Some other information such as $groupId may be required by some scripts.
* Scripts that process input and/or output files may require accessible folder sctructures.

Example script config

```json

# Site config
$org = "https://subdomain.oktapreview.com"
$token="00FTs0L6e_TtBh7oWqV-xxxxxxxxxxxxxxxx"


#config home folder
$homeFolder = "C:\repos\sw_Powershell\sw_UserImport";
#setup input file
$inputFile = "$homeFolder\SampleImport_SHA256_10.csv";


#setup output file headers
$timestamp = Get-Date -uFormat "%Y%m%d%H%M%S";
$success = "$homeFolder\Successfull_ProcessUser_$timestamp.csv";
$failCreate = "$homeFolder\Failed_CreateUser_$timestamp.csv";
$failUpdate = "$homeFolder\Failed_UpdateUser_$timestamp.csv";
"email,firstName,lastName,customId,city,dateOfBirth,hashPassword,hashSalt" |Out-File $success
"email,firstName,lastName,customId,city,dateOfBirth,hashPassword,hashSalt" |Out-File $failCreate
"email,firstName,lastName,customId,city,dateOfBirth,hashPassword,hashSalt" |Out-File $failUpdate

```


## Other Resources
Some of the scripts use a Powershell library (OktaAPI.psm1) created to facilitate API features

https://github.com/gabrielsroka/OktaAPI.psm1

https://www.powershellgallery.com/packages/OktaAPI

To Install on PowerShell 5:

PS> Install-Module -Name OktaAPI  -Scope CurrentUser
This command will install the powesrshell module in your local store found at; 
$HOME\Documents\WindowsPowerShell\Modules

PS> Install-Module -Name OktaAPI -Scope AllUsers -AllowClobber
This command will install the powesrshell module in your global store found at;
C:\Program Files\WindowsPowerShell\Modules

Other sample scripts can be found at;
* https://www.powershellgallery.com/packages/CallOktaAPI
	* CallOktaAPI.ps1 has sample code. Replace YOUR_API_TOKEN and YOUR_ORG with your values or use OktaAPISettings.ps1.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request

**Note**: Contributing is very similar to the Github contribution process as described in detail 
[here](https://guides.github.com/activities/forking/).
