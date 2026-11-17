$ErrorActionPreference = "Stop"

# --- Lab account with a unique, unshared password ---
$pass = ConvertTo-SecureString (([guid]::NewGuid().ToString("N")) + "aA1!") -AsPlainText -Force
$user = Get-LocalUser -Name "svc_backup" -ErrorAction SilentlyContinue
if (-not $user) {
  New-LocalUser -Name "svc_backup" -Password $pass -PasswordNeverExpires
  Add-LocalGroupMember -Group "Remote Desktop Users" -Member "svc_backup"
} else {
  Set-LocalUser -Name "svc_backup" -Password $pass
}

# --- Vuln 1: unquoted service path in a writable folder ---
New-Item -ItemType Directory -Path "C:\VulnApp" -Force | Out-Null
Copy-Item "$env:WINDIR\System32\cmd.exe" "C:\VulnApp\service.exe" -Force
icacls "C:\VulnApp" /grant "Users:(OI)(CI)F" | Out-Null

sc.exe create vulnsvc binpath= "C:\VulnApp\service.exe /k" start= demand | Out-Null
sc.exe failure vulnsvc reset= 0 actions= restart/5000 | Out-Null

# --- Tripwire: watch the vuln folder specifically via Sysmon is config-level;
#     here we just log that provisioning ran ---
"Vulnerabilities planted: $(Get-Date)" | Out-File -Append C:\livefire-setup.log