<#
.Synopsis
   A PowerShell Module to find user accounts in Active Directory with all or only part of their last name
.DESCRIPTION
   Find a user account based off of all or part of a user's last name.
   This will search Active Directory OU's to locate all users with all or
   part of the provided last name.  Results will be stored in a hast table,
   converted into a new PSObject, and then all results in the hash table
   will be output to the host window.
.EXAMPLE
   FindUser -LastName markw -ADServerName AD01
   FindUser -LastName markw -ADServerName AD01 -Verbose
.INPUTS
   LastName
   ADServerName
   Verbose
.OUTPUTS
   obj
.NOTES
  This PowerShell Module assumes that you are a Domain Admin, and have the Windows RSAT Tools installed
  on your local machine, for access to Active Directory Users and Computers, and more importantly, the
  module ActiveDirectory.
.FUNCTIONALITY
  Find a user account based off of all or part of a user's last name.
  This will search Active Directory OU's based off of the AD server name specified
  to locate all users with all or part of the provided lastname.  Once found all
  results stored in the new PowerShell Object $obj will be output to the host window via values
  stored in the $Users hast table.  This uses the Get-ADUser cmdlet, -LDAPFilter and
  specifies -Server to search Active Directory.
#>

function FindUser {
  [CmdletBinding ()]

  param(
      [Parameter(Mandatory=$True,
          HelpMessage="Enter all or part of a user's last name")]
      [string]$LastName,

      [Parameter(Mandatory=$True,
          HelpMessage="Enter a valid Active Directory server name")]
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
    # against -Server $ADServerName.  If found, puts entries into $Users hash table.  Then a 
    # new PSObject is created based on the $Users hash table, and outputs values stored in the
    # newly created PSObject $obj to the host window.
    $i=0
    while ($i -eq 0) {
      Get-ADUser -Properties SamAccountName,GivenName,Surname,mail -LDAPFilter "(sn=*$LastName*)" -Server $ADServerName | ForEach-Object {
          $SamAccountName=$_.SamAccountName
          $GivenName=$_.GivenName
          $Surname=$_.Surname
          $EmailAddress=$_.mail

          $Users=[ordered]@{
            'User Initials'=$SamAccountName
            'First Name'=$GivenName
            'Last Name'=$Surname
            'Email Address'=$EmailAddress
          }

          $obj=New-Object -TypeName PSObject -Property $Users
          Write-Output $obj
        }

        # If $Users is null, meaning Get-ADUser could not find a user in Active Directory with the $LastName entered
        # and the hash table $Users contains nothing, this will prompt the user to re-enter the last name and will go
        # back and test again for Get-ADUser and output to screen if user is found.  If $Users is not empty, it will
        # exit and display output stored PSObject $obj to screen.
        if ($Users.count -eq 0) {
            Write-Output ""
            Write-Error "No users with the last name $LastName could be found, please try again!"
            Write-Output ""
            $LastName=$null
            $LastName=Read-Host "What is all or part of the user's last name?"
        }
        else {
            $i=1
        }
    }
}