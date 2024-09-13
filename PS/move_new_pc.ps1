 
 Get-ADComputer -SearchBase 'CN=Computers,DC=rzdba,DC=local' -Filter * -Properties * | where {$_.Name -like "NB-*"} | Move-ADObject -TargetPath "OU=PC,OU=RZDBA.RU,DC=rzdba,DC=local"