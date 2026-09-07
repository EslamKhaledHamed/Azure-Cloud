# Lab 11 — Key Vault Console App

## What I Did
Built a .NET console app in Azure Cloud Shell that connects to an Azure Key Vault and provides a simple menu to create new secrets and list existing ones. Also set up the Key Vault itself and assigned the right role using CLI before writing any code.

## Setup Steps

Created the Key Vault and assigned myself the Secrets Officer role:

```bash
resourceGroup=myResourceGrouplod62001688
location=eastus
keyVaultName=mykeyvaultname62001688

az keyvault create \
    --name $keyVaultName \
    --resource-group $resourceGroup \
    --location $location

# Get my user identity
userPrincipal=$(az rest --method GET \
    --url https://graph.microsoft.com/v1.0/me \
    --headers 'Content-Type=application/json' \
    --query userPrincipalName --output tsv)

# Scope the role to just this Key Vault
resourceID=$(az keyvault show \
    --resource-group $resourceGroup \
    --name $keyVaultName \
    --query id --output tsv)

az role assignment create \
    --assignee $userPrincipal \
    --role "Key Vault Secrets Officer" \
    --scope $resourceID

# Create the initial secret via CLI to test
az keyvault secret set \
    --vault-name $keyVaultName \
    --name "MySecret" \
    --value "My secret value"

# Verify it worked
az keyvault secret show --name "MySecret" --vault-name $keyVaultName
```

## The .NET App

```bash
mkdir keyvault && cd keyvault
dotnet new console
dotnet add package Azure.Identity
dotnet add package Azure.Security.KeyVault.Secrets
az login
dotnet run
```

## App Menu

```
Please select an option:
1. Create a new secret
2. List all secrets
Type 'quit' to exit
```

## Key Code

Connecting to Key Vault:
```csharp
string KeyVaultUrl = "https://mykeyvaultname62001688.vault.azure.net/";

DefaultAzureCredentialOptions options = new()
{
    ExcludeEnvironmentCredential = true,
    ExcludeManagedIdentityCredential = true
};

var client = new SecretClient(new Uri(KeyVaultUrl), new DefaultAzureCredential(options));
```

Creating a secret:
```csharp
var secret = new KeyVaultSecret(secretName, secretValue);
await client.SetSecretAsync(secret);
```

Listing secrets:
```csharp
var secretProperties = client.GetPropertiesOfSecretsAsync();
await foreach (var secretProperty in secretProperties)
{
    var secret = await client.GetSecretAsync(secretProperty.Name);
    Console.WriteLine($"Name: {secret.Value.Name}");
    Console.WriteLine($"Value: {secret.Value.Value}");
    Console.WriteLine($"Created: {secret.Value.Properties.CreatedOn}");
}
```

## What I Learned
- GetPropertiesOfSecretsAsync() only returns metadata — you need a separate GetSecretAsync() call to get the actual value
- DefaultAzureCredential tries multiple auth methods in order — useful in different environments
- Role assignments take a minute or two to propagate before they work
- Key Vault Secrets Officer = create, read, update, delete secrets. Key Vault Secrets User = read only
- Running az login inside Cloud Shell is required even though the shell is already authenticated

**May 2026**
