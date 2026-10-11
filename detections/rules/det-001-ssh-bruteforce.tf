resource "azurerm_sentinel_alert_rule_scheduled" "ssh_bruteforce" {
  name                       = "det-001-ssh-bruteforce"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  display_name               = "SSH Brute Force Attempt"
  severity                   = "Medium"
  description                = "Detects repeated failed SSH logins from a single source within 5 minutes. Maps to MITRE ATT&CK T1110 (Brute Force)."

  query = <<-KQL
    Syslog
    | where SyslogMessage has "Failed password"
    | extend SourceIP = extract(@"from (\d+\.\d+\.\d+\.\d+)", 1, SyslogMessage)
    | where isnotempty(SourceIP)
    | summarize FailedAttempts = count() by SourceIP, Computer, bin(TimeGenerated, 5m)
    | where FailedAttempts >= 10
  KQL

  query_frequency   = "PT5M"
  query_period      = "PT5M"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0
  tactics           = ["CredentialAccess"]

  incident_configuration {
    create_incident_enabled = true
    grouping {
      enabled                 = true
      lookback_duration       = "PT5H"
      reopen_closed_incidents = false
      entity_matching_method  = "Selected"
      group_by_entities       = ["Host"]
    }
  }
}