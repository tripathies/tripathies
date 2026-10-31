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
Write-Host "Preflight complete. No provider was registered and no resource was deployed."
