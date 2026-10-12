resource "azurerm_sentinel_alert_rule_scheduled" "rdp_bruteforce" {
  name                       = "det-002-rdp-bruteforce"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  display_name               = "RDP Brute Force Attempt"
  severity                   = "Medium"
  description                = "Detects repeated failed RDP logon attempts (Event 4625) from the same source within 5 minutes. Maps to MITRE ATT&CK T1110 (Brute Force)."

  query = <<-KQL
    SecurityEvent
    | where EventID == 4625
    | where LogonType == 10 or LogonType == 3
    | summarize FailedAttempts = count(), Accounts = make_set(TargetUserName) by IpAddress, Computer, bin(TimeGenerated, 5m)
    | where FailedAttempts >= 10
  KQL

  query_frequency   = "PT5M"
  query_period      = "PT5M"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0
  tactics           = ["CredentialAccess"]
}