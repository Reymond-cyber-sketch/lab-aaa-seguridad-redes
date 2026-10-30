#requires -RunAsAdministrator
# Versión reutilizable de los comandos de cuentas de la práctica.
$ErrorActionPreference = "Stop"
Import-Module ActiveDirectory
$aaaDominio = Get-ADDomain
if ($aaaDominio.DNSRoot -ne "seguridad.test") {
    throw "El dominio esperado es seguridad.test."
}
$aaaRuta = "OU=LAB-AAA,$($aaaDominio.DistinguishedName)"
if (-not (Get-ADOrganizationalUnit -Filter "Name -eq 'LAB-AAA'" -SearchBase $aaaDominio.DistinguishedName -SearchScope OneLevel)) {
    New-ADOrganizationalUnit -Name "LAB-AAA" -Path $aaaDominio.DistinguishedName
}
foreach ($aaaNivel in 0,5,10) {
    $aaaNombreGrupo = "NIVEL-$aaaNivel"
    $aaaUsuario = "usuario$aaaNivel"
    if (-not (Get-ADGroup -Filter "SamAccountName -eq '$aaaNombreGrupo'")) {
        New-ADGroup -Name $aaaNombreGrupo -SamAccountName $aaaNombreGrupo -GroupScope Global -GroupCategory Security -Path $aaaRuta
    }
    $aaaCuenta = Get-ADUser -Filter "SamAccountName -eq '$aaaUsuario'" -Properties MemberOf
    if (-not $aaaCuenta) {
        New-ADUser -Name $aaaUsuario -SamAccountName $aaaUsuario -UserPrincipalName "$aaaUsuario@seguridad.test" -Path $aaaRuta -Enabled $false
        $aaaCuenta = Get-ADUser $aaaUsuario -Properties MemberOf
    }
    if (-not $aaaCuenta.Enabled) {
        $aaaClave = Read-Host "Clave fuerte privada para $aaaUsuario" -AsSecureString
        Set-ADAccountPassword -Identity $aaaUsuario -NewPassword $aaaClave -Reset
        Enable-ADAccount -Identity $aaaUsuario
        Remove-Variable aaaClave
    }
    Set-ADUser -Identity $aaaUsuario -ChangePasswordAtLogon $false
    $aaaGrupo = Get-ADGroup $aaaNombreGrupo
    if ($aaaCuenta.MemberOf -notcontains $aaaGrupo.DistinguishedName) {
        Add-ADGroupMember -Identity $aaaGrupo -Members $aaaUsuario
    }
}
0,5,10 | ForEach-Object {
    Get-ADUser "usuario$_" -Properties LockedOut,PasswordExpired,MemberOf |
        Select-Object SamAccountName,Enabled,LockedOut,PasswordExpired,MemberOf
}
Write-Host "Verificar Dial-in y políticas NPS siguiendo el manual."
