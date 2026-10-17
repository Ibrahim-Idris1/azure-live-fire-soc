# Vulnerabilities

The following Linux endpoint services are intentionally vulnerable for authorized training exercises. Commands should be run only from a network path permitted by the range configuration.

| Endpoint | Vulnerability | Attack surface | Difficulty | Detection | Verification |
|----------|---------------|----------------|------------|-----------|--------------|
| Linux | DVWA (Damn Vulnerable Web Application) | SQL injection, file upload to RCE, XSS | Medium | DET-007 | `curl -I http://<linux-public-ip>/DVWA/` |
| Linux | Anonymous Samba share at `/srv/samba/public` | No authentication required; world-writable share | Easy | Enumeration target; no dedicated detection rule yet | `smbclient -N -L //<linux-host>` |

The current Terraform NSG allows inbound HTTP but does not allow inbound SMB on TCP port 445. Run Samba verification from the VM or another explicitly permitted network path; do not open SMB broadly to the internet.