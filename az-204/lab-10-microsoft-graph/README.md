# Lab 10 — Querying Microsoft Graph with .NET

## What I Did
Built a .NET console app that signs in a user interactively, then queries the Microsoft Graph API to retrieve their profile. The app uses the Graph SDK so I didn't have to deal with raw HTTP requests or token handling manually.

## How It Works

```
App loads CLIENT_ID and TENANT_ID from .env file
      ↓
InteractiveBrowserCredential opens the browser
      ↓
User logs into Microsoft Entra ID
      ↓
Browser shows "Authentication Complete"
      ↓
App gets an access token with User.Read scope
      ↓
Graph SDK calls GET /me
      ↓
Profile info printed to console
```

## App Registration

| Setting | Value |
|---|---|
| App name | myGraphApplication |
| Client ID | de9b9030-af29-4fc2-aabf-a876c7e4e77f |
| Tenant ID | 8eb87a6e-8055-4135-b69d-f19c799ec045 |
| Account type | Single-tenant |
| Redirect URI | Public client (localhost) |

## .env File

```
CLIENT_ID=de9b9030-af29-4fc2-aabf-a876c7e4e77f
TENANT_ID=8eb87a6e-8055-4135-b69d-f19c799ec045
```

## Key Code

```csharp
DotEnv.Load();
var envVars = DotEnv.Read();

string clientId = envVars["CLIENT_ID"];
string tenantId = envVars["TENANT_ID"];

var scopes = new[] { "User.Read" };

var credential = new InteractiveBrowserCredential(
    new InteractiveBrowserCredentialOptions
    {
        TenantId = tenantId,
        ClientId = clientId
    });

var client = new GraphServiceClient(credential, scopes);

var user = await client.Me.GetAsync();
Console.WriteLine($"Display Name:   {user.DisplayName}");
Console.WriteLine($"Principal Name: {user.UserPrincipalName}");
Console.WriteLine($"User Id:        {user.Id}");
```

## Output

```
Retrieving user profile...
Display Name:   LabUser-62000594
Principal Name: LabUser-62000594@cloudslice.onmicrosoft.com
User Id:        39a05369-2626-48cb-9847-afaa1528656e
```

## What I Learned
- Microsoft Graph is a single API endpoint for all Microsoft 365 data — users, emails, calendars, files, teams
- You need to register an app in Entra ID before you can call Graph on behalf of users
- InteractiveBrowserCredential handles the entire OAuth flow — opening the browser, capturing the redirect, exchanging the code for a token
- User.Read scope gives access to the signed-in user's basic profile only
- The .env file keeps credentials out of the source code
- `client.Me.GetAsync()` maps to `GET https://graph.microsoft.com/v1.0/me`

**May 21, 2026**
