# Lab 09 — Event Publishing with Azure Event Grid

## What I Did
Built a .NET console app that publishes employee registration events to an Azure Event Grid topic. A web-based Event Grid Viewer app subscribes to the topic via webhook and displays the events as they arrive.

## Flow

```
EventPublisher app
      ↓ publishes 2 events
Event Grid Topic (hrtopic61966830)
      ↓ routes to subscription (basicsub)
Webhook endpoint
      ↓
Event Viewer at eventviewer61966830.azurewebsites.net
      ↓ displays both events in real time
```

## Resources

| Resource | Type |
|---|---|
| PubSubEvents-lod61966830 | Resource Group |
| hrtopic61966830 | Event Grid Topic |
| eventviewer61966830 | App Service (viewer) |
| EventPlan | App Service Plan (P1v3) |

## Events I Published

```json
{
  "subject": "New Employee: Alba Sutton",
  "eventType": "Employees.Registration.New",
  "dataVersion": "1.0",
  "data": {
    "FullName": "Alba Sutton",
    "Address": "4567 Pine Avenue, Edison, WA 97202"
  }
}
```

```json
{
  "subject": "New Employee: Alexandre Doyon",
  "eventType": "Employees.Registration.New",
  "dataVersion": "1.0",
  "data": {
    "FullName": "Alexandre Doyon",
    "Address": "456 College Street, Bow, WA 98107"
  }
}
```

## Code

```csharp
Uri endpoint = new Uri(topicEndpoint);
AzureKeyCredential credential = new AzureKeyCredential(topicKey);
EventGridPublisherClient client = new EventGridPublisherClient(endpoint, credential);

EventGridEvent evt = new EventGridEvent(
    subject: "New Employee: Alba Sutton",
    eventType: "Employees.Registration.New",
    dataVersion: "1.0",
    data: new { FullName = "Alba Sutton", Address = "4567 Pine Avenue..." }
);

await client.SendEventAsync(evt);
Console.WriteLine("First event published");
```

## Commands

```bash
dotnet new console --framework net8.0 --name EventPublisher --output .
dotnet add package Azure.Messaging.EventGrid --version 4.11.0
dotnet build
dotnet run
```

## What Showed Up in the Viewer

Three events appeared: the two I published plus a `Microsoft.EventGrid.SubscriptionValidationEvent` which Azure sends automatically when a new subscription is created to verify the webhook endpoint is working.

## What I Learned
- Event Grid is a routing service — it doesn't store events, it routes them
- The topic is the endpoint you publish to
- The subscription defines who receives events and how (webhook, queue, function, etc.)
- Both events arrived within seconds of publishing
- SubscriptionValidationEvent happens once when you create a subscription — Event Grid checks the endpoint is reachable before routing real events to it

**May 20, 2026**
