Param
(
  [Parameter(Mandatory=$true)]
  [String] $rgname,
  [Parameter(Mandatory=$true)]
  [String] $vnname,
  [Parameter(Mandatory=$true)]
  [String] $fwname,
  [Parameter(Mandatory=$true)]
  [String] $ipname
)

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

$connection = Get-AutomationConnection -Name AzureRunAsConnection

# Wrap authentication in retry logic for transient network failures
$logonAttempt = 0
while(!($connectionResult) -and ($logonAttempt -le 10))
{
    $LogonAttempt++
    # Logging in to Azure...
    $connectionResult = Connect-AzAccount `
                            -ServicePrincipal `
                            -Tenant $connection.TenantID `
                            -ApplicationId $connection.ApplicationID `
                            -CertificateThumbprint $connection.CertificateThumbprint

    Start-Sleep -Seconds 30
}

# Re-allocate
$firewall=Get-AzFirewall -ResourceGroupName $rgname -Name $fwname
$vnet = Get-AzVirtualNetwork -ResourceGroupName $rgname -Name $vnname
$pip = Get-AzPublicIpAddress -ResourceGroupName $rgname -Name $ipname
$firewall.Allocate($vnet, $pip)
$firewall | Set-AzFirewall