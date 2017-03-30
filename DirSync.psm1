<#
    .Synopsis
        PowerShell Module that runs manual Azure Active Directory Sync (AAD Sync) to sync Active Directory on-prem
        to Office 365
    .DESCRIPTION
        Runs Azure Active Directory Sync (AAD Sync) to sync Active Directory on-prem
        to Office 365 manually.  It will connect to the AAD server specificed by the user, uses
        current user's credentials, and then performs a manual Start-ADSyncSyncCyle -PolicyType Initial
    .EXAMPLE
        dirSync
        ServerName:  AADServerName
    .INPUTS
        ServerName
    .OUTPUTS
        Status of AAD Sync on remote AAD Sync Server as either Success or AAD Sync Busy if already syncing
#>

function dirSync {
    [CmdletBinding ()]

    param(
      [Parameter(Mandatory=$True)]
      [string]$ServerName
      )

    $session=New-PSSession -ComputerName $ServerName
    Invoke-Command -Session $session {
        Start-ADSyncSyncCycle -PolicyType Initial
    }
}