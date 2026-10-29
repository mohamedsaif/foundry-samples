param cosmosDBConnection string 
param azureStorageConnection string 
param aiSearchConnection string
param projectName string
param accountName string
param projectCapHost string

var threadConnections = ['${cosmosDBConnection}']
var storageConnections = ['${azureStorageConnection}']


resource account 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' existing = {
   name: accountName
}

resource project 'Microsoft.CognitiveServices/accounts/projects@2025-04-01-preview' existing = {
  name: projectName
  parent: account
}

resource projectCapabilityHost 'Microsoft.CognitiveServices/accounts/projects/capabilityHosts@2025-04-01-preview' = {
  name: projectCapHost
  parent: project
  properties: {
    #disable-next-line BCP037
    capabilityHostKind: 'Agents'
    vectorStoreConnections: [aiSearchConnection]
    storageConnections: storageConnections
    threadStorageConnections: threadConnections
  }

}

output projectCapHost string = projectCapabilityHost.name
