<#
We should validate that:
    * it is valid JSON (ARM.Tests)
    * it includes a schema, parameters, variables, resources and a outputs section (ARM.Tests)
    * all parameters have metadata (ARM.Tests)
    * it is UTF-8 encoded 
    * no tabs are used, but 4 spaces for identation
    * Test-AzureRmResourceGroupDeployment should return ok 
#>
 #Requires -Modules  @{ModuleName='Pester';ModuleVersion='3.3.14'}  

$azuredeploy = ".\azuredeploy.json"

    Context 'Deployment' {
        
        BeforeAll {
            
            $Resourcegroup = Get-AzureRmResourceGroup -Name 'RGAutomationPack'
            if(!$Resourcegroup){
                
                [void](New-AzureRmResourceGroup -Name 'RGAutomationPack' -Location 'West Europe')
            }
            
            $script:ARMParamObject = @{
                accountName = 'AAAzureBilling01'
                RegionId = 'West Europe'
                pricingTier = 'Free'
            }
        }
        
        It 'should deploy' {
          Test-AzureRmResourceGroupDeployment -TemplateFile $azuredeploy -TemplateParameterObject $script:ARMParamObject -ResourceGroupName $ResourceGroup | Should not Throw
        }
        
        AfterAll {
            
            Remove-AzureRmResourceGroup -Name 'RGAutomationPackIt is ' -Force
        }
    }


