[![Build Status](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_apis/build/status/bat-platform-building-blocks?branchName=master)](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build/latest?definitionId=45&branchName=master)
# Platform Building Blocks: Styles and Conventions
The templates provided in this repository are designed to provide a level of standardised configuration across
one or more application in a service.

## Table of contents
1. [Usage](#Usage)
2. [Branching](#Branching)
3. [Resource naming and parameter metadata description properties](#Resource-naming-and-parameter-metadata-description-properties)
4. [Property name formatting](#Property-name-formatting)
5. [Logic App for Slack](#logic-app-for-slack)

### Usage

1. In the root of the applications repository, create a new directory named `azure`

2. Within the directory Create a new template named `template.json`

3. Set the root 'Raw' path of the Azure Resource templates as a top-level variable as follows:

    ```json
    "variables": {
            "deploymentUrlBase": "https://raw.githubusercontent.com/SkillsFundingAgency/bat-platform-building-blocks/master/templates/",
            ...
    }
    ```

4. Select the Azure Resource template you wish to use, (eg. https://raw.githubusercontent.com/SkillsFundingAgency/bat-platform-building-blocks/master/templates/app-service.json) by setting the concatenation of the deploymentUrlBase variable and the file name as the uri of the templateLink property as follows:

    ```json
    {
        "apiVersion": "2017-05-10",
        "name": "app-service",
        "type": "Microsoft.Resources/deployments",
        "properties": {
            "mode": "Incremental",
            "templateLink": {
                "uri": "[concat(variables('deploymentUrlBase'),'app-service.json')]",
                "contentVersion": "1.0.0.0"
            },
            "parameters": {
                "parameter1": {
                    "value": "<Your value>"
                },
                "parameter2": {
                    "value": "<Your value>"
                }
            }
        },
        "dependsOn":[
            "<Any dependencies>"
        ]
    }
    ```

### Branching

1. Always do your work in a new branch.

2. Do not ever commit straight to master.

3. Submit a pull request to the team when you are ready for review.

4. After the pull request is approved and the branch merged to master, delete the branch you made.

### Resource-naming-and-parameter-metadata-description-properties

Reduce the number of top-level parameters needed by setting the Azure resource names with variables:

1. Set the top-level resourceEnvironmentName and serviceName parameters as follows:

    ```json
    "parameters": {
        "resourceEnvironmentName": {
            "type": "string",
            "metadata": {
                "description": "Short name of the environment. Used for the name of resources created."
            }
        },
        "serviceName": {
            "type": "string",
            "metadata": {
                "description": "Short name of the service. Used for the name of resources created."
            }
        },
            ...
    }
    ```

2. Set the top-level variable of the ```resourceNamePrefix``` and Azure resource names as follows:

    ```json
    "variables": {
        ...
        "resourceNamePrefix": "[toLower(concat('bat-', parameters('resourceEnvironmentName'),'-', parameters('serviceName')))]",
        "storageAccountName": "[toLower(concat('bat', parameters('resourceEnvironmentName'), parameters('serviceName'), 'str'))]",
        "appServiceName": "[concat(variables('resourceNamePrefix'), '-as')]",
        ...
    }
    ```

3. Within the properties section of the resource deployment section, use the resource name variable for the name parameter of the resource as follows:

    ```json
    "parameters": {
        "appServiceName": {
            "value": "[variables('appServiceName')]"
        },
        ...
    }
    ```

4. Set the the top-level output of the generated variable that will be used in the release pipeline as follows:

    ```json
    "outputs": {
        "AppServiceName": {
            "type": "string",
            "value": "[variables('appServiceName')]"
        },
        ...
    }
    ```

### Property name formatting

The convention of property name formatting, as used in the examples above:

1. Parameters: camelCase (matching the release pipeline override template parameters)
2. Variables: camelCase
3. Resource Deployments: lowercase-with-hyphens
4. Outputs: PascalCase (matching the release pipeline variables)

### Logic App for Slack

When deploying the logic app for Slack, after the initial deployment you will need to complete following manual steps to authorise the API connection with Slack the first time only. Until these steps are complete you will not be able to receive alerts in slack.
1. Login to the [Azure portal](https://portal.azure.com)
2. Go to the 'API Connection' blade
3. Select the Slack API connection that has been deployed
4. Select 'Edit API connection' under 'General' in the menu
5. Click the 'Authorize' button and click 'Allow' in the pop-up window that opens
6. Once the Authorization is complete click the 'Save' button in the Edit API connection pane that should still be open in the portal.
