# What is Bicep?

Bicep is a ***Domain Specific Language (DSL)*** developed by Microsoft to deploy Resources in Azure. Bicep does not support state file management. State file is managed by Azure Resource Manager itself. Bicep is free and does not need a license to start building Infrastructure as Code (IaC).

## Infrastructure as Code?

IaC is defining infrastructure within a code format. This is defined using declarative syntax that helps maintain the infrastruture as a source code for authoring and maintaining the real world infrastructure similar to application programming.

IaC brings a lot of advantages to organizations viz. faster deployment, acts as a state of the infrastructure deployed etc.

Bicep is an IaC tool offered by Microsoft to deploy resources within Azure.

## Bicep demystified

With Bicep, it becomes much more easier to author and maintain Azure IaC templates. A bicep file and a corresponding bicepparam (parameters file) is all you need to start deploying resources. It provides a bultin linter that helps you maintain best practices when developing bicep templates.

A bicep file mostly contains parameters (param blocks), variables, resource block(s) that represent(s) actual azure resources and outputs.

Bicep offers modular deployments using nested templates which act as community templates that can be leveraged across different requirements. Microsoft has developed public modules what is called CARML modules that can be used or write the modules from scratch that tailor to your needs. More information on modules is covered in later sections.

When passed to ARM engine, it gets converted into a JSON ARM template and gets deployed.

### Parameters

Parameters in bicep provide standerdized resuable templates that provide information during deployments. Click [here](https://learn.microsoft.com/en-us/training/modules/build-reusable-bicep-templates-parameters/) to know more about creating parameterized bicep templates

### Variables

Variables in bicep mostly act as config maps for your bicep template.

### Conditions and loops

Use conditions and loops to build flexible bicep templates that makes the bicep templates/modules easy to use.

To know more about incorporating conditional deployments and loops, visit [this link](https://learn.microsoft.com/en-us/training/modules/build-flexible-bicep-templates-conditions-loops/).

### Modules

Create Modules that act as resuable templates.

## What is a bicep module?

To be simple, a bicep module is nothing but a nested ARM template. It provides the re-usability of the template across different requirements. It is like any other bicep file. The advantage with the module is, it encapuslates the complex details of the deployment such as the resource configuration. With modular approach, you can incorporate the governance standards that are offered by Microsoft and as well as the ones that are orchestrated by your company.

It is wise to use Azure's Well Architected Framework and Cloud Adoption Framework which helps you follow Microsoft's best practices. Doing so, helps the users using the module simplify the deployment based on their needs.

Package the module using parameters, logics, conditions, and child/dependent resources to ensure the dependent/child resources get deployed if chosen. This ensures using consuming the module provides more flexibility when deploying by only taking less time to deploy the set of resources using a single module.

A module can have multiple modules within it.

Bicep supports publishing the modules to a private registry such as template spec or Azure Container Registry. This helps share the modules across the organizations.

With the Bicep CLI versions 0.21 and above supports user-defined data types. User-defined data types is a new feature and is explained in later section.

The BICEP CLI being used at the writing of the README file is 0.24.24 where the user-defined types are no more experimental.

### ***Best practices***

- Publish the modules to ACR as it supports private connectivity to your modules. Agents running the bicep deployment stays within the network and not exposed publicly. It also provides RBAC control on restricting the access.

- Version the module accordingly. Force publish the module with the same version only when the changes made to the module does not affect the users using it. [__Verisoning Policies__](https://learn.microsoft.com/en-us/training/modules/share-bicep-modules-using-private-registries/4-publish-module-private-registry?pivots=cli).

- Use parameters to provide flexible tempalte and prevent hardcoding the property values when not necessary. This allows the module to be customized to the users' needs. Use decorators viz. ___@description()___, ___@allowedValues()___ etc. to provide more context around the parameters.

- Use user-defined types for complex parameters such as object or object[] as it helps in autopopulating the required properties.

- When using for loops to deploy multiple instances of your module, add the decorator @batchSize(1), as this ensures that the deployment happens sequentially.

    ```bicep
    // deploy multiple key vaults
    param keyVaultNameSuffixes array = [
        'test1'
        'test2'
    ]

    // consume key vault module
    @batchSize(1)
    module test '../KeyVault/module.bicep' = [ for each in keyVaultNameSuffixes: {
        name: 'DeployKeyVault
        parameters: {
            nameSuffix: each
            //may contain more parameters
        }
    }]
    ```

- If you want to deploy multiple instances of the module in parallel (default method), set the deployment name of the child modules within the root module (if any) with Unique names. Using timestamps alone is not sufficient when deploying multiple instances of the module at the same time.

- Add comments within your module.

- Create a bicep param file for the bicep file that consumes the modules.


### ___User-defined data types___

User-defined types is a new feature developed by Microsoft to create custom data types for the bicep templates. These custom data types allow the user to auto-populate the properties availble within an object or object[] type expressions.

To define a user-defined data type within the bicep file, use type statement, a name to it and followed by an expression. Below is an example.

```bicep
type exampleArray = {
    sku: ('Developer' | 'Premium')
    count: int
    pubisherEmail: string
}[]
```

