$usercred=Get-Credential
$session=New-psSession -ComputerName "DC_PC_NAME" -Authentication Kerberos -Credential $usercred
Import-Module -PSsession $session -Name ActiveDirectory
Get-ADComputer -SearchBase "DC=...,DC=local" -Filter * -Properties * | where {$_.Name -like "NB-*"} | Sort-Object DNSHostName | ft DNSHostName 
Remove-PSSession $session
Pause