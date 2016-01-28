<#PSScriptInfo

.VERSION 0.1

.GUID b66368a8-dc27-481a-b4f3-dff65a6d42ee

.AUTHOR stijncallebaut

.COMPANYNAME Inovativ

.COPYRIGHT 

.TAGS AzureAutomation OMS Azure Usagedata Utility

.LICENSEURI http://choosealicense.com/licenses/mit/

.PROJECTURI https://github.com/azureautomation/runbooks/blob/master/Utility/Connect-AzureVM.ps1

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES

#>

#Requires -Module AzureRm

<# 

.DESCRIPTION 

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

#Get-iAzureResourceUsageDate

    param (
         $ReportedStartTime = "2015-05-01"
        ,$ReportedEndTime = ([datetime]::Today).toString('yyyy-MM-dd')
        ,[ValidateSet('Daily','Hourly')]
         $Granularity = 'Daily'
        ,$SubscriptionId
        ,$ShowDetails = $true
        ,$Credential
    )

    Add-AzureRmAccount -Credential $credential

    $ResourceData = @()
    $continuationToken = ""
    Do { 

        $usageData = Get-UsageAggregates `
            -ReportedStartTime $reportedStartTime `
            -ReportedEndTime $reportedEndTime `
            -AggregationGranularity $granularity `
            -ShowDetails:$showDetails `
            -ContinuationToken $continuationToken

        $ResourceData += $usageData.UsageAggregations.Properties | 
            Select-Object `
                UsageStartTime, `
                UsageEndTime, `
                @{n='SubscriptionId';e={$subscriptionId}}, `
                MeterCategory, `
                MeterId, `
                MeterName, `
                MeterSubCategory, `
                MeterRegion, `
                Unit, `
                Quantity, `
                @{n='Project';e={$_.InfoFields.Project}}, `
                InstanceData
        If ($usageData.NextLink) {
            $ContinuationToken = `
                [System.Web.HttpUtility]::`
                UrlDecode($usageData.NextLink.Split("=")[-1])
        } 
        Else {
            $ContinuationToken = ""
        }
    } Until (!$ContinuationToken)

    $ResourceData