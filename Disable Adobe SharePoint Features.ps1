<#
    .Synopsis
        Script to check for Adobe Acrobat, and disble SharePoint Features.
    .DESCRIPTION
        Script to check for Adobe Acrobat, and disble SharePoint Features.  This will prevent
        PDF files on SharePoint (on-prem and SharePoint Online) from being inadvertently
        Checked Out when a user clicks to open the file, which will not let another user open
        or edit the file until it is manually checked back in.  This will also prevent a prompt
        each time the file is opened for the user to Check Out/Check Out & Edit.
    .INPUTS
        None
    .OUTPUTS
        If Adobe isn't installed
        If SharePoint Features of Adobe are already disabled in the Windows Registry
        If SharePoint Features of Adobe are not already disabled in the Windows Registry, shows where the key was created to disable it
    .FUNCTIONALITY
        This is a script, not a PowerShell Module.  It is meant to automatically check and create
        the necessary Key in the Windows Registry to disable the SharePoint Features, which is a part
        of Adobe Acrobat Reader and Pro versions.  This script will need to be ran by a user with Administrator permissions,
        otherwise it will not work.
#>
# To edit Windows Registry, we need to run PowerShell as Administrator
# Taken from StackOverflow:  https://stackoverflow.com/questions/7690994/powershell-running-a-command-as-administrator
If (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Write-Host "To make changes to the Windows Registry, this script needs to be ran as Administrator!" -ForegroundColor Red -BackgroundColor Black
    Break
}
Else {
    # Adobe Acrobat keyname needed to disable SharePoint Features
    [string]$AdobeSPKey="cSharePoint"

    # Adobe Acrobat sub-keyname under $SharePointKey needed to disable SharePoint Features
    [string]$DisableSPKey="bDisableSharePointFeatures"

    # Sets default Windows Registry Path for Adobe
    [string]$DefaultAdobePath="HKLM:\SOFTWARE\Policies\Adobe"

    If (Test-Path $DefaultAdobePath) {
        # Gets the names under the Adobe Key in the Registry
        $GetAdobeKeyNames=Get-ChildItem -Path "HKLM:\SOFTWARE\Policies\Adobe\" -Recurse | Select-Object Name

        # Looks for the term FeatureLockDown (it is a Key) in $GetAdobeKeyNames, when it is matched, store that value
        # in $AdobeKeyName
        $AdobeKeyName=(($GetAdobeRegPath.Name) -match "FeatureLockDown$")

        # Replace HKEY_LOCAL_MACHINE with HKLM:
        [string]$HKLMPath=$AdobeKeyName.Replace('HKEY_LOCAL_MACHINE','HKLM:')

        # Test the path to the cSharePoint key to see if it exists, if so, skip creating it
        # If not, create the appropriate keys and value
        If (Test-Path "$HKLMPath\$AdobeSPKey") {
            Write-Host "Adobe SharePoint Features are already disabled!" -ForegroundColor Green -BackgroundColor Black
        }
        Else {
            Write-Host "Adobe SharePoint Features are not disabled, editing Windows Registry to disable..." -ForegroundColor Yellow -BackgroundColor Black

            # Creates a new Key called cSharePoint under FeatureLockDown
            Try {
                New-Item -Path "$HKLMPath\$AdobeSPKey" -Force | Out-Null
            }
            Catch {
                Write-Host "Could not create $AdobeSPKey in $HKLMPath !" -ForegroundColor Red -BackgroundColor Black
            }

            # Creates a sub-key called bDisableSharePointFeatures under cSharePoint, sets value to 1 to Disable SharePoint Features
            Try {
                Set-ItemProperty -Path "$HKLMPath\$AdobeSPKey" -Name $DisableSPKey -Type DWord -Value 1
            }
            Catch {
                Write-Host "Could not set value for $DisableSPKey in Registry!" -ForegroundColor Red -BackgroundColor Black
            }
        }
    }
    Else {
        Write-Host "Could not find Adobe in the Registry, is Adobe Acrobat installed?" -BackgroundColor Black -ForegroundColor Red
        Break
    }
}