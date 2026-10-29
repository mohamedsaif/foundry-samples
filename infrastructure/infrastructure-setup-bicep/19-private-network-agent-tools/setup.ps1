$RG_NAME = "rg-secure-agent-01"
$RG_LOCATION = "swedencentral"
az group create --name $RG_NAME --location $RG_LOCATION
az deployment group create --resource-group $RG_NAME --template-file main.bicep --parameters main.bicepparam