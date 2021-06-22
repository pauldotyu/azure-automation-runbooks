Param
(
  [Parameter(Mandatory=$true)]
  [String] $rgname,
  [Parameter(Mandatory=$true)]
  [String] $fwname
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

# Deallocate
$firewall=Get-AzFirewall -ResourceGroupName $rgname -Name $fwname
$firewall.Deallocate()
$firewall | Set-AzFirewall