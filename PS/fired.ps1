[CmdletBinding()]
Param (
[Parameter (Mandatory=$true, Position=1)]
[string] $userLogin
)

$ouDN = "OU=USERS FIRED,OU=RZDBA.RU,DC=rzdba,DC=local"
$firedCN = "CN=Fired_users,OU=USERS FIRED,OU=RZDBA.RU,DC=rzdba,DC=local"

# Получаем RID для группы Fired_users
$groupRID = Get-ADGroup -Identity Fired_users -Property primaryGroupToken | Select-Object -ExpandProperty primaryGroupToken

# 1 Делаем учетку общим ящиком
Set-Mailbox -Identity $userLogin -type shared

# 2 Переименовываем учетку
#$user = (Get-ADUser -Identity $userLogin -Properties DisplayName).DisplayName
$user = (Get-ADUser -Identity $userLogin -Properties DisplayName).Name
$newDisplayName = "Архив-" + $user
Set-ADUser -Identity $userLogin -DisplayName $newDisplayName

# 3 Переносим учетку в OU USERS FIRED
$userDN = (Get-ADUser -Identity $userLogin -Properties DisplayName).DistinguishedName
Move-ADObject -Identity $userDN -TargetPath "OU=USERS FIRED,OU=RZDBA.RU,DC=rzdba,DC=local"

# 4 Добавляем пользователя в группу Fired_users
Add-ADGroupMember -Identity "Fired_users" -Members $userLogin

# Указываем группу в качестве основной для пользователя
Set-ADUser -Identity $userLogin -Replace @{primaryGroupID = $groupRID}

# Удаляем пользователя из всех групп, кроме Fired_users
$user = Get-ADUser -Identity $userLogin -Properties MemberOf
$groups = $user.MemberOf | Where-Object { $_ -ne $firedCN }

foreach ($group in $groups) {
        Remove-ADGroupMember -Identity $group -Members $userLogin -Confirm:$false
}

Set-Mailbox -Identity $userLogin -HiddenFromAddressListsEnabled $true
Set-CASMailbox -Identity $userLogin -OWAEnabled $false