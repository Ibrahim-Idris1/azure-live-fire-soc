# Lessons Learned

- **APT lock collisions during provisioning:** `unattended-upgrades` can hold `/var/lib/apt/lists/lock` while the provisioning script starts its own `apt-get` operations. Provisioning now waits for that lock to clear before proceeding.
- **Auditd rules file newline handling:** Appending rules without guarding against a missing trailing newline can concatenate directives and corrupt the auditd rules file. The correction was to rewrite the managed rules file idempotently with `tee` instead of appending.