resource "azurerm_sentinel_alert_rule_scheduled" "web_shell" {
  name                       = "det-007-web-shell"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  display_name               = "Possible Web Shell — Apache Spawning Shell"
  severity                   = "High"
  description                = "Detects the Apache process spawning a shell or interpreter, a strong indicator of a web shell following file upload exploitation on DVWA. Maps to MITRE ATT&CK T1505.003."

  query = <<-KQL
    Syslog
    | where Facility == "local6" and SyslogMessage has 'key="exec"'
    | where SyslogMessage has "www-data"
    | where SyslogMessage has_any ("/bin/sh", "/bin/bash", "nc ", "python", "perl")
  KQL

  query_frequency   = "PT5M"
  query_period      = "PT5M"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0
  tactics           = ["InitialAccess", "Execution"]
}