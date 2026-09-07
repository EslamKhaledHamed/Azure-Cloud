# Lab 08 — Multi-Tier Solution with API Management

## What I Did
Set up a two-tier architecture: a containerized web app as the backend and Azure API Management sitting in front of it as a proxy. Built three API operations that each demonstrate a different APIM capability — header injection, response transformation, and URL rewriting.

This lab couldn't be fully completed due to subscription restrictions, so it's documented from the lab instructions.

## Architecture

```
Client
  ↓
Azure API Management (proapi61963702)
  ├── Echo Headers     → adds custom header, routes to /headers
  ├── Get Legacy Data  → calls /xml, converts response to JSON
  └── Modify Status    → rewrites /status/404 to /status/200
  ↓
Azure App Service (httpapi61963702)
└── kennethreitz/httpbin container — returns info about requests
```

## Resources

| Resource | Type |
|---|---|
| ApiService-lod61963702 | Resource Group |
| httpapi61963702 | App Service — httpbin container |
| ApiPlan | App Service Plan (Basic B1) |
| proapi61963702 | API Management (Consumption) |

## Three Operations and Their Policies

**Echo Headers** — Injects a custom header into every request:
```xml
<inbound>
    <base />
    <set-header name="source" exists-action="append">
        <value>azure-api-mgmt</value>
    </set-header>
</inbound>
```

**Get Legacy Data** — Converts XML response from backend into JSON automatically:
```xml
<outbound>
    <base />
    <xml-to-json kind="direct" apply="always" consider-accept-header="false" />
</outbound>
```

**Modify Status Code** — Rewrites the request URL before it hits the backend:
```xml
<inbound>
    <base />
    <rewrite-uri template="/status/200" />
</inbound>
```

## What I Learned
- APIM sits between clients and your backend — clients never talk directly to the backend
- Inbound policies run before the request reaches the backend
- Outbound policies run after the backend responds, before the client receives it
- You can change headers, transform formats, rewrite URLs, enforce auth — all at the proxy layer
- Consumption tier is serverless — you pay per million calls, no minimum
- This pattern is common in enterprise architectures where you need versioning, rate limiting, and monitoring across multiple APIs

**May 2026**
