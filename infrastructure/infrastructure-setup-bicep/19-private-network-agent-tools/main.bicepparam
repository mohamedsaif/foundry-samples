using './main.bicep'

// -----------------------------------------------------------------------------
// Foundry account & project
// -----------------------------------------------------------------------------
param location = 'uaenorth'
param aiServices = 'aif'           // 2-40 lowercase chars; a 4-char suffix is appended
param firstProjectName = 'proj-secure-aen-agent-01'
param projectDescription = 'A project for the AI Foundry account with network secured deployed Agent'
param displayName = 'Secure AEN Agent 01'

// -----------------------------------------------------------------------------
// Model deployment
// -----------------------------------------------------------------------------
param modelName = 'gpt-6.1-terra'
param modelFormat = 'OpenAI'
param modelVersion = '2026-10-26'
param modelSkuName = 'GlobalStandard'
param modelCapacity = 2

// -----------------------------------------------------------------------------
// Networking
//
// Two scenarios:
//   1) NEW VNet (default): leave `existingVnetResourceId` empty. The template will
//      create a new VNet plus three subnets (agent / pe / mcp). Set `vnetAddressPrefix`
//      and the per-subnet prefixes if you want non-default CIDRs.
//   2) EXISTING VNet: set `existingVnetResourceId` to the VNet's full ARM ID. The
//      `vnetName` and per-subnet `*Name` params are then ignored — names come from the
//      ARM IDs. To **reuse** existing subnets without modification, also set the
//      matching `existing*SubnetResourceId` params (highly recommended for shared VNets;
//      otherwise the template will try to (re)create the subnets and may overwrite NSGs
//      or routing).
// -----------------------------------------------------------------------------
param vnetName = 'agent-vnet'
param agentSubnetName = 'agent-subnet'
param peSubnetName = 'pe-subnet'
param mcpSubnetName = 'mcp-subnet'

param vnetAddressPrefix = ''           // e.g. '192.168.0.0/16'
param agentSubnetPrefix = ''           // e.g. '192.168.0.0/24'
param peSubnetPrefix    = ''           // e.g. '192.168.1.0/24'
param mcpSubnetPrefix   = ''           // e.g. '192.168.2.0/24'

param existingVnetResourceId = '/subscriptions/de50fc35-0789-477a-bd11-d939aff69d9b/resourceGroups/rg-agents-vnet/providers/Microsoft.Network/virtualNetworks/vnet-agents-aen-01'
// param existingVnetResourceId = '/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>'

// Optional - reuse existing subnets in the existing VNet (no create / no modify).
// Provide the full ARM ID for each subnet you want to leave untouched.
param existingAgentSubnetResourceId = '/subscriptions/de50fc35-0789-477a-bd11-d939aff69d9b/resourceGroups/rg-agents-vnet/providers/Microsoft.Network/virtualNetworks/vnet-agents-aen-01/subnets/snet-agents-01'
param existingPeSubnetResourceId    = '/subscriptions/de50fc35-0789-477a-bd11-d939aff69d9b/resourceGroups/rg-agents-vnet/providers/Microsoft.Network/virtualNetworks/vnet-agents-aen-01/subnets/snet-pe'
param existingMcpSubnetResourceId   = '/subscriptions/de50fc35-0789-477a-bd11-d939aff69d9b/resourceGroups/rg-agents-vnet/providers/Microsoft.Network/virtualNetworks/vnet-agents-aen-01/subnets/snet-ai-assets'
// param existingAgentSubnetResourceId = '/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/agent-subnet'

// -----------------------------------------------------------------------------
// Bring-your-own backing resources (optional)
// Leave resource IDs empty to create new ones in the deployment resource group.
// -----------------------------------------------------------------------------
param aiSearchLocation = '' // Empty uses location; e.g. 'swedencentral' for another region. The private endpoint stays in location.
param cosmosDBLocation = '' // Empty uses location; e.g. 'swedencentral' for another region. The private endpoint stays in location.
param existingAiSearchResourceId = ''
param existingAzureStorageAccountResourceId = ''
param existingAzureCosmosDBAccountResourceId = ''
param existingFabricWorkspaceResourceId = ''
param enableKeyVault = true
param keyVaultName = ''
param existingKeyVaultResourceId = ''
param enableMonitorPrivateLink = false

// -----------------------------------------------------------------------------
// Private DNS zones
// Each value is an object: { subscriptionId: '<sub-guid>', resourceGroup: '<rg>' }.
//   - Both empty            => create the zone in THIS deployment RG.
//   - resourceGroup only    => reference existing zone in that RG, current subscription.
//   - both set              => reference existing zone in another subscription/RG.
// IMPORTANT: When referencing an existing zone, this template does NOT create the
// VNet link. You must ensure the shared zone is already linked to the target VNet.
// -----------------------------------------------------------------------------
param existingDnsZones = {
  'privatelink.services.ai.azure.com':       { subscriptionId: 'de50fc35-0789-477a-bd11-d939aff69d9b', resourceGroup: 'rg-dns-zones' }
  'privatelink.openai.azure.com':            { subscriptionId: 'de50fc35-0789-477a-bd11-d939aff69d9b', resourceGroup: 'rg-dns-zones' }
  'privatelink.cognitiveservices.azure.com': { subscriptionId: 'de50fc35-0789-477a-bd11-d939aff69d9b', resourceGroup: 'rg-dns-zones' }
  'privatelink.search.windows.net':          { subscriptionId: 'de50fc35-0789-477a-bd11-d939aff69d9b', resourceGroup: 'rg-dns-zones' }
  'privatelink.blob.core.windows.net':       { subscriptionId: 'de50fc35-0789-477a-bd11-d939aff69d9b', resourceGroup: 'rg-dns-zones' }
  'privatelink.documents.azure.com':         { subscriptionId: 'de50fc35-0789-477a-bd11-d939aff69d9b', resourceGroup: 'rg-dns-zones' }
  'privatelink.azurecr.io':                  { subscriptionId: 'de50fc35-0789-477a-bd11-d939aff69d9b', resourceGroup: 'rg-dns-zones' }
  'privatelink.fabric.microsoft.com':        { subscriptionId: 'de50fc35-0789-477a-bd11-d939aff69d9b', resourceGroup: 'rg-dns-zones' }
  'privatelink.vaultcore.azure.net':         { subscriptionId: 'de50fc35-0789-477a-bd11-d939aff69d9b', resourceGroup: 'rg-dns-zones' }
}
