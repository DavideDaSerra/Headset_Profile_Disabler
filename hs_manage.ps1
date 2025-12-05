## Script to disable headset mode on windows for a bluetooth device
## DDS90 - 2025-12-05

param(
    [string]$HeadsetName = "WH-CH510",
    [switch]$Enable = $false,
    [switch]$ListOnly = $false
)

# Richiedi privilegi amministratore se non presenti
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting admin privileges..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -HeadsetName `"$HeadsetName`" $(if($Enable){'-Enable'})" -Verb RunAs
    exit
}


Write-Host "=== Handling Headset Bluetooth ===" -ForegroundColor Cyan
Write-Host ""

if($ListOnly){
    Write-Host "These are the audio devices I found:" -ForegroundColor Yellow
    Get-PnpDevice -Class AudioEndpoint | Where-Object {$_.Status -ne "Unknown"} | Format-Table FriendlyName, Status -AutoSize
    Write-Host ""
    pause
    exit
}


# Cerca dispositivi headset/microfono Bluetooth
$dispositivi = Get-PnpDevice -Class AudioEndpoint | Where-Object {
    $_.FriendlyName -like "*$HeadsetName*" -and 
    ($_.FriendlyName -like "*Headset*" -or 
     $_.FriendlyName -like "*Hands-Free*" -or
     $_.FriendlyName -like "*Microphone*") -and
     $_.Status -ne "Unknown"
}

if ($dispositivi.Count -eq 0) {
    Write-Host "No device headset found with filter: $HeadsetName" -ForegroundColor Red
    Write-Host ""
    exit
}

Write-Host "Devices found:" -ForegroundColor Green
$dispositivi | Format-Table FriendlyName, Status, InstanceId -AutoSize
Write-Host ""

foreach ($dev in $dispositivi) {
    if ($Enable) {
        Write-Host "Enabling: $($dev.FriendlyName)..." -ForegroundColor Green
        Get-PnpDevice -InstanceId $dev.InstanceId | Select-Object Status,ProblemCode
        Enable-PnpDevice -InstanceId $dev.InstanceId -Confirm:$false -ErrorAction Stop
    } else {
        Write-Host "Disabling: $($dev.FriendlyName)..." -ForegroundColor Yellow
        Get-PnpDevice -InstanceId $dev.InstanceId | Select-Object Status,ProblemCode
        Disable-PnpDevice -InstanceId $dev.InstanceId -Confirm:$false -ErrorAction Stop
    }
}

Write-Host ""
Write-Host "Operration Completed!" -ForegroundColor Green
Start-Sleep -Seconds 2
