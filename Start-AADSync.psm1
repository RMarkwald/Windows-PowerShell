<#
.Synopsis
    PowerShell Module that runs manual Azure Active Directory Sync (AAD Sync) to sync Active Directory on-prem
    to Office 365
.DESCRIPTION
    Runs Azure Active Directory Sync (AAD Sync) to sync Active Directory on-prem
    to Office 365 manually.  It will connect to the AAD server specificed by the user, uses
    current user's credentials, and then performs:  Start-ADSyncSyncCyle -PolicyType Initial
    Using the -Credential parameter will prompt for a Username and Password to connect the PSSession
    as a different user.
.EXAMPLE
    Start-AADSync -ComputerName AADServerName
.EXAMPLE
    Start-AADSync -ComputerName AADServerName -Credential
.EXAMPLE
    PS C:\Windows\system32> Start-AADSync

    cmdlet Start-AADSync at command pipeline position 1
    Supply values for the following parameters:
    (Type !? for Help.)
    ComputerName: AzureSyncServer
.INPUTS
    ComputerName
.OUTPUTS
    Status of AAD Sync on remote AAD Sync Server as either Success or AAD Sync Busy if already syncing

    PSComputerName  RunspaceId                           Result
    --------------  ----------                           ------
    AzureSyncServer Unique RunspaceID listed here        Success
.NOTES
#>
function Start-AADSync {
    [CmdletBinding ()]

    Param(
      [Parameter(Mandatory=$True,
            HelpMessage="Enter the Azure AD Sync server name")]
      [string]$ComputerName,
      [switch]$Credential
      )

    $NOTFOUND=$null
    $i=0
    While ($i -eq 0) {
        If ($Credential) {
            $Session=New-PSSession -ComputerName $ComputerName -ErrorAction SilentlyContinue -ErrorVariable NOTFOUND -Credential (Get-Credential)
        }
        Else {
            $Session=New-PSSession -ComputerName $ComputerName -ErrorAction SilentlyContinue -ErrorVariable NOTFOUND
        }

        If ($NOTFOUND) {
            Write-Error "Could not connect to $ComputerName, please verify the computer name and try again!"
            Write-Output ""
            $ComputerName=$null
            $ComputerName=Read-Host "Please enter the AAD Sync server name"
        }
        Else {
            $i=1
        }
    }

    Invoke-Command -Session $Session {
        Start-ADSyncSyncCycle -PolicyType Initial
    }
}