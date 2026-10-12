resource "azurerm_sentinel_alert_rule_scheduled" "new_service_installed" {
  name                       = "det-005-new-service-installed"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  display_name               = "New Service Installed"
  severity                   = "Medium"
  description                = "Detects installation of a new Windows service (Event 7045), a common persistence and privilege escalation technique (e.g. unquoted service path abuse). Maps to MITRE ATT&CK T1543.003."

  query = <<-KQL
    Event
    | where Source == "Service Control Manager"
    | where EventID == 7045
    | project TimeGenerated, Computer, RenderedDescription
  KQL

  query_frequency   = "PT10M"
  query_period      = "PT10M"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0
  tactics           = ["Persistence", "PrivilegeEscalation"]
}