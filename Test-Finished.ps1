<#
.SYNOPSIS
The purpose of this funciton is to allow for interactive simplified restarts of loops. 

.DESCRIPTION
The purpose of this funciton is to allow for simplified restarts of loops. The idea is to create the primary part of the script as a function,
or multiple functions, and then call the 'Test-Finished' to allow you the opportunity to either end the script cleanly or restart and run it again. 
One example of this is when used with a script for processing terminated employee accounts. If you have mulitple to run over and over again, you can
include this function in your script to make it easier to start over without having to sign back in each time. 

.EXAMPLE
#Begin Example Script

function Test-Finished {
    $finished = Read-Host "Do Need to assign any more licenses? Y or N" 
    IF ($finished -like "Y") {
        Start-AssignLicense
    }
    ELSE {
        Write-Host "Disconnecting from Graph" -ForegroundColor Blue
        Disconnect-Graph
    }
}


function Start-AssignLicense {
    try {
        $input = Read-Host "What user do you want to assign a license to?"
        $user = Get-MgUser -ConsistencyLevel eventual -Search '"DisplayName:$input"'
        $EmsSku = Get-MgSubscribedSku -All | Where SkuPartNumber -eq 'EMSPREMIUM'
        Set-MgUserLicense -UserId $user.id -AddLicenses @{SkuId = $EmsSku.SkuId} -RemoveLicenses @()
        #Run the test Finished function to either quit or restart the loop
        Test-Finished
    }
    catch {
        Write-Host $Error
    }

}

#connect Graph
Connect-Graph

#begin Loop
Start-AssignLicense

.LINK
https://seesmitty.com/how-to-script-call-forwarding-in-microsoft-teams-voice/#create-call-account
https://seesmitty.com/streamline-your-scripting-3-more-powershell-functions-i-find-helpful/

.NOTES
Author: Smitty
Date: 10/17/2023
Version: 1.0

#>


#This function is meant to be used inconjuntion with another function that calls this within it
function Test-Finished {

    $finished = Read-Host "Do Need to forward any more phone numbers? Y or N" 
    IF ($finished -like "Y") {
        #Call the function that contains the primary part of your script and includes the loop you are trying to repeat
        Start-LoopFromBeginning
    }
    ELSE {
        #exits the script closing out any connections you have or whatever you need to finish the end of your script. 
        Write-Host "Disconnecting from Graph" -ForegroundColor Blue
        Disconnect-Graph
    }
}
