
Version: 1.0.1 16-01-2018<br>
Developed by: Attilio Borri<br>

BackUP_ESXI.ps1 is a script that can be called from scheduled task to backup the configuration of a ESXi Server.

## Requirements

- [PackageManagement PowerShell Modules](https://www.microsoft.com/en-us/download/details.aspx?id=51451)
- VMWare.PowerCLI

## Scheduled Task

Add a basic task and use the following settings:

**Start a program**: powershell <br />
**Add arguments**: -command "& '<script_path>\BackUP_ESXI.ps1' '<esxi_ipaddress>' '<esxi_username>' '<esxi_password>' '<network_share_path>' '<network_share_username>' '<network_share_password>'"