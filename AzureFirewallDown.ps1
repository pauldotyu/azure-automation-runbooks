Param
(
  [Parameter(Mandatory=$true)]
  [String] $rgname,
  [Parameter(Mandatory=$true)]
  [String] $fwname
)

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

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

# Deallocate
$firewall=Get-AzFirewall -ResourceGroupName $rgname -Name $fwname
$firewall.Deallocate()
$firewall | Set-AzFirewall
