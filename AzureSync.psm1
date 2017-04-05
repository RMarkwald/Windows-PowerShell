<#
.Synopsis
    PowerShell Module that runs manual Azure Active Directory Sync (AAD Sync) to sync Active Directory on-prem
    to Office 365
.DESCRIPTION
    Runs Azure Active Directory Sync (AAD Sync) to sync Active Directory on-prem
    to Office 365 manually.  It will connect to the AAD server specificed by the user, uses
    current user's credentials, and then performs a manual Start-ADSyncSyncCyle -PolicyType Initial
.EXAMPLE
    AzureSync -ServerName AADServerName
    ServerName:  AADServerName
.INPUTS
    ServerName
.OUTPUTS
    Status of AAD Sync on remote AAD Sync Server as either Success or AAD Sync Busy if already syncing
.NOTES
    This PowerShell Module assumes that you are a Domain Admin, and have the Windows RSAT Tools installed
    on your local machine, for access to Active Directory Users and Computers, and more importantly, the
    module ActiveDirectory.
#>

function AzureSync {
    [CmdletBinding ()]

    param(
      [Parameter(Mandatory=$True,
            HelpMessage="Enter the Azure AD Sync server name")]
      [string]$ServerName
      )

    $i=0
    while ($i -eq 0) {
        $Session=New-PSSession -ComputerName $ServerName

        if ($Session -eq $null) {
            Write-Error "Could not find $ServerName, please verify the name and try again!"
            Write-Output ""
            $ServerName=$null
            $ServerName=Read-Host "Please enter the AAD Sync server name"
        }
        else {
            $i=1
        }
    }

    Invoke-Command -Session $Session {
        Start-ADSyncSyncCycle -PolicyType Initial
    }
}