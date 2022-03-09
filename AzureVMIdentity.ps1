Param
(
  [Parameter(Mandatory=$true)]
  [object]$WebHookData,
  [Parameter(Mandatory=$true)]
  [String] $rgname
)

if ($WebHookData) {
    Import-Module Az.Accounts
    Import-Module Az.Compute
    Import-Module Az.Resources
    
    # Ensures you do not inherit an AzContext in your runbook
    Disable-AzContextAutosave –Scope Process
    $AzContext = $null
    
    try {
        $AzAuth = Connect-AzAccount -Identity
        if (!$AzAuth -or !$AzAuth.Context) {
            throw $AzAuth
        }
        $AzContext = $AzAuth.Context
    }
    catch {
        throw [System.Exception]::new('Failed to authenticate Azure using System-Assigned Managed Identity', $PSItem.Exception)
    }
    
    Write-Output "Successfully authenticated with Azure using System-Assigned Managed Identity: $($AzContext | Format-List -Force | Out-String)"

    $requestBody = $WebHookData.requestBody | ConvertFrom-Json
    $vmResource = Get-AzResource -Id $requestBody.Subject
    
    $vm = Get-AzVM -Name $vmResource.Name -ResourceGroupName $vmResource.ResourceGroupName
    
    Update-AzVM -VM $vm -IdentityType SystemAssigned -ResourceGroupName $vmResource.ResourceGroupName
    
    $vm = Get-AzVM -Name $vmResource.Name -ResourceGroupName $vmResource.ResourceGroupName
    $id = $vm.Identity.PrincipalId
    
    $groupId = (Get-AzADGroup -DisplayName $rgname).ID
    Add-AzADGroupMember -MemberObjectId $id -TargetGroupObjectId $groupId
}
else {
    Write-Output 'no data'
}
