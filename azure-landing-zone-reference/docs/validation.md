# LittleNest validation and troubleshooting

## Before apply

- Confirm Azure CLI tenant and subscription ID.
- Confirm the subscription is disposable and non-production.
- Confirm the deployment identity can create resources and role assignments.
- Verify the region supports Functions Flex Consumption and the subscription has quota.
- Confirm Cosmos DB Free Tier eligibility before account creation.
- Inspect the Terraform plan, private endpoint count and recurring charges.

## Network validation

From a machine with a route into the VNet:

~~~powershell
Resolve-DnsName "<web-app-name>.azurewebsites.net"
Resolve-DnsName "<function-app-name>.azurewebsites.net"
Resolve-DnsName "<cosmos-account>.documents.azure.com"
Resolve-DnsName "<key-vault-name>.vault.azure.net"
Resolve-DnsName "<storage-account>.blob.core.windows.net"
Resolve-DnsName "<storage-account>.queue.core.windows.net"
~~~

Service names should resolve through configured private DNS zones to private addresses. DNS success does not prove authorisation or routing; test HTTPS and the actual SDK call too.

## Identity validation

- App Service and Function App system-assigned identities exist.
- If the optional banner exercise is enabled, the App Service identity can read the synthetic Key Vault secret and no secret value is stored in app settings.
- App Service can read Cosmos DB and send a Storage Queue message using its identity.
- Function App can receive a queue message and update the order document.
- Neither application contains account keys, SAS tokens or connection-string secrets.
- Terraform deployment identity has only the resource and role-assignment permissions required for this lab.

## Application validation

- GET /healthz returns status=ok.
- GET /api/products returns the sample catalogue.
- POST /api/orders creates a demo order and queues a message.
- Function logs show the order was processed.
- Order status changes from Received to Processed.

## Troubleshooting

| Symptom | Likely checks |
|---|---|
| App cannot start | App Service logs, Node runtime, deployment package and app settings |
| Cosmos 403 | Cosmos native data-plane role, identity principal ID and propagation delay |
| Cosmos timeout | Private endpoint approval, private DNS, VNet integration and routing |
| Queue 403 | Storage Queue data-plane roles and queue URI |
| Function trigger idle | Flex host storage identity roles, trigger connection settings, private DNS and host logs |
| SCM deployment fails | Private SCM endpoint reachability; deploy from a connected private network |
| Storage access denied | Blob/Queue/Table data-plane roles, shared-key settings and DNS |

## Cleanup

After Terraform destroy, check for soft-deleted Key Vaults, retained blobs, Log Analytics data and resources created manually. Confirm Azure Cost Management no longer shows ongoing lab consumption.
