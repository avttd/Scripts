 
 Get-ADComputer -SearchBase 'CN=...,DC=....,DC=local' -Filter * -Properties * | where {$_.Name -like "NB-*"} | Move-ADObject -TargetPath "OU=PC,OU=...,DC=...,DC=..."