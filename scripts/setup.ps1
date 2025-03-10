# Install Python
Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.11.4/python-3.11.4-amd64.exe" -OutFile "python_installer.exe"
Start-Process -FilePath "python_installer.exe" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait

