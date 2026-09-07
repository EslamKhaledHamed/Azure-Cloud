# Lab 12 — Sending and Receiving Events with Azure Event Hubs

## What I Did
Built a .NET console app that sends a batch of events to an Azure Event Hub and then reads them all back. The producer and consumer are in the same app for simplicity, but in real systems they'd typically be separate services.

## How It Works

```
Producer creates a batch of 3 events with random numbers
      ↓
EventHubProducerClient sends the batch
      ↓
Events stored in the Event Hub partitions
      ↓
Press Enter
      ↓
EventHubConsumerClient counts events across all partitions
      ↓
Reads from the beginning and prints each one
```

## Resources

| Resource | Type |
|---|---|
| myResourceGrouplod62002681 | Resource Group |
| eventhubsns62002681 | Event Hubs Namespace |
| myEventHub | Event Hub |

## CLI Setup

```bash
resourceGroup=myResourceGrouplod62002681
location=eastus
namespaceName=eventhubsns62002681

az eventhubs namespace create \
    --name $namespaceName --resource-group $resourceGroup -l $location

az eventhubs eventhub create \
    --name myEventHub --resource-group $resourceGroup \
    --namespace-name $namespaceName

# Assign Data Owner role
userPrincipal=$(az rest --method GET \
    --url https://graph.microsoft.com/v1.0/me \
    --headers 'Content-Type=application/json' \
    --query userPrincipalName --output tsv)

resourceID=$(az eventhubs namespace show \
    --resource-group $resourceGroup \
    --name $namespaceName --query id --output tsv)

az role assignment create \
    --assignee $userPrincipal \
    --role "Azure Event Hubs Data Owner" \
    --scope $resourceID
```

## Producer Code

```csharp
EventHubProducerClient producerClient = new EventHubProducerClient(
    namespaceURL, eventHubName, new DefaultAzureCredential(options));

using EventDataBatch eventBatch = await producerClient.CreateBatchAsync();

var random = new Random();
for (int i = 1; i <= 3; i++)
{
    int num = random.Next(1, 101);
    eventBatch.TryAdd(new EventData(Encoding.UTF8.GetBytes($"Event {num}")));
}

await producerClient.SendAsync(eventBatch);
Console.WriteLine("A batch of 3 events has been published.");
```

## Consumer Code

```csharp
await using var consumerClient = new EventHubConsumerClient(
    EventHubConsumerClient.DefaultConsumerGroupName,
    namespaceURL, eventHubName, new DefaultAzureCredential(options));

await foreach (PartitionEvent partitionEvent in
    consumerClient.ReadEventsAsync(startReadingAtEarliestEvent: true))
{
    string body = Encoding.UTF8.GetString(partitionEvent.Data.Body.ToArray());
    Console.WriteLine($"Retrieved event: {body}");
}
```

## Output

```
A batch of 3 events has been published.
Press Enter to retrieve and print the events...

Retrieving all events from the hub...
Retrieved event: Event 4
Retrieved event: Event 96
Retrieved event: Event 74
Done retrieving events. Press Enter to exit...
```

## What I Learned
- Event Hubs is designed for high-throughput streaming, not just simple messaging
- Events accumulate — if you run the app again you get all previous events too
- Partitions are how Event Hubs achieves parallelism — each partition is an independent ordered log
- startReadingAtEarliestEvent: true means start from the very first event ever sent
- Consumer groups give different consumers independent read positions in the same hub
- The namespace is the container; the event hub is the actual channel

**May 2026**
