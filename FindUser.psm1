<#
.Synopsis
   A PowerShell Module to find user accounts in Active Directory with all or only part of their last name
.DESCRIPTION
   Find a user account based off of all or part of a user's last name.
   This will search Active Directory OU's to locate all users with all or
   part of the provided last name.  Once found all results will be output to the 
   host window.
.EXAMPLE
   FindUser -LastName markw -ADServerName AD01
.INPUTS
   LastName
   ADServerName
.OUTPUTS
   getUser
.NOTES
  This PowerShell Module assumes that you are a Domain Admin, and have the Windows RSAT Tools installed
  on your local machine, for access to Active Directory Users and Computers, and more importantly, the
  module ActiveDirectory.
.FUNCTIONALITY
  Find a user account based off of all or part of a user's last name.
  This will search Active Directory OU's based off of the AD server name specified
  to locate all users with all or part of the provided lastname.  Once found all
  results will be output to the host window.  This uses the Get-ADUser cmdlet,
  -LDAPFilter and specifies -Server to search Active Directory.
#>

function FindUser {
  [CmdletBinding ()]

  param(
      [Parameter(Mandatory=$True)]
      [string]$LastName,

      [Parameter(Mandatory=$True)]
      [string]$ADServerName
      )

    # Array that valid domain controllers will be added to.
    [System.Collections.ArrayList]$DCs=@()

    # Find valid domain controllers, add to array for comparison later.
    Get-ADDomainController -Filter * | ForEach-Object {
      $DCs.Add($_.name) | Out-Null
    }

    # Verifies that $ADServerName is a valid domain controller and if not,
    # will continuously prompt user for a vaild domain controller name.
    while ($DCs -notcontains $ADServerName) {
      Write-Error "You've entered an invalid domain controller name, please try again!"
      Write-Output ""
      $ADServerName=$null
      $ADServerName=Read-Host "Which domain controller do you wish to search against?"
    }

    # Searches for the user in Active Directory using Get-ADUser and -LDAPFilter on $LastName
    # against -Server $ADServerName.  If found, displays user's Initials, First Name, Last Name,
    # and Email Address to screen.
    $i=0
    while ($i -eq 0) {
        $getUser=Get-ADUser -Properties SamAccountName,GivenName,Surname,mail -LDAPFilter "(sn=*$LastName*)" -Server $ADServerName | ForEach-Object {
            $SamAccountName=$_.SamAccountName
            $GivenName=$_.GivenName
            $Surname=$_.Surname
            $EmailAddress=$_.mail

            Write-Output "   User Initials:  $SamAccountName"
            Write-Output "   First Name   :  $GivenName"
            Write-Output "   Last Name    :  $Surname"
            Write-Output "   Email Address:  $EmailAddress"
            Write-Output ""
        }

        # If $getUser is null, meaning Get-ADUser could not find a user in Active Directory with the $LastName entered,
        # this will prompt the user to re-enter the last name and will go back and test again for Get-ADUser and output
        # to screen if user is found.  If $getUser is not null, will exit and display output to screen.
        if ($getUser -eq $null) {
            Write-Output ""
            Write-Error "No users with the last name $LastName could be found, please try again!"
            Write-Output ""
            $lastName=$null
            $lastName=Read-Host "What is all or part of the user's last name?"
        }
        else {
            $i=1
        }
    }
  # Writes $getUser value from the user's it has found to screen
  Write-Output ""
  Write-Output $getUser
}