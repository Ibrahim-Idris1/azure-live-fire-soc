resource "azurerm_sentinel_alert_rule_scheduled" "ssh_bruteforce" {
  name                       = "det-001-ssh-bruteforce"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  display_name               = "SSH Brute Force Attempt"
  severity                   = "Medium"
  description                = "Groups failed SSH logins into 10-minute KQL bins while evaluating a five-minute lookback. Maps to MITRE ATT&CK T1110 (Brute Force)."

  query = <<-KQL
    Syslog
    | where SyslogMessage has "Failed password"
    | extend SourceIP = extract(@"from (\d+\.\d+\.\d+\.\d+)", 1, SyslogMessage)
    | where isnotempty(SourceIP)
    | summarize FailedAttempts = count() by SourceIP, Computer, bin(TimeGenerated, 10m)
    | where FailedAttempts >= 10
  KQL

  query_frequency   = "PT5M"
  query_period      = "PT5M"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0
  tactics           = ["CredentialAccess"]
}
