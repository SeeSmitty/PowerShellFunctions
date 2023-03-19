<#
.SYNOPSIS
This is a function that uses MS Graph API to send a mail message. 
This is an alternative to using Send-MgMailMessage via Microsoft Graph PowerShell SDK.

.PARAMETER from
This allows for setting a default from email address, but will also accept an alternative address as well

.PARAMETER subject
THis is a one liner for the subject of the email

.PARAMETER recipient
This is the person, or distribution list that will receive the email

.PARAMETER content
This is what will be in the email. this can be a single line, can be HTML in the form of a variable, or HTML formated text. 
Recommend using HTML saved as a variable.

.EXAMPLE
Send-GraphMailMessage -from "me@domain.com" -recipient "You@domain.com" -subject "This is my Subject" -content "<h2>This is a Header 2 HTML line of text</h2>"

.NOTES
This requires that you have already retrieved a $token for MS Graph access, and that your App Registrion has the Mail.Send Application permission granted. 

Author: Smitty
Date Updated: 2/15/2023

#>
function Send-GraphMailMessage {
    [CmdletBinding()]
    Param (
        [string]$from = "myEmail@domain.com",   
        [Parameter(Mandatory)][string]$subject,
        [Parameter(Mandatory)][string]$recipient, 
        [Parameter(Mandatory)]$content
    )
    begin {
        $headers = @{
            "Authorization" = "Bearer $token"
            "Content-Type" = "application/json"
        }
        $data = @{
            message = @{
                subject = $subject
                body = @{
                    ContentType = "HTML"
                    Content = $content
                }
                toRecipients = @(
                    @{
                        EmailAddress = @{
                            Address = $recipient
                        }
                    }
                )
            }          
        }
        $apiUrl = "https://graph.microsoft.com/v1.0/users/$from/sendMail"
    }
    process {
        $json = $data | ConvertTo-Json -Depth 4
        Invoke-RestMethod -Uri $apiURL -Headers $headers -Method POST -Body $json
    }
}
