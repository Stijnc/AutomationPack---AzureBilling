#Get-AzureResourceCards
    param(
         $Credential
        ,$ApiVersion = '2015-06-01-preview'
        ,$Offer #https://azure.microsoft.com/en-us/support/legal/offer-details/
        ,$Currency = 'EUR'
        ,$Locale = 'en-us'
        ,$RegionInfo = 'BE'
    )
    
    $token = Get-AzureAuthtoken -credential $Credential
    
    $data = Get-AzureRateCard -token $token -Offer $AzureRateCardOfferName -Currency $Currency -locale $Locale -regionInfo $RegionInfo -apiversion $ApiVersion
    
    $data

 
