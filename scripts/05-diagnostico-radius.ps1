#requires -RunAsAdministrator
param([ValidateSet("10.24.96.1","10.24.96.2")][string]$Cliente="10.24.96.2")
# Captura de contadores de NIC; no almacena contenido de paquetes.
$ErrorActionPreference = "Stop"
$aaaFiltro = "AAA-LAB-" + [Guid]::NewGuid().ToString("N").Substring(0,8)
Get-Service IAS
Get-NetUDPEndpoint -LocalPort 1812,1813 | Format-Table LocalAddress,LocalPort
$aaaDesde = Get-Date
pktmon filter add $aaaFiltro -i $Cliente -t UDP -p 1812
if ($LASTEXITCODE -ne 0) { throw "No se pudo añadir el filtro de diagnóstico." }
pktmon start --capture --counters-only --comp nics
if ($LASTEXITCODE -ne 0) {
    pktmon filter remove $aaaFiltro
    throw "La captura no inició. Revisar el mensaje de pktmon."
}
try {
    Read-Host "Realiza UN intento por consola en el NAS; vuelve y pulsa Enter"
    pktmon counters
} finally {
    pktmon stop
    pktmon filter remove $aaaFiltro
}
$aaaEventos = @(Get-WinEvent -FilterHashtable @(
    @{LogName="System"; ProviderName="NPS"; StartTime=$aaaDesde}
    @{LogName="Security"; Id=6272,6273,6274; StartTime=$aaaDesde}
) -ErrorAction SilentlyContinue |
    Where-Object { $_.Message -match [regex]::Escape($Cliente) } |
    Sort-Object TimeCreated -Descending | Select-Object -First 5)
if ($aaaEventos.Count) {
    $aaaEventos | Format-List TimeCreated,LogName,Id,Message
} else {
    Write-Host "No hay eventos de NPS para el intento. Revisar contadores y filtros del servidor."
}
