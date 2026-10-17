#!/bin/bash
set -e

# Wait for any other apt process to finish (handles unattended-upgrades collisions)
while sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
  sleep 5
done
while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
  sleep 5
done

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

# --- Vuln 3: DVWA web application ---
apt-get update -y
apt-get install -y apache2 php php-mysqli php-gd mariadb-server

systemctl enable --now mariadb
mysql -e "CREATE DATABASE IF NOT EXISTS dvwa;"
mysql -e "CREATE USER IF NOT EXISTS 'dvwa'@'localhost' IDENTIFIED BY 'p@ssw0rd';"
mysql -e "GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

if [ ! -d /var/www/html/DVWA ]; then
  git clone https://github.com/digininja/DVWA.git /var/www/html/DVWA
fi

cp /var/www/html/DVWA/config/config.inc.php.dist /var/www/html/DVWA/config/config.inc.php
sed -i "s/\$_DVWA\[ 'db_password' \] = '';/\$_DVWA[ 'db_password' ] = 'p@ssw0rd';/" /var/www/html/DVWA/config/config.inc.php

chown -R www-data:www-data /var/www/html/DVWA
chmod -R 755 /var/www/html/DVWA/hackable/uploads
systemctl enable --now apache2
systemctl restart apache2

# --- Vuln 4: anonymous Samba share ---
apt-get install -y samba
mkdir -p /srv/samba/public
chmod 777 /srv/samba/public
if ! grep -q "\[public\]" /etc/samba/smb.conf; then
cat >> /etc/samba/smb.conf << 'SMBCONF'

[public]
   path = /srv/samba/public
   browsable = yes
   writable = yes
   guest ok = yes
   read only = no
SMBCONF
fi
systemctl restart smbd

# --- Audit watches (tripwires), added only once each ---
RULES_FILE="/etc/audit/rules.d/livefire.rules"
if ! grep -q "vuln-cleanup-script" "$RULES_FILE"; then
  printf '\n-w /opt/scripts/cleanup.sh -p wa -k vuln-cleanup-script\n-w /etc/cron.d/cleanup -p wa -k vuln-cleanup-script\n' >> "$RULES_FILE"
fi
if ! grep -q "vuln-dvwa" "$RULES_FILE"; then
  printf '\n-w /var/www/html/DVWA -p wa -k vuln-dvwa\n-w /srv/samba/public -p wa -k vuln-samba-share\n' >> "$RULES_FILE"
fi

augenrules --load

echo "Vulnerabilities planted: $(date)" >> /var/log/livefire-setup.log