#requires -RunAsAdministrator
# Solo consultas. No muestra claves compartidas.
$ErrorActionPreference = "Stop"
Import-Module ActiveDirectory
Import-Module NPS
Get-Date
Get-CimInstance Win32_ComputerSystem | Select-Object Name,Domain,PartOfDomain,DomainRole
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' |
    Select-Object ProductName,CurrentBuild,UBR
Get-NetIPConfiguration
Get-Service IAS,NTDS,DNS | Format-Table Status,Name,DisplayName
Get-NpsRadiusClient | Format-Table Name,Address,Enabled,AuthAttributeRequired
Get-NetUDPEndpoint -LocalPort 1812,1813 | Format-Table LocalAddress,LocalPort
auditpol /get /subcategory:"Network Policy Server"
foreach ($aaaNivel in 0,5,10) {
    Get-ADGroupMember "NIVEL-$aaaNivel" | Select-Object Name,SamAccountName
    Get-ADUser "usuario$aaaNivel" -Properties LockedOut,PasswordExpired |
        Select-Object SamAccountName,Enabled,LockedOut,PasswordExpired
}
$aaaDesde = (Get-Date).AddHours(-1)
$aaaEventos = @(Get-WinEvent -FilterHashtable @{
    LogName="Security"
    Id=6272,6273,6274
    StartTime=$aaaDesde
} -MaxEvents 100 -ErrorAction SilentlyContinue |
    Where-Object { $_.Message -match 'usuario(?:0|5|10)(?:@|\\|\s)' } |
    Select-Object -First 6)
if ($aaaEventos.Count) {
    $aaaEventos | Format-List TimeCreated,Id,Message
} else {
    Write-Host "No hay eventos recientes de las cuentas del laboratorio. Realizar una prueba nueva."
}
