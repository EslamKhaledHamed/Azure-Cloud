# Lab 06 — Authentication with OpenID Connect and MSAL

## What I Did
Built an ASP.NET Core web app that delegates authentication to Microsoft Entra ID using OpenID Connect. Instead of managing passwords, the app redirects users to Microsoft login and receives a signed JWT token back.

## How It Works

```
User opens localhost:7084
      ↓
Clicks Sign In
      ↓
Redirected to Microsoft Entra ID
      ↓
User logs in with Microsoft credentials
      ↓
Entra ID sends back a signed JWT token
      ↓
App validates the token (signature, lifetime, audience)
      ↓
Welcome page shows the user's email address
      ↓
User clicks Sign Out → confirmed signed out
```

## App Registration Details

| Setting | Value |
|---|---|
| App name | OIDCClient |
| Client ID | 46b497bd-6053-4410-8332-60d33f7d5ef0 |
| Tenant | LODSPRODMSLEARNMCA.onmicrosoft.com |
| Account type | Single-tenant (org only) |

## Commands

```powershell
dotnet build
dotnet dev-certs https --trust
dotnet run
```

## Token Validation Log Output
```
IDX10242: Security token has a valid signature
IDX10239: Lifetime of the token is valid
IDX10234: Audience Validated — 46b497bd-6053-4410-8332-60d33f7d5ef0
IDX10245: Creating claims identity from validated token
```

## What I Learned
- OpenID Connect sits on top of OAuth 2.0 and adds identity (who you are, not just what you can do)
- MSAL handles the redirect, token exchange, and validation — you don't write that logic yourself
- JWT tokens are signed — the app verifies the signature to make sure Microsoft issued the token
- Audience validation ensures the token was meant for this specific app, not another one
- Single-tenant means only users from the registered organization can sign in
- The whole flow requires no passwords stored anywhere in the app

**May 14, 2026**
