#requires -RunAsAdministrator
# Aplica clientes, regla UDP y auditoría; no crea las políticas NPS.
$ErrorActionPreference = "Stop"
Import-Module NPS
Import-Module ActiveDirectory
if ((Get-ADDomain).DNSRoot -ne "seguridad.test") {
    throw "El dominio esperado es seguridad.test."
}
$aaaSegura = Read-Host "Clave RADIUS privada común a los NAS y NPS" -AsSecureString
$aaaClave = [System.Net.NetworkCredential]::new("",$aaaSegura).Password
try {
    foreach ($aaaCliente in @(
        @{Name="R1-AAA"; Address="10.24.96.1"}
        @{Name="SW1-AAA"; Address="10.24.96.2"}
    )) {
        $aaaParametros = @{
            Name=$aaaCliente.Name
            Address=$aaaCliente.Address
            SharedSecret=$aaaClave
            AuthAttributeRequired=$true
        }
        if (Get-NpsRadiusClient -Name $aaaCliente.Name -ErrorAction SilentlyContinue) {
            Set-NpsRadiusClient @aaaParametros -Enabled $true | Out-Null
        } else {
            New-NpsRadiusClient @aaaParametros | Out-Null
        }
    }
} finally {
    Remove-Variable aaaClave,aaaSegura,aaaParametros -ErrorAction SilentlyContinue
}
$aaaRegla = Get-NetFirewallRule -Name "LAB-AAA-RADIUS" -ErrorAction SilentlyContinue
if ($aaaRegla) {
    $aaaRegla | Set-NetFirewallRule -Enabled True -Direction Inbound -Action Allow -Profile Any
    $aaaRegla | Get-NetFirewallAddressFilter |
        Set-NetFirewallAddressFilter -LocalAddress 10.24.96.138 -RemoteAddress 10.24.96.1,10.24.96.2
    $aaaRegla | Get-NetFirewallPortFilter |
        Set-NetFirewallPortFilter -Protocol UDP -LocalPort 1812,1813
} else {
    $aaaFirewall = @{
        Name="LAB-AAA-RADIUS"
        DisplayName="LAB AAA RADIUS"
        Direction="Inbound"
        Action="Allow"
        Protocol="UDP"
        LocalPort=@(1812,1813)
        LocalAddress="10.24.96.138"
        RemoteAddress=@("10.24.96.1","10.24.96.2")
        Profile="Any"
    }
    New-NetFirewallRule @aaaFirewall | Out-Null
}
$aaaComputadora = Get-ADComputer -Identity $env:COMPUTERNAME
Add-ADGroupMember -Identity "RAS and IAS Servers" -Members $aaaComputadora
auditpol /set /subcategory:"Network Policy Server" /success:enable /failure:enable
if ($LASTEXITCODE -ne 0) { throw "No se pudo configurar la auditoría NPS." }
Restart-Service IAS
Get-NpsRadiusClient | Format-Table Name,Address,Enabled
Write-Host "Introducir esta misma clave de forma privada en cada NAS; revisar las políticas en nps.msc."
