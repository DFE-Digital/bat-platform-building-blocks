[![Build Status](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_apis/build/status/bat-platform-building-blocks?branchName=master)](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build/latest?definitionId=45&branchName=master)
# bat-platform-building-blocks
The templates provided in this repository are designed to provide a level of standardised configurations across
one or more application in a service.

## Example deployment with PowerShell
Use the following to deploy the example linked template with PowerShell.

```PowerShell
# --- Set resource group name and create
$ResourceGroupName = "xxx-dev-rg"
New-AzResourceGroup -Name $ResourceGroupName -Location "West Europe" -Force

# --- Deploy infrastructure
$DeploymentParameters = @{
    AppServiceName = "xxx-dev-as"
    AppServicePlanName = "xxx-dev-asp"
    TrafficManagerProfileName = "xxx-dev-tmp"
    TrafficManagerEndpointName = "xxx-dev-as"
    TrafficManagerEndpointPriority = 1
}

New-AzResourceGroupDeployment -Name "deployment-01" -ResourceGroupName $ResourceGroupName -TemplateFile .\examples\example-linked-template.json @DeploymentParameters
```

## Example deployment with Az cli
Use the following to deploy the example linked template with Az cli.

```Bash
#!/bin/bash
RESOURCEGROUPNAME="xxx-dev-rg"
LOCATION="westeurope"

az group create --name $RESOURCEGROUPNAME --location $LOCATION

az group deployment create --resource-group $RESOURCEGROUPNAME \
                           --template-file './examples/example-linked-template.json' \
                           --parameters appServiceName="xxx-dev-as" \
                                        appServicePlanName="xx-dev-asp" \
                                        trafficManagerProfileName="xxx-dev-tmp" \
                                        trafficManagerEndpointName="xxx-dev-as" \
                                        trafficManagerEndpointPriority=1
```