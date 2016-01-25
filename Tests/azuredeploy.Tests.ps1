<#
We should validate that:
    * it is valid JSON
    * it includes a schema, parameters, variables, resources and a outputs section
    * all parameters have metadata
    * it is UTF-8 encoded
    * no tabs are used, but 4 spaces for identation
    * Test-AzureRmResourceGroupDeployment should return ok 
#>
 #Requires -Modules  @{ModuleName='Pester';ModuleVersion='3.3.14'}  

$azuredeploy = ".\azuredeploy.json"

Describe 'Text files formatting' {
    
    Context 'File encoding' {
        
        It "doesn't use Unicode encoding"  {
            
            
        }    
    }
    Context "Identations" {
        
        It 'Uses spaces for identiation, not tabs' {
            
        }
    }
}

Describe 'Json file: $azuredeploy' {
    
    BeforeAll { 
        $SchemaVersion = '2015-01-01-preview'
        $SchemaUri = '{0}{1}#' -f 'http://schemas.microsoft.org/azure/deploymentTemplate?api-version=', $SchemaVersion
        
         $jsser = [System.Web.Script.Serialization.JavaScriptSerializer]::new()
            $jsser.MaxJsonLength = $jsser.MaxJsonLength * 10
            $jsser.RecursionLimit = 99
        
        $script:json = $null
    }
    
    Context 'Valid Json' {
        
        It 'is valid Json' {
            #$powershellRepresentation = ConvertFrom-Json (Get-Content $azuredeploy -Raw)
            #should also work but throws an error for files > 2MB
            #http://stackoverflow.com/questions/17034954/how-to-check-if-file-has-valid-json-syntax-in-powershell
            
           { $script:json = $jsser.DeserializeObject((Get-Content $azuredeploy -Raw)) } | should Not Throw       
        }
    }
    
    Context "$azuredeploy properties" {
        
       BeforeAll {
           $script:json =  $jsser.DeserializeObject((Get-Content $azuredeploy -Raw))
       }
        
       It 'should include a schema' {
       
           $script:json.Keys -ccontains '$schema'| Should Be $true
           
       }
              
        It "should have a value of $SchemaUri" {
             $script:json['$schema'] | out-file test.txt -Append
            $script:json['$schema'] -eq $SchemaUri | Should be $true
        }
        
        It 'should include properties' {
            $script:json.Keys -ccontains 'parameters' | Should Be $true
            
        }
        
        It 'should include variables' {
            $script:json.Keys -ccontains 'variables' | Should Be $true
        }
        
        It 'should include resources' {
            $script:json.Keys -ccontains 'resources' | Should Be $true
        }
        
        It 'should include outputs' {
            $script:json.Keys -ccontains 'outputs' | Should Be $true
        }
        
        foreach ($Parameter in $script:json['parameters']) {
            
           foreach ($Item in $Parameter.Values) {
               
               It "parameter $($Parameter.Name) contains metadata" {
                   $item.Keys -ccontains 'metadata' | Should Be $true
               }
           }
            
        }
        
        AfterAll {
            $script:json = $null
            
        }
    }
    Context 'Deployment' {
        
        It 'should deploy' {
            #Test-AzureRmResourceGroupDeployment    
        }
    }
}


