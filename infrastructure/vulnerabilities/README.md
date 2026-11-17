# Vulnerabilities

These configurations are intentionally insecure and are for authorized training in an isolated, dedicated lab only. Vulnerability planting is disabled by default. The current Terraform network rules allow inbound HTTP from any source; restrict access before enabling vulnerable web services. Never deploy this configuration in production. Account and database credentials are generated during provisioning; the scripts do not set shared fixed passwords.

| Endpoint | Vulnerability | Attack surface | Difficulty | Detection | Verification |
|----------|---------------|----------------|------------|-----------|--------------|
| Linux | DVWA (Damn Vulnerable Web Application) | SQL injection, file upload to RCE, XSS | Medium | DET-007 | `curl -I http://<linux-public-ip>/DVWA/` |
| Linux | Anonymous Samba share at `/srv/samba/public` | No authentication required; world-writable share | Easy | Enumeration target; no dedicated detection rule yet | `smbclient -N -L //<linux-host>` |
| Windows | Writable service directory | `C:\VulnApp` and the `vulnsvc` service | Medium | DET-005 | Review the service and directory configuration on the lab VM |

The current Terraform NSG allows inbound HTTP but does not allow inbound SMB on TCP port 445. Run Samba verification from the VM or another explicitly permitted network path; do not open SMB broadly to the internet.