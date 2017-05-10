New-Item -ItemType Directory -Path 'c:\explorerplusplus'
Invoke-WebRequest -Uri 'https://explorerplusplus.com/software/explorer++_1.3.5_x64.zip' -UseBasicParsing -OutFile 'C:\explorerplusplus\explorer++_1.3.5_x64.zip'
Expand-Archive -Path C:\explorerplusplus\explorer++_1.3.5_x64.zip -DestinationPath c:\explorerplusplus 
New-Alias epp 'C:\explorerplusplus\Explorer++.exe'
epp