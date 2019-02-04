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
    TrafficManagerEndpointName = "xxx-dev-tme"
    TrafficManagerEndpointPriority = 1

    ContainerRegistryName = "cccdevcr"
    ContainerRegistryPassword = "xxxxxxxxxxxxx"
    ContainerImageReference = "image:tag"

    DfESignInIssuer = "PLACEHOLDER"
    DfESignInIdentifier = "PLACEHOLDER"
    DfESignInSecret = "PLACEHOLDER"
    DfESignInProfile = "PLACEHOLDER"
    SiteBaseUrl = "PLACEHOLDER"
}

New-AzResourceGroupDeployment -Name "deployment-01" -ResourceGroupName $ResourceGroupName -TemplateFile .\examples\example-linked-template.json @DeploymentParameters
```

## Example deployment with Az cli
Use the following to deploy the example linked template with Az cli.

```Bash
TBA
```