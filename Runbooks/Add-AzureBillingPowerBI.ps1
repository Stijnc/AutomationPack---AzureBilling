
<#PSScriptInfo

.VERSION 1.0

.GUID 1bc7a10a-bb16-4b37-85d6-90cc7f5ee310

.AUTHOR StijnCallebaut

.COMPANYNAME 

.COPYRIGHT 

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#>

<# 

.DESCRIPTION 
 description 

#> 

<#
.SYNOPSIS 

.DESCRIPTION
    
.PARAMETER AzureSubscriptionName
    
    
.PARAMETER AzureOrgIdCredential
    

.PARAMETER ServiceName
    

.PARAMETER VMName    
     

.EXAMPLE
    

.NOTES
    AUTHOR: Stijn Callebaut
    LASTEDIT: Jan 6, 2016 
#>
#region setup
'test'
$PowerBIConnection = Get-AutomationConnection -Name 'AzureBillingPowerBIConnection'
$AzureRateCardConnection = Get-AutomationConnection 'AzureRateCardConnection'
$AzureRateCardCredential = [pscredential]::new($AzureRateCardConnection.userName,(ConvertTo-SecureString -String $AzureRateCardConnection.Password -AsPlainText -Force ))
#$token        
$AuthToken = Get-PBIAuthToken -Connection $powerBIConnection
write-output 'test'
$DataSetSchema = Get-PBIDataSet -AuthToken $AuthToken -Name "Azure billing" -Verbose
If( -Not $DataSetSchema){
    
    #Create a new schema
    $DataSetSchema = @{
         name = "Azure billing"
         tables = @(
            @{
             name = "ResourceConsumption"
             columns = @( 
                    @{name = "UsageStartTime"; dataType = "DateTime"  }
                    @{name = "UsageEndTime"; dataType = "DateTime"  }
                    @{name='SubscriptionId'; dataType = 'String'},
                    @{name='MeterCategory'; dataType = 'String'}
                    @{name='MeterId'; dataType = 'String'},
                    @{name='MeterName'; dataType = 'String'},
                    @{name='MeterSubCategory'; dataType = 'String'},
                    @{name='MeterRegion'; dataType = 'String'},
                    @{name='Unit'; dataType = 'String'},
                    @{name='Quantity'; dataType = 'String'},
                    @{name='Project'; dataType = 'String'},
                    @{name='InstanceData'; dataType = 'String'}
                    )}
            , 
            @{
             name = "Pricelist"
             columns = @( 
                    @{name='MeterId'; dataType='String'},
                    @{name='MeterName'; dataType = 'String'},
                    @{name='MeterCategory'; dataType = 'String'},
                    @{name='MeterSubCategory'; dataType = 'String'}
                    @{name='Unit'; dataType = 'String'},
                    @{name='MeterTags'; dataType = 'String'},
                    @{name='MeterRegion'; dataType = 'String'},
                    @{name='MeterRates'; dataType = 'String'},
                    @{name='EffectiveDate'; dataType = 'DateTime'},
                    @{name='IncludedQuantity'; dataType = 'String'},
                    @{name='Currency'; dataType = 'String'}            
                    )}
        )}
    $DataSetSchema = New-PBIDataSet -AuthToken $authToken -DataSet $dataSetSchema -DefaultRetentionPolicy "basicFIFO" -Verbose
}

#get the usage data
$DataUsage = .\Get-AzureResourceUsageData.ps1 -Credential $AzureCredential

#Get the pricelist
$RateCardProperties = @{
    Credential = $AzureRateCardCredential
    Offer = $AzureRateCardConnection.Offer
    Currency = $AzureRateCardConnection.Currency
    Locale = $AzureRateCardConnection.Locale
    RegionInfo = $AzureRateCardConnection.RegionInfo
    ApiVersion = $AzureRateCardConnection.ApiVersion
}

$DataPrices = .\Get-AzureResourceCards.ps1 @RateCardProperties

$DataUsage | Add-PBITableRows -AuthToken $AuthToken -DataSetId $DataSetSchema.id -TableName 'ResourceConsumption' -BatchSize 1000 -Verbose


$DataPrices | Add-PBITableRows -AuthToken $AuthToken -DataSetId $DataSetSchema.id -TableName 'Pricelist' -BatchSize 1000 -Verbose
