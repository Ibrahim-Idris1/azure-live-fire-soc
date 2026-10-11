$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Path C:\Sysmon -Force | Out-Null
Invoke-WebRequest -UseBasicParsing "https://download.sysinternals.com/files/Sysmon.zip" -OutFile C:\Sysmon\Sysmon.zip
Expand-Archive C:\Sysmon\Sysmon.zip C:\Sysmon -Force
Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -OutFile C:\Sysmon\sysmonconfig.xml
if (Get-Service Sysmon64 -ErrorAction SilentlyContinue) {
  C:\Sysmon\Sysmon64.exe -c C:\Sysmon\sysmonconfig.xml
} else {
  C:\Sysmon\Sysmon64.exe -accepteula -i C:\Sysmon\sysmonconfig.xml
}