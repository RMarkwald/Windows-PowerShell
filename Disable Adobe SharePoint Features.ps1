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
        of Adobe Acrobat Reader and Pro versions.
#>

# To edit Windows Registry, we need to run PowerShell as Administrator
# Taken from StackOverflow:  https://stackoverflow.com/questions/7690994/powershell-running-a-command-as-administrator
if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    break
}

[string]$DefaultPath="HKLM:\SOFTWARE\Policies\Adobe"
[string]$Free11="$DefaultPath\Acrobat Reader\11.0\FeatureLockDown"
[string]$Free10="$DefaultPath\Acrobat Reader\10.0\FeatureLockDown"
[string]$Pro2015="$DefaultPath\Adobe Acrobat\2015\FeatureLockDown"
[string]$FreeDC="$DefaultPath\Acrobat Reader\DC\FeatureLockDown"
[string]$Pro11="$DefaultPath\Adobe Acrobat\11.0\FeatureLockDown"
[string]$Pro10="$DefaultPath\Adobe Acrobat\10.0\FeatureLockDown"

$regPath=@($Free11,$Free10,$Pro2015,$FreeDC,$Pro10,$Pro11)

$SharePointKeyName="cSharePoint"
$Name="bDisableSharePointFeatures"

if (Test-Path $DefaultPath) {
    $i=0

    # Checks to see if SharePoint Features are already disabled for Adobe Acrobat,
    # if so, sets $i to 1
    ForEach ($SharePointKey in $regPath) {
        $version="$SharePointKey\$SharePointKeyName"
        if (Test-Path $version) {
            $i=1
            break
        }
        else {
            $i=0
        }
    }

    # If $i equals 1, then the SharePoint key exists and there is no need to re-create it
    if ($i -eq 1) {
        Write-Output "Adobe SharePoint Features are already disabled!"
        Write-Output "Skipping creation of Registry Key..."
    }
    else {
        # If $i equals 0, the SharePoint key doesn't currently exist, so find the version of
        # Adobe Acrobat installed, and create the cSharePoint key accordingly
        ForEach ($version in $regPath) {
            if (Test-Path $version) {
                $newPath="$version\$SharePointKeyName"
                Write-Output "Setting DWord Value of 1 for $Name at $newPath..."
                New-Item -Path $newPath -Force | Out-Null
                Set-ItemProperty -Path $newPath -Name $Name -Type DWord -Value 1
            }
        }
    }
}
else {
    # If Adobe is not installed, throw an error that Adobe Acrobat isn't on the system
    Write-Error "Could not find Adobe Acrobat in the Windows Registry, is Adobe Acrobat installed???"
}

Write-Output ""
Write-Output ""
Write-Output "DONE!"
Write-Output "Press any key to exit script..."
$x=$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
break