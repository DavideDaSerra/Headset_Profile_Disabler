# Headset_Profile_Disabler
Script to disable the headset profile on a windows machine for a specific bluetooth device

# Scope
I found an issue using some sony headphones (Sony WH-CH510) unmanageable via Sony app that, when used in headset mode
pick up ambient audio echoing it to the earpice, making listening quite annoying.

With this script you can disable the headset mode for the devicem forcing it to run as A2DP disabling the embedded microphone and tedious echoing effect

# Usage
First you have to enable unsigned code (this script) running the following command in an administrative powershell

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

Then you can invoke the script as:
## Disable headset profile for device with specific name (Default disable)
.\hs_manage.ps1 -HeadsetName "WH-CH510"

## Enable headset mode on all devices
.\hs_manage.ps1 -Enable

## Enable headset mode on specific devices
.\hs_manage.ps1 -HeadsetName "Sony" -Enable

## List audio devices
.\hs_manage.ps1 -ListOnly

## The default behaviour 
If called with no parameters the default behaviouris to deactivate the headset profile for the Sony WH-CH510 headset
