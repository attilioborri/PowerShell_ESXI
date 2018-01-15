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

$LocalTempFolder = "C:\ESXiBackUP"
if(!(Test-Path $LocalTempFolder)){
    New-Item -ItemType Directory -Force -Path $LocalTempFolder;
}
$BKPESXI_EnableDateRename = 1;
$BKPESXI_MAXBKP = 2; 

$s=Get-Date;
$BackUP_ESXI_Temp_File = New-TemporaryFile;
$BackUP_ESXI_Host = $args[0];
$BackUP_ESXI_CountParameters = $args.Length;
$BackUP_ESXI_executebackup = 0;
if($BackUP_ESXI_CountParameters.Equals(2)){
    #echo 'CustomLogn'
    $BackUP_ESXI_DefaultPath = $args[1];
    $BackUP_ESXI_Server = Connect-VIServer -Server $BackUP_ESXI_Host;
    $BackUP_ESXI_executebackup = 1;
}elseif($BackUP_ESXI_CountParameters.Equals(4)){
    #echo 'AutomaticLogin-LocalFolder'
    $BackUP_ESXI_Username = $args[1];
    $BackUP_ESXI_Password = $args[2];
    $BackUP_ESXI_DefaultPath = $args[3];
    $BackUP_ESXI_Server = Connect-VIServer -Server $BackUP_ESXI_Host -User $BackUP_ESXI_Username -Password $BackUP_ESXI_Password;
    $BackUP_ESXI_executebackup = 1;
}elseif($BackUP_ESXI_CountParameters.Equals(6)){
    #echo 'AutomaticLogin-NetWorkDrive'
    $BackUP_ESXI_Username = $args[1];
    $BackUP_ESXI_Password = $args[2];
    $BackUP_ESXI_DefaultPath = $args[3];
    $BackUP_ESXI_Server = Connect-VIServer -Server $BackUP_ESXI_Host -User $BackUP_ESXI_Username -Password $BackUP_ESXI_Password;
    $BackUP_ESXI_executebackup = 1;
    $BackUP_ESXI_NetUsername = $args[4];
    $BackUP_EDCI_NetPassword = $args[5];
}else{
    $BackUP_ESXI_executebackup = 0;
}
if($BackUP_ESXI_executebackup.Equals(1)){
   if($BackUP_ESXI_DefaultPath.ToString().Contains('\\') -and $BackUP_ESXI_CountParameters.Equals(6)){
        #network drive
        
        #New-Item -ItemType directory -Path $LocalTempFolder
        
        Get-VMHostFirmware -VMHost $BackUP_ESXI_Host -BackupConfiguration -DestinationPath $LocalTempFolder;
        Disconnect-VIServer -Server $BackUP_ESXI_Server -confirm:$false;
        net use $BackUP_ESXI_DefaultPath /user:$BackUP_ESXI_NetUsername $BackUP_EDCI_NetPassword;
        if($BKPESXI_EnableDateRename.Equals(1)){
            $files = Get-ChildItem $LocalTempFolder;
            for($i=0;$i -lt $files.Count; $i++){
                if(Test-Path $files[$i].FullName){
                    $GetDate = Get-Date -format "yyyy/MM/dd_HHmmss";
                    $newfile = "$($LocalTempFolder)\$($files[$i].BaseName) $($GetDate)$($files[$i].Extension)".Replace(" ","_").Replace("/","-");

                    #echo $newfile;
                    #echo $($files[$i].FullName);

                    #echo "Move-Item -Path $($files[$i].FullName) -Destination $newfile";

                    Move-Item -Path "$($files[$i].FullName)" -Destination "$newfile";
                    Move-Item $newfile $BackUP_ESXI_DefaultPath;
                    #Remove-Item $newfile;
                }
            }
        }
    }else{
        #local folder
        Get-VMHostFirmware -VMHost $BackUP_ESXI_Host -BackupConfiguration -DestinationPath $BackUP_ESXI_DefaultPath;
        Disconnect-VIServer -Server $BackUP_ESXI_Server -confirm:$false;
    }

    


}else{
    echo '';
    echo 'Wrong number of parameters. Following modes are allowed:';
    echo '';
    echo 'Automatic Login Local Folder:';
    echo '      BackUP_ESXI.ps1 <ip_address> <username> <password> <default_path>';
    echo '';
    echo 'Automatic Login Network Drive:';
    echo '      BackUP_ESXI.ps1 <ip_address> <username> <password> <network path> <net_username> <net_password>';
    echo '';
    echo 'Custom Login';
    echo '      BackUP_ESXI.ps1 <ip_address> <default_path>';
}




#Delete Temp File before end of the script
#Remove-Item $BackUP_ESXI_Temp_File -Force;


#Remove Old Remote Files if MAX!=0
if($BKPESXI_MAXBKP.Equals(0)){
    #do nothing
}else{
#delete old backups
#$cnttotalfiles = $(Get-ChildItem -filter "$BackUP_ESXI_DefaultPath\*.tgz").Count;
$filestoremove = Get-ChildItem -path "$BackUP_ESXI_DefaultPath\*.tgz" | sort LastWriteTime
$cnt = $filestoremove.Count;
    for($i=0;$i -lt $cnt; $i++){
    #for($i=$filestoremove.Count;$i -lt 0; $i--){
        if($cnt -gt $BKPESXI_MAXBKP){
            Remove-Item $filestoremove[$i];
            $cnt--;
        }
    }
}


$e=Get-Date; 
#echo ($e - $s)
