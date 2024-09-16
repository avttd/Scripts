#путь до OU с уволенными сотрудниками
$ouDN = "OU=USERS FIRED,DC=COMPANY,DC=local"

#путь до группы с уволенными сотрудниками
$firedCN = "CN=Fired_users,DC=COMPANY,DC=local"

# Получаем RID новой основной группы FIRED_USERS
$groupRID = Get-ADGroup -Identity FIRED_USERS -Property primaryGroupToken | Select-Object -ExpandProperty primaryGroupToken

# Получаем всех пользователей
$users = Get-ADUser -Filter * -SearchBase $ouDN -Properties MemberOf

foreach ($user in $users) {

#Добавляем пользователя в группу FIRED_USERS
    Add-ADGroupMember -Identity "FIRED_USERS" -Members $user.SamAccountName

#укажем группу в качестве основной для пользователя:
   Set-ADUser -Identity $user.SamAccountName -Replace @{primaryGroupID = $groupRID}

# Удаляем пользователя из всех групп, кроме FIRED_USERS
$groups = $user.MemberOf | Where-Object { $_ -ne $firedCN }
    foreach ($group in $groups) {
        Remove-ADGroupMember -Identity $group -Members $user.SamAccountName -Confirm:$false
    }
}
