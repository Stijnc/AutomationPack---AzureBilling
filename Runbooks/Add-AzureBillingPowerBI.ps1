#region setup
$powerBIConnection = Get-AutomationConnection -Name 'AzureBillingPowerBIConnection'
$AzureRateCardConnection = Get-AutomationConnection 'AzureRateCardConnection'
$AzureRateCardCredential = [pscredential]::new($AzureRateCardConnection.userName,(ConvertTo-SecureString -String $AzureRateCardConnection.Password -AsPlainText -Force ))
#$token		
$authToken = Get-PBIAuthToken -Connection $powerBIConnection

$dataSetSchema = Get-PBIDataSet -authToken $authToken -name "Azure billing" -Verbose
if( -Not $dataSetSchema){
    
    #Create a new schema
    $dataSetSchema = @{
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
	$dataSetSchema = New-PBIDataSet -authToken $authToken -dataSet $dataSetSchema -defaultRetentionPolicy "basicFIFO" -Verbose
}

#get the usage data
$DataUsage = .\Get-AzureResourceUsageData.ps1 -credential $azureCredential

#Get the pricelist
$DataPrices = .\Get-AzureResourceCards.ps1 -Credential $AzureRateCardCredential -Offer $$AzureRateCardConnection.Offer -Currency $$AzureRateCardConnection.Currency -locale $$AzureRateCardConnection.Locale -regionInfo $$AzureRateCardConnection.RegionInfo -apiversion $$AzureRateCardConnection.ApiVersion

#for demo we clear the data
Clear-PBITableRows -authToken $authToken -dataSetId $dataSetSchema.Id -tableName 'ResourceConsumption' -Verbose
Clear-PBITableRows -authToken $authToken -dataSetId $dataSetSchema.Id -tableName 'Pricelist' -Verbose

$DataUsage | Add-PBITableRows -authToken $authToken -dataSetId $dataSetSchema.id -tableName 'ResourceConsumption' -batchSize 1000 -Verbose


$DataPrices | Add-PBITableRows -authToken $authToken -dataSetId $dataSetSchema.id -tableName 'Pricelist' -batchSize 1000 -Verbose
