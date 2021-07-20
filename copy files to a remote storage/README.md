The script is checking a folder for the latest created files (SQL *.bak backup files), copying them to a remote network storage, 
adding logs to the local and remote (overwrite it) log files.

Script uses login and password for the remote access authentication. Password is stored as a hash in pswd.txt. 
To convert a plain-text into a secure string the following command could be used:

>  "YOUR_PASSWORD" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File "C:\pswd.txt" 
