<#
.SYNOPSIS
    Converts time in seconds to a DateTime object in Eastern Daylight Time or a timezone of your choosing.

.DESCRIPTION
    Converts time in seconds to a DateTime object in Eastern Daylight Time or a timezone of your choosing. The intent is to use this function
    to convert the timestamp returned by the any REST API that delivers time results in the form os seconds since the UNIX EPOCH (1/1/1970).

.PARAMETER Seconds
    The number of seconds since the UNIX EPOCH (1/1/1970) to convert to a DateTime object. Generally from a REST API.

.EXAMPLE
    ConvertFrom-Seconds -Seconds 1623686400

    Monday, June 14, 2021 12:00:00 AM

.NOTES
    Author: SeeSmitty
    Date: 5/29/2023
    Version: 1.0
#>

function ConvertFrom-Seconds {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [double]$Seconds
    )
    process {
        $apiDate = (Get-Date -Date "01-01-1970") + ([System.TimeSpan]::FromSeconds(($Seconds)))
        $timeZoneOffset = [System.TimeSpan]::FromHours(-4)  # Eastern Daylight Time offset
        $convertedDateTime = $apiDate.Add($timeZoneOffset)
    }
    end {
        return $convertedDateTime
    }
}
