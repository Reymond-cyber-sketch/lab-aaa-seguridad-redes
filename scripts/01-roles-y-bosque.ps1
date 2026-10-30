#requires -RunAsAdministrator
param([switch]$CrearBosque)
$ErrorActionPreference = "Stop"
Install-WindowsFeature AD-Domain-Services,DNS,NPAS -IncludeManagementTools
if ($CrearBosque) {
    $aaaEquipo = Get-CimInstance Win32_ComputerSystem
    if ($aaaEquipo.PartOfDomain) {
        throw "El servidor ya pertenece a un dominio. Validar el montaje existente."
    }
    Install-ADDSForest -DomainName "seguridad.test" -DomainNetbiosName "SEGURIDAD" -InstallDNS -CreateDnsDelegation:$false -Force
}
