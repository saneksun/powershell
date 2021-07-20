<#Copy the latest Backup SQL database files to network storage
#>

#Get dates 

$today = get-date -format yyyyMMMdd
$timestamp = get-date -format g
@("*******************************************************") + (Get-Content "c:\DB_script_logs\BackupSQLdbs.log") | Set-Content "c:\DB_script_logs\BackupSQLdbs.log" -Encoding UTF8
$username = 'username'
$File =  "C:\DB_scripts\pswd.txt"
$server="\\X.X.X.X\C$\DB_backup"
# Check for valid password/cpnnection establishing
try {$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, (Get-Content $File | ConvertTo-SecureString )}
Catch {        
           $ErrorMessage = $Error[0].Exception.Message       
          @("$timestamp New-PSDrive Error: $ErrorMessage") + (Get-Content "c:\DB_script_logs\BackupSQLdbs.log") | Set-Content "c:\DB_script_logs\BackupSQLdbs.log" -Encoding UTF8
           
       }
# Mount the remote disk as a network drive:
try {New-PSDrive -Name "X" -PSProvider "FileSystem" -Root $server -Persist -Credential $cred}

# Checking for disk mounting errors
Catch {        
           $ErrorMessage = $Error[0].Exception.Message       
          @("$timestamp New-PSDrive Error: $ErrorMessage") + (Get-Content "c:\DB_script_logs\BackupSQLdbs.log") | Set-Content "c:\DB_script_logs\BackupSQLdbs.log" -Encoding UTF8
       }
      

#Get list of files created today:

$filelist  = Get-ChildItem c:\DB_backup -filter *.bak | Where {$_.LastWriteTime -gt (get-date).Date} | select -expand name 

if ($filelist -eq $null) {  # If no new DB backups - write log and sent logfile
    @("$timestamp No new DB backup found") + (Get-Content "c:\DB_script_logs\BackupSQLdbs.log") | Set-Content "c:\DB_script_logs\BackupSQLdbs.log" -Encoding UTF8
     Copy-Item c:\DB_script_logs\BackupSQLdbs.log -Destination X:\BackupSQLdbs.log
}
else {
   @("$timestamp New file(s) found: $filelist") + (Get-Content "c:\DB_script_logs\BackupSQLdbs.log") | Set-Content "c:\DB_script_logs\BackupSQLdbs.log" -Encoding UTF8
    foreach ($db in $filelist) {
       #Create the file name that will be saved on remote machine (without date)
       $destdb = $db -replace $today,''  
       @("$timestamp $destdb starting to copy to $server") + (Get-Content "c:\DB_script_logs\BackupSQLdbs.log") | Set-Content "c:\DB_script_logs\BackupSQLdbs.log" -Encoding UTF8  
       try {Copy-Item c:\DB_backup\$db -Destination X:\$destdb}
       # Checking for copy errors
       Catch {        
           $ErrorMessage = $Error[0].Exception.Message
           @("$timestamp Copy-Item Error: $ErrorMessage") + (Get-Content "c:\DB_script_logs\BackupSQLdbs.log") | Set-Content "c:\DB_script_logs\BackupSQLdbs.log" -Encoding UTF8 
       }         
    #Copy log file to remote PC
    Copy-Item c:\DB_script_logs\BackupSQLdbs.log -Destination X:\BackupSQLdbs.log
  }
}
# Dismount the network disk

Remove-PSDrive -Name X
