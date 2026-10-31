[CmdletBinding()]
param(
 [Parameter(Mandatory=$true)][string]$Location,
 [string]$ExpectedSubscriptionId
)
$ErrorActionPreference="Stop"
if(-not(Get-Command az -ErrorAction SilentlyContinue)){throw "Azure CLI was not found. Install it first."}
$accountJson=az account show --output json 2>$null
if($LASTEXITCODE -ne 0 -or -not $accountJson){throw "No active Azure CLI session. Run az login first."}
$account=$accountJson|ConvertFrom-Json
Write-Host "Tenant:       $($account.tenantId)"
Write-Host "Subscription: $($account.name) [$($account.id)]"
Write-Host "User:         $($account.user.name)"
Write-Host "State:        $($account.state)"
if($account.state -ne "Enabled"){throw "Selected subscription is not Enabled."}
if($ExpectedSubscriptionId -and $account.id -ne $ExpectedSubscriptionId){throw "Active subscription does not match ExpectedSubscriptionId."}
$providers=@("Microsoft.Network","Microsoft.Web","Microsoft.App","Microsoft.DocumentDB","Microsoft.Storage","Microsoft.KeyVault")
foreach($namespace in $providers){
 $state=az provider show --namespace $namespace --query registrationState --output tsv 2>$null
 if($LASTEXITCODE -ne 0){Write-Warning "Unable to inspect provider $namespace.";continue}
 Write-Host ("{0,-28} {1}" -f $namespace,$state)
 if($state -ne "Registered"){Write-Warning "$namespace is not registered. Registration requires approval and suitable permissions."}
}
Write-Host ""
Write-Host "Location check: $Location"
az account list-locations --query "[?name=='$Location'].{name:name,displayName:displayName}" --output table
Write-Host ""
$flexLocations = az functionapp list-flexconsumption-locations --query "[].name" --output tsv 2>$null
if ($LASTEXITCODE -ne 0 -or -not $flexLocations) {
    Write-Warning "Could not retrieve the current Flex Consumption region list. Check Azure CLI version and network access."
} elseif ($flexLocations -notcontains $Location) {
    throw "Region $Location is not currently listed for Functions Flex Consumption. Choose a region returned by az functionapp list-flexconsumption-locations."
} else {
    Write-Host "Flex Consumption region: supported"
    $nodeVersions = az functionapp list-flexconsumption-runtimes --location $Location --runtime node --query "[].version" --output tsv 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Node runtime versions in $($Location): $($nodeVersions -join ', ')"
        if ($nodeVersions -notcontains "22") {
            throw "Node.js 22 is not listed for Flex Consumption in $Location. Update the runtime version or choose another supported region."
        }
    } else {
        Write-Warning "Could not verify Node.js runtime availability for Flex Consumption."
    }
}
Write-Host "Preflight complete. No provider was registered and no resource was deployed."
