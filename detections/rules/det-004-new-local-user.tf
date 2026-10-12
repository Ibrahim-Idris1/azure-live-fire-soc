resource "azurerm_sentinel_alert_rule_scheduled" "new_local_user" {
  name                       = "det-004-new-local-user"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  display_name               = "New Local User Account Created"
  severity                   = "Medium"
  description                = "Detects creation of a new local user account on Windows (Event 4720) or Linux (auditd identity key). Maps to MITRE ATT&CK T1136 (Create Account)."

  query = <<-KQL
    let windows_events = SecurityEvent
      | where EventID == 4720
      | project TimeGenerated, Computer, Account = TargetUserName, Source = "Windows";
    let linux_events = Syslog
      | where Facility == "local6" and SyslogMessage has 'key="identity"' and SyslogMessage has "useradd"
      | project TimeGenerated, Computer, Account = extract(@"name=\x22([^\x22]+)", 1, SyslogMessage), Source = "Linux";
    windows_events
    | union linux_events
  KQL

  query_frequency   = "PT10M"
  query_period      = "PT10M"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0
  tactics           = ["Persistence", "PrivilegeEscalation"]
}