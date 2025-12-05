## Script to disable headset mode on windows for a bluetooth device
## DDS90 - 2025-12-05

param(
    [string]$HeadsetName = "WH-CH510",
    [switch]$Enable = $false,
    [switch]$ListOnly = $false
)

# Ask admin privileges
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


# Find headset/mic Bluetooth devices
$devices = Get-PnpDevice -Class AudioEndpoint | Where-Object {
    $_.FriendlyName -like "*$HeadsetName*" -and 
    ($_.FriendlyName -like "*Headset*" -or 
     $_.FriendlyName -like "*Hands-Free*" -or
     $_.FriendlyName -like "*Microphone*") -and
     $_.Status -ne "Unknown"
}

if ($devices.Count -eq 0) {
    Write-Host "No device headset found with filter: $HeadsetName" -ForegroundColor Red
    Write-Host ""
    exit
}

Write-Host "Devices found:" -ForegroundColor Green
$devices | Format-Table FriendlyName, Status, InstanceId -AutoSize
Write-Host ""

foreach ($dev in $devices) {
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
Write-Host "Operation Completed!" -ForegroundColor Green
Start-Sleep -Seconds 2
