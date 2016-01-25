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
#Get-AzureResourceCards
    param(
         $Credential
        ,$ApiVersion = '2015-06-01-preview'
        ,$Offer #https://azure.microsoft.com/en-us/support/legal/offer-details/
        ,$Currency = 'EUR'
        ,$Locale = 'en-us'
        ,$RegionInfo = 'BE'
    )
    
    $Token = Get-AzureAuthtoken -credential $Credential
    
    $Data = Get-AzureRateCard -token $token -Offer $AzureRateCardOfferName -Currency $Currency -locale $Locale -regionInfo $RegionInfo -apiversion $ApiVersion
    
    $Data

 
