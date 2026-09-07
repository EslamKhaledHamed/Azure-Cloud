# AZ-104 Lab 04 — Identity and Access Management

## What This Covers
Managing users and groups in Microsoft Entra ID, assigning RBAC roles at different scopes, creating custom roles, and configuring Conditional Access policies.

## Tasks

- Create users and groups in Entra ID
- Assign users to groups
- Assign built-in RBAC roles at subscription, resource group, and resource scope
- Test permissions as a specific user
- Create a custom RBAC role from a JSON definition
- Set up a Conditional Access policy
- Review access with Access Reviews

## CLI Commands

```bash
# Create a user
az ad user create \
  --display-name "Test User" \
  --user-principal-name testuser@domain.onmicrosoft.com \
  --password "TempPass123!" \
  --force-change-password-next-sign-in true

# Create a group
az ad group create \
  --display-name "CloudAdmins" --mail-nickname "CloudAdmins"

# Add user to group
az ad group member add \
  --group CloudAdmins --member-id <user-object-id>

# Assign Contributor role at resource group scope
az role assignment create \
  --assignee testuser@domain.onmicrosoft.com \
  --role "Contributor" --resource-group MyRG

# Assign Reader at subscription scope
az role assignment create \
  --assignee testuser@domain.onmicrosoft.com \
  --role "Reader" \
  --scope /subscriptions/<subscription-id>

# List role assignments in a resource group
az role assignment list --resource-group MyRG --output table

# Remove a role assignment
az role assignment delete \
  --assignee testuser@domain.onmicrosoft.com \
  --role "Contributor" --resource-group MyRG

# Create custom role from JSON
az role definition create --role-definition custom-role.json
```

## Custom Role JSON

```json
{
  "Name": "VM Start/Stop Operator",
  "Description": "Can start and stop VMs but nothing else",
  "Actions": [
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/powerOff/action",
    "Microsoft.Compute/virtualMachines/read"
  ],
  "NotActions": [],
  "AssignableScopes": [
    "/subscriptions/<subscription-id>"
  ]
}
```

## Key Concepts
**Built-in Roles**
- Owner → everything including managing role assignments
- Contributor → everything except managing role assignments
- Reader → view only, no changes
- User Access Administrator → can assign roles but limited on resource actions

**RBAC Scope Hierarchy**
- Management Group → Subscription → Resource Group → Resource
- Roles assigned at a higher scope are inherited by everything below it
- You can narrow permissions by assigning a restrictive role at a lower scope

**How RBAC Works**
- Permissions are additive — if you have multiple role assignments, you get the union of all permissions
- Exception: Deny assignments always win, regardless of allow rules
- Role assignments take a few minutes to propagate

**Conditional Access**
- Requires Azure AD P2 license
- Works as if/then rules: if condition, then require MFA / block / allow
- Common conditions: user location, device compliance, app being accessed, sign-in risk level
