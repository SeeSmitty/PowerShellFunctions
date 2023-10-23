<#
    .SYNOPSIS
    Removes a network printer based on the provided IP address or printer name.

    .DESCRIPTION
    This function removes a network printer based on the input provided. It can remove a printer using either its IP address or printer name.

    .PARAMETER printer
    Specifies the IP address or printer name to remove.

    .EXAMPLE
    Remove-NetworkPrinter -printer "192.168.1.1"
    Removes the network printer with the IP address 192.168.1.1.

    .EXAMPLE
    Remove-NetworkPrinter -printer "PrinterName"
    Removes the network printer with the name "PrinterName."

    .NOTES
    Author: Smitty
    Date: 10/3/2023
    Version: 1.0
    #>
    
function Remove-NetworkPrinter {
    
    param (
        [Parameter()]
        [string]$printer
    )

    switch -Regex ($printer) {
        '\b(?<ipv4>\d{1,3}(?:\.\d{1,3}){3})\b' {
            if ($Matches['ipv4'] -as [IPAddress]) {
                # It's an IP address - Removing Printer by IP Address
                $printerToRemove = Get-WmiObject -Class Win32_Printer | Where-Object { $_.PortName -eq $printer }
                Write-Host "Removing Printer by IP Address"
            }
        }
        default {
            # This is the default case for printer name processing
            $printerToRemove = Get-WmiObject -Class Win32_Printer | Where-Object { $_.ShareName -eq $printer }
            Write-Host "Its not an IP Address - Removing by Printer Name"
        }
    }

    if ($printerToRemove) {
        #Removes the printer
        $printerToRemove.Delete()
        Write-Host "Printer removed successfully."
    }
    else {
        Write-Host "Printer not found or removal failed."
    }
}

Remove-NetworkPrinter -printer "Printer1"
