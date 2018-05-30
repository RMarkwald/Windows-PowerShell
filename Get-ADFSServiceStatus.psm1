<#
.Synopsis
    Check ADFS servers' ADFS Service (DisplayName = AD FS Windows Service; Name = adfssrv) to check its status.
    Restart the service if the switch -Restart is given in case the service is in a Stopped state.
.DESCRIPTION
    Check ADFS Service's status on all ADFS servers.  If the service needs to be restarted, using the -Restart
    switch will restart the ADFS Service on the server(s).
.EXAMPLE
    Get-ADFSServiceStatus -ComputerName adfs01 -Restart
    Get-ADFSServiceStatus -ComputerName adfs01
    Get-ADFSServiceStatus -Hostname adfs01 -Restart
    Get-ADFSServiceStatus -ADFSServer adfs01
    Get-ADFSServiceStatus -ServerName adfs01 -Restart
    Get-ADFSServiceStatus -ServerName adfs01,adfs02 -Restart
    Get-ADFSServiceStatus -ServerName adfs01,adfs02
.INPUTS
    $ComputerName
.OUTPUTS
    None
.NOTES
    $ComputerName will accept multiple strings for multiple computer names, example:
    Get-ADFSServiceStatus -ServerName adfs01,adfs02
    Get-ADFSServiceStatus -ServerName adfs01,adfs02 -Restart
.FUNCTIONALITY
#>
function Get-ADFSServiceStatus {
    [CmdletBinding ()]

    Param(
        [Parameter(Mandatory=$True,
            HelpMessage="Enter ADFS server's FQDN (EX.  ADFS01,ADFS02")]
        [Alias('Hostname')]
        [Alias('ADFSServer')]
        [Alias('ServerName')]
        [ValidateNotNullorEmpty()]
        [string[]]$ComputerName,
        [switch]$Restart
    )

    # ADFS Service Name
    [string]$ADFSSRV='adfssrv'

    # Creates Script Block for Invoke-Command to run on remote server
    $ScriptBlock=$ExecutionContext.InvokeCommand.NewScriptBlock("Get-Service -Name $ADFSSRV")

    # For each $Server in $ComputerName, run the Script Block stored in $ScriptBlock to check the status
    # of the ADFS Service called "adfssrv".
    # If the switch -Restart is declared, then also restart the service on the remote server(s)
    ForEach ($Server in $ComputerName) {
        Invoke-Command -ComputerName "$Server" -ScriptBlock $ScriptBlock

        If ($Restart) {
            Write-Host "Restarting ADFS Service on $Server..." -ForegroundColor Green -BackgroundColor Black
            Invoke-Command -ScriptBlock {Restart-Service -Name $ADFSSRV -ComputerName "$Server"}
        }
        Else {
            Write-Output ""
            Write-Host "ADFS Service will NOT being restarted on $Server..." -ForegroundColor Red -BackgroundColor Black
        }
    }
}