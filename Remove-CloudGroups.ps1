<#
.SYNOPSIS
This Function is meant to work with Hybrid Azure AD Tenants. Ideally, you are removing On-Prem Group membership in a separate part of your script.
This is intent on focusing on the cloud or Azure side of things. 

.DESCRIPTION
This script is meant for removing a single user from all their groups (typically in a termination script). This script uses an App Registrion for 
the MS Graph changes, and Exchange Online for the distribution group changes. 

.PARAMETER username
This is a required parameter. This is the user who will be removed from all the groups in this function. This is intended to match the 
on-prem 'SamAccountName' attribute Ie. username. It is not intended to be a full UserPrincipalName, although this could be modified to 
use UPN with little difficulty. 

.EXAMPLE
Remove-CloudGroups -username 'smitty'

.NOTES
Author: Smitty
Date: 2/20/23

#>

function Remove-CloudGroups {
    param (
        [Parameter(Mandatory)][string]$username
    )
    #gather details about the user in question
    [string]$usrUri = 'https://graph.microsoft.com/v1.0/users?$filter'+("=startswith(mail, '$userName')")
    $User = (Invoke-RestMethod -Method Get -Uri $usrUri -Headers $headers).value
    $userId = $user.id

    #collect information about what groups the user is a part of
    [string]$allGrpUri = "https://graph.microsoft.com/v1.0/users/$userId/transitiveMemberOf/microsoft.graph.group"
    $groups = (Invoke-RestMethod -Method Get -Uri $allGrpUri -Headers $headers).value

    foreach($grp in $groups){
        #remove user from distribution groups
        If($grp.mailEnabled -eq $true){
            try {
                #This will attempt to remove the member from any Distribution List or Mail-Enabled Security Group
                Remove-DistributionGroupMember -Identity $grp.displayName -Member $user.displayName -Confirm:$false
                Write-Host "Removed from" $grp.displayName -ForegroundColor Green
            }
            catch {
                #Indicates that a connection to Exchange Online PowerShell is not connected
                Write-host $grp.displayName "Needs Removed via Exchange Online" -ForegroundColor DarkYellow
            }
        
        #Skip on-prem groups that are sycned - they were removed in the AD section
        }elseif ($grp.onPremisesSyncEnabled -eq $true) {
            Write-Host $grp.displayName "is on-prem synced - not removed" -ForegroundColor DarkYellow

        #Remove user from All Azure AD groups, and M365 Groups
        }else {
            #You must have the /$ref included at the end of this URI or it will delete the user instead of the reference
            [string]$DelUri =  "https://graph.microsoft.com/v1.0/groups/$grp.id/members/$userId"+'/$ref' 
            Invoke-RestMethod -Method Delete -Uri $DelUri -Headers $headers -ErrorAction SilentlyContinue
            Write-host "Removed from" $grp.displayName -ForegroundColor Green
        }
    }
    
}
