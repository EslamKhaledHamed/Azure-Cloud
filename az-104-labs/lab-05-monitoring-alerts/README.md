# AZ-104 Lab 05 — Monitoring and Alerts

## What This Covers
Setting up Azure Monitor, connecting resources to a Log Analytics workspace, writing KQL queries to analyze logs, creating metric alerts with action groups, and building dashboards.

## Tasks

- Create a Log Analytics Workspace
- Enable diagnostic settings on a VM to send logs and metrics
- Write KQL queries to analyze data
- Create a metric alert for high CPU usage
- Create an action group that sends email notifications
- Pin metrics to an Azure dashboard
- Set up Application Insights on a web app

## CLI Commands

```bash
# Create Log Analytics Workspace
az monitor log-analytics workspace create \
  --resource-group MyRG \
  --workspace-name MyWorkspace \
  --location eastus

# Get workspace customer ID
az monitor log-analytics workspace show \
  --resource-group MyRG --workspace-name MyWorkspace \
  --query customerId --output tsv

# Create action group (email notification)
az monitor action-group create \
  --resource-group MyRG --name MyActionGroup --short-name MyAG \
  --email-receiver name=Admin email-address=admin@example.com

# Create metric alert — fires when CPU exceeds 80% for 5 minutes
az monitor metrics alert create \
  --resource-group MyRG --name HighCPUAlert \
  --scopes <vm-resource-id> \
  --condition "avg Percentage CPU > 80" \
  --window-size 5m --evaluation-frequency 1m \
  --action MyActionGroup --severity 2

# Query logs from CLI
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "Heartbeat | summarize count() by Computer" \
  --output table
```

## KQL Queries I Practiced

Check which VMs stopped sending heartbeats:
```kusto
Heartbeat
| summarize LastHeartbeat = max(TimeGenerated) by Computer
| where LastHeartbeat < ago(5m)
```

Average CPU over time per VM:
```kusto
Perf
| where ObjectName == "Processor"
| where CounterName == "% Processor Time"
| summarize avg(CounterValue) by Computer, bin(TimeGenerated, 5m)
| render timechart
```

Recent errors from Windows Event Log:
```kusto
Event
| where EventLevelName == "Error"
| project TimeGenerated, Computer, EventLog, RenderedDescription
| order by TimeGenerated desc
```

## Key Concepts
**Metrics vs Logs**
- Metrics = numbers over time (CPU %, memory, requests per second). Retained 93 days. Near real-time
- Logs = text events stored in Log Analytics. Retention configurable 30-730 days. Queried with KQL

**Alert Types**
- Metric alert — triggers on a threshold (CPU > 80%). Fast, 1-5 min evaluation
- Log alert — triggers based on KQL query results. More flexible, slightly slower (5-15 min)
- Activity log alert — triggers when something changes in Azure (VM deleted, policy assigned)

**Alert Severity**
- 0 = Critical, 1 = Error, 2 = Warning, 3 = Informational, 4 = Verbose

**Diagnostic Settings**
- Must be explicitly configured per resource
- Can send logs/metrics to: Log Analytics, Storage Account, Event Hub
- Activity Log is separate from resource-level diagnostic logs

**Action Groups**
- Reusable — one action group can be attached to many alert rules
- Can notify via: email, SMS, push notification, webhook, Azure Function, Logic App
