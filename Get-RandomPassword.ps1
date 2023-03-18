<#
.SYNOPSIS
This function is meant to randomly select a number between your chosen values, and generate a password the length
of that number. 

.DESCRIPTION
The idea behind having a number chosen at random is to increase the randomness of the passwords that get created to 
maximize the complexity of someone trying to brute force a guess. If passwords are random lengths, then it would mean
a wider range of possible passwords.

.PARAMETER characters (optional)
This parameter is optional as it is predefined with a standard set of characters. However, if you wish to define your 
own character set, this parameter will alow you to do so. 

Default value is: "abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890!$%&/()=?}][{@#*+"

.PARAMETER minChar (optional)
Minimum number of characters you want to specify for the random values. MUST be less than or equal to maxChar value

Default values is: 25

.PARAMETER maxChar (optional)
Maximum number of characters you want to specify for the random values. Must be Greater than or equal to the minChar value.

Default Value is: 32

.EXAMPLE
-Using the default set of characters
Get-RandomPassword

-Using a custom set of characters
Get-RandomPassword -characters "yourRANDOMvaluesHERE1!"

-Using non-default minimum and maximum values for characters
Get-RandomPassword -minChar 12 -maxChar 16

-Using this function in a script
$securePassword = ConvertTo-SecureString -String (Get-RandomPassword) -AsPlainText -Force

-Using all available parameters
Get-RandomPassword -minChar 12 -maxChar 16 -characters "asdfghjlkuyt"

.NOTES
Author: SeeSmitty
Date: 3/17/2023
Version: 1.2.1

#>
function Get-RandomPassword {
    [CmdletBinding()]
    Param (
    [String]$characters = "abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890!$%&/()=?}][{@#*+",
    [Int32]$minChar = 25,
    [Int32]$maxChar = 32
    )
    if ($minChar -le $maxChar) {
        $length = Get-Random -Count 1 -InputObject ($minChar..$maxChar)
        $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
        $private:ofs=""
        Write-Host "Password is $length characters long"
        return [String]$characters[$random] 
    }else {
        Write-Host "Your Minimum $minChar is greater than your maximum $maxChar, please adjust your values and try again" -ForegroundColor Red
    }
       
}



