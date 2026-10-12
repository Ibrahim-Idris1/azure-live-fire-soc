resource "azurerm_sentinel_alert_rule_scheduled" "persistence_cron" {
  name                       = "det-006-persistence-cron"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  display_name               = "Linux Persistence via Cron"
  severity                   = "Medium"
  description                = "Detects creation or modification of cron jobs, cron.d entries, or related persistence files via auditd watches. Maps to MITRE ATT&CK T1053.003 (Scheduled Task/Job: Cron)."

  query = <<-KQL
    Syslog
    | where Facility == "local6"
    | where SyslogMessage has 'key="persistence"'
    | project TimeGenerated, Computer, SyslogMessage
  KQL

  query_frequency   = "PT10M"
  query_period      = "PT10M"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0
  tactics           = ["Persistence"]
}