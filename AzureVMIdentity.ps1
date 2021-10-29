param (
    [object]$WebHookData
)

if ($WebHookData) {
    $groupName = "AibBuilder"
    Import-Module Az.Accounts
    Import-Module Az.Compute
    Import-Module Az.Resources
    
    # Ensures you do not inherit an AzContext in your runbook
    Disable-AzContextAutosave –Scope Process
    $AzAuth = Connect-AzAccount -Identity
    
    $requestBody = $WebHookData.requestBody | ConvertFrom-Json
    $vmResource = Get-AzResource -Id $requestBody.Subject
    
    $vm = Get-AzVM -Name $vmResource.Name -ResourceGroupName $vmResource.ResourceGroupName
    
    Update-AzVM -VM $vm -IdentityType SystemAssigned -ResourceGroupName $vmResource.ResourceGroupName
    
    $vm = Get-AzVM -Name $vmResource.Name -ResourceGroupName $vmResource.ResourceGroupName
    $id = $vm.Identity.PrincipalId
    
    #$groupId = (Get-AzADGroup -DisplayName $groupname).ID
    #Add-AzADGroupMember -MemberObjectId $id -TargetGroupObjectId $groupId
}
else {
    Write-Output 'no data'
}
