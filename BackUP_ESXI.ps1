# ESXI Configuration BackUP PowerShell Script
#
# Usage example:
# Automatic Login:  BackUP_ESXI.ps1 <ip_address> <username> <password> <default_path>
# Custom Login:     BackUP_ESXI.ps1 <ip_address> <default_path>
#
# If the script doesn't work, install the following module from Admin account
# https://www.powershellgallery.com/packages/VMware.PowerCLI/6.5.4.7155375
# 
# Install-Module -Name VMware.PowerCLI

$BackUP_ESXI_Temp_File = New-TemporaryFile
$BackUP_ESXI_Host = $args[0]
$BackUP_ESXI_CountParameters = $args.Length
$BackUP_ESXI_executebackup = 0
if($BackUP_ESXI_CountParameters.Equals(2)){
    #echo 'CustomLogn'
    $BackUP_ESXI_DefaultPath = $args[1]
    $BackUP_ESXI_Server = Connect-VIServer -Server $BackUP_ESXI_Host
    $BackUP_ESXI_executebackup = 1
}elseif($BackUP_ESXI_CountParameters.Equals(4)){
    #echo 'AutomaticLogin'
    $BackUP_ESXI_Username = $args[1]
    $BackUP_ESXI_Password = $args[2]
    $BackUP_ESXI_DefaultPath = $args[3]
    $BackUP_ESXI_Server = Connect-VIServer -Server $BackUP_ESXI_Host -User $BackUP_ESXI_Username -Password $BackUP_ESXI_Password
    $BackUP_ESXI_executebackup = 1
}else{
    $BackUP_ESXI_executebackup = 0
}
if($BackUP_ESXI_executebackup.Equals(1)){
    Get-VMHostFirmware -VMHost $BackUP_ESXI_Host -BackupConfiguration -DestinationPath $BackUP_ESXI_Temp_File.FullName
    Disconnect-VIServer -Server $BackUP_ESXI_Server -confirm:$false
}else{
    echo ''
    echo 'Wrong number of parameters. Following modes are allowed:'
    echo ''
    echo 'Automatic Login:'
    echo '      BackUP_ESXI.ps1 <ip_address> <username> <password> <default_path>'
    echo ''
    echo 'Custom Login'
    echo '      BackUP_ESXI.ps1 <ip_address> <default_path>'
}