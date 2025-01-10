$subscriptionId    = '' #Your subscription id 
$resourceGroupName = '' # your Resource Group 
$location = "" # The region where the test machine is arc enabled.

$account       = Connect-AzAccount 
$context       = Set-azContext -Subscription $subscriptionId 
$profile       = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile 
$profileClient = [Microsoft.Azure.Commands.ResourceManager.Common.rmProfileClient]::new( $profile ) 
$token         = $profileClient.AcquireAccessToken($context.Subscription.TenantId) 
$header = @{ 
   'Content-Type'='application/json' 
   'Authorization'='Bearer ' + $token.AccessToken 
}

$machines = get-azresource -ResourceType "Microsoft.HybridCompute/machines" -ResourceGroupName $resourceGroupName

foreach ($machine in $machines) {
    $machineName = $machine.Name
    $uri = [System.Uri]::new( "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.HybridCompute/machines/$machineName/licenseProfiles/default?api-version=2023-10-03-preview" ) 
    $contentType = "application/json"  
    $data = @{         
        location = $location; 
        properties = @{ 
            softwareAssurance = @{ 
                softwareAssuranceCustomer= $true; 
            }; 
        }; 
    }; 
    $json = $data | ConvertTo-Json; 
    $response = Invoke-RestMethod -Method PUT -Uri $uri.AbsoluteUri -ContentType $contentType -Headers $header -Body $json; 
    $response.properties
}
