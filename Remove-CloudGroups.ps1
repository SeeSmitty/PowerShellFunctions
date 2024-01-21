<#
.SYNOPSIS
The purpose of this script is to remove a user from all cloud based groups they are members of, including distribution lists, mail-enabled security
groups, M365 unified Groups, and Azure Security Groups. 

.DESCRIPTION
This script is meant for removing a single user from all their groups (typically in a termination script). This script uses an App Registrion for 
the MS Graph changes, and Exchange Online for the distribution group changes. This Function is meant to work with Hybrid Azure AD Tenants. 
Ideally, you are removing On-Prem Group membership in a separate part of your script.This is intent on focusing on the cloud or Azure 
side of things. Additionally, Invokce-WebRequest is used in place of the Microsoft Graph SDK equivalent because I had some issues with 
PowerShell 5.1. When running this in an on-prem environment, where PowerShell 5.1 is most common, Microsoft Graph was less consistent and 
left me with more errors. 

.PARAMETER username
This is a required parameter. This is the user who will be removed from all the groups in this function. This is intended to match the 
on-prem 'SamAccountName' attribute Ie. username. It is not intended to be a full UserPrincipalName, although this could be modified to 
use UPN with little difficulty. 

.LINK
https://seesmitty.com/streamline-your-scripting-3-powershell-functions-i-use-every-day/#remove-cloud-groups

.EXAMPLE
Remove-CloudGroups -username 'smitty'

.NOTES
Author: Smitty
Date: 1/21/23
Version 2.0

#>

function Remove-CloudGroups {
    param (
        [Parameter(Mandatory)][string]$username
    )
    #gather details about the user in question
    [string]$usrUri = 'https://graph.microsoft.com/v1.0/users?$filter' + ("=startswith(mail, '$userName')")
    $User = (Invoke-RestMethod -Method Get -Uri $usrUri -Headers $headers).value
    $userId = $user.id

    #collect information about what groups the user is a part of
    [string]$allGrpUri = "https://graph.microsoft.com/v1.0/users/$userId/transitiveMemberOf/microsoft.graph.group"
    $groups = (Invoke-RestMethod -Method Get -Uri $allGrpUri -Headers $headers).value

    foreach ($grp in $groups) {
        switch ($true) {
        ($grp.mailEnabled -eq $true -and $grp.groupTypes -ne 'Unified') { 
                #This will remove the member from any Distribution List 
                Remove-DistributionGroupMember -Identity $grp.Mail -Member $user.displayName -Confirm:$false
                Write-Host "Removed from" $grp.displayName "Distribution Group" -ForegroundColor DarkCyan
            }
        ($grp.GroupType -eq 'Universal, SecurityEnabled' -and $grp.groupTypes -ne 'Unified') {
                #This will remove the member from any Mail-Enabled Security Group
                Remove-DistributionGroupMember -Identity $grp.displayName -Member $user.displayName -Confirm:$false
                Write-Host "Removed from" $grp.displayName "Mail-Enabled Security Group" -ForegroundColor DarkGreen
            }
        ($grp.MailEnabled -eq $true -and $grp.SecurityEnabled -eq $false -and $grp.groupTypes -ne 'Unified') {
                #This will attempt to remove the member from any 
                Remove-DistributionGroupMember -Identity $grp.Mail -Member $user.displayName -Confirm:$false 
                Write-Host "Removed from" $grp.displayName "Group" -ForegroundColor DarkCyan
            }
        ($grp.onPremisesSyncEnabled -eq $true) {
                #Skip on-prem groups that are sycned - they were removed in the AD section
                Write-Host $grp.displayName "is on-prem synced - not removed" -ForegroundColor DarkYellow
            }
        ($null -ne $grp.MembershipRule) {
                #Skip Dynamic Groups as they will be removed when conditions are no longer met
                Write-Host $grp.displayName "is Dynamic - not removed" -ForegroundColor DarkYellow
            }
            Default {
                #Remove user from All Azure AD groups, and M365 Groups
                $id = $grp.id
                #You must have the /$ref included at the end of this URI or it will delete the user instead of the reference
                [string]$DelUri = "https://graph.microsoft.com/v1.0/groups/$id/members/$userId" + '/$ref' 
                Invoke-RestMethod -Method Delete -Uri $DelUri -Headers $headers -ErrorAction SilentlyContinue
                Write-host "Removed from" $grp.displayName -ForegroundColor Green
            }
        }
    } 
}


