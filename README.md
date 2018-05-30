# **Learning Windows PowerShell, PowerShell for Active Directory, and PowerShell for Office 365**

I am learning to PowerShell and manage our local Active Directory, and Office 365 tenant.  I have been learning and creating scripts,
modules, and am constantly trying to automate tasks that require logins to multiple servers, GUI's, and have everything done quickly
via one PowerShell window.  I am still learning, and tweaking my scripts and modules.  I've gotten "brave", and will start posting them
as I see fit.  I welcome critique and suggestions for doing things in a more effecient/effective manner.  Always looking to learn
something new!


## **Prerequisites**

Windows PowerShell
Get-ExecutionPolicy set accordingly to allow running of scripts on your system, so make sure you are aware of changing the policy,
what it will do and mean for you system!


## **Module Deployment**

In Windows, there will be a directory C:\Users\<user's name>\Documents\WindowsPowerShell, which should have a directory called
Modules, and a file called Microsoft.PowerShell_profile.ps1.  Microsoft.PowerShell_profile.ps1 is used to import modules each time a
PowerShell window is opened.  To do this, add something similar to yours and then save the file:

Import-Module AzureSync,FindUser

Inside the Modules directory, you should have setup a folder with the .psm1 module name.  If your module is called AzureSync.psm1, the
folder should be called AzureSync, and AzureSync.psm1 should be in the AzureSync directory.  Your structure would be:

C:\Users\<user's name>\Documents\WindowsPowerShell\Modules\AzureSync\AzureSync.psm1


## **Using from PowerShell**

Once you've got the directory stucture setup, modules in place, if you open a PowerShell window, you should be able to then type the
Function name (which is located inside of the .psm1 file), and it should then run that Function.  For the example of the PowerShell Module
AzureSync.psm1, with a PowerShell window open, type in:  AzureSync, and it should run the Function called AzureSync inside of AzureSync.psm1.


## **Author(s)**

Ryan Markwald


## **License**

This project is licensed under the MIT License - see the LICENSE.md file for details


## **Acknowledgments**

Microsoft PowerShell Team
Jeffrey Snover & Jason Helmick for the MVA videos on PowerShell
The book "PowerShell in a month of lunches" by Don Jones & Jeffery D. Hicks
The Internet
