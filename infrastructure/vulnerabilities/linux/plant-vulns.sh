#!/bin/bash
set -e

# --- Vuln 1: weak-password low-priv account ---
id backupuser &>/dev/null || useradd -m -s /bin/bash backupuser
echo "backupuser:Summer2024!" | chpasswd

# --- Vuln 2: world-writable root cron job ---
mkdir -p /opt/scripts
cat > /opt/scripts/cleanup.sh << 'SCRIPT'
#!/bin/bash
rm -rf /tmp/old-logs/* 2>/dev/null
SCRIPT
chmod 777 /opt/scripts/cleanup.sh
echo "* * * * * root /opt/scripts/cleanup.sh" > /etc/cron.d/cleanup
chmod 644 /etc/cron.d/cleanup

# --- Vuln-specific audit watches (tripwires), added only once ---
RULES_FILE="/etc/audit/rules.d/livefire.rules"
if ! grep -q "vuln-cleanup-script" "$RULES_FILE"; then
  printf '\n-w /opt/scripts/cleanup.sh -p wa -k vuln-cleanup-script\n-w /etc/cron.d/cleanup -p wa -k vuln-cleanup-script\n' >> "$RULES_FILE"
fi

augenrules --load

echo "Vulnerabilities planted: $(date)" >> /var/log/livefire-setup.log