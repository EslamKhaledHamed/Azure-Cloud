# Lab 02 — Task Processing with Azure Functions

## What I Did
Built three Azure Functions that demonstrate the three most common trigger types: HTTP, Timer, and Blob Storage input. Deployed the function app to Azure and tested each one.

The lab environment had some outdated configuration, so parts of the setup were adapted from the lab instructions and documented here for reference.

## What I Built

Three functions in one function app:

**Echo** — HTTP trigger that reads whatever you POST to it and sends it back. Simple but useful for testing.

**Recurring** — Timer trigger set to fire every minute using a CRON expression. Just logs the time each time it runs.

**GetSettingInfo** — HTTP trigger that reads a JSON file from Blob Storage and returns the content. This one shows how Functions can integrate with other Azure services through bindings.

## Resources

| Resource | Type |
|---|---|
| Serverless-lod61547382 | Resource Group |
| funcstor61547382 | Storage Account |
| funclogic61547382 | Function App (Consumption, Linux) |
| content | Blob Container |

## Commands

```bash
# Set up the project
func init --worker-runtime dotnet-isolated --target-framework net8.0 --force
func new --template "HTTP trigger" --name "Echo"
func new --template "Timer trigger" --name "Recurring"
func new --template "HTTP trigger" --name "GetSettingInfo"

# Add blob extension
dotnet add package Microsoft.Azure.Functions.Worker.Extensions.Storage --version 6.2.0

# Run locally
func start --build

# Test with curl
curl -X POST -i http://localhost:7071/api/echo -d "Hello"
curl -X GET -i http://localhost:7071/api/GetSettingInfo

# Deploy
func azure functionapp publish funclogic61547382 --dotnet-version 8.0
```

## Key Code

Echo function — reads the request body and sends it back:
```csharp
[Function("Echo")]
public HttpResponseData Run(
  [HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequestData req)
{
    var response = req.CreateResponse(HttpStatusCode.OK);
    StreamReader reader = new StreamReader(req.Body);
    string requestBody = reader.ReadToEnd();
    response.WriteString(requestBody);
    return response;
}
```

Blob input binding — reads a file from storage directly in the function signature:
```csharp
[Function("GetSettingInfo")]
public HttpResponseData Run(
  [HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequestData req,
  [BlobInput("content/settings.json", Connection = "AzureWebJobsStorage")] string blobContent)
{
    var response = req.CreateResponse(HttpStatusCode.OK);
    response.WriteString($"{blobContent}");
    return response;
}
```

## What I Learned
- Consumption plan means you pay only when the function actually runs
- CRON format for every minute: `0 */1 * * * *`
- Blob input bindings let you inject file content without writing connection code
- local.settings.json holds config locally — Azure uses app settings in the portal
- func start --build compiles and runs everything locally before deploying

**May 6, 2026**
