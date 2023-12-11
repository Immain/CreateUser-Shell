# Write Messages to Screen
Write-Host "------------------------------------------------------------------------------------------------------------------------"
Write-Host "This script will create a new user in Azure AD and assign a random password to the account"
Write-Host "Please use this script responsibly and ensure you have the correct permissions to create users in Azure AD"
Write-Host "If you are experiencing issues with this script, please contact your SharePoint Administrator"
Write-Host "------------------------------------------------------------------------------------------------------------------------"

# Requires: AzureAD PowerShell Module
Import-Module AzureAD

# Connect to Azure AD
Connect-AzureAD

# Function to generate a password with at least one number
function Generate-Password {
    $Password = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 13 | % { [char]$_ })
    $Number = Get-Random -Minimum 0 -Maximum 10
    $Password = $Password.Insert($Number, (Get-Random -Minimum 0 -Maximum 10))
    return $Password
}

# Function to generate a unique user principal name with the number 1
function Get-UniqueUserPrincipalName($UserPrincipalName) {
    $originalUserPrincipalName = $UserPrincipalName
    $counter = 1

    while (Get-AzureADUser -Filter "userPrincipalName eq '$UserPrincipalName@changeme.com'") {
        $UserPrincipalName = "$originalUserPrincipalName$counter"
        $counter++
    }

    return $UserPrincipalName + "@changeme.com"
}

# Generate Random Password
$Password = Generate-Password

# Ask for User Information
$FirstName = Read-Host -Prompt "Enter User's First Name"
$LastName = Read-Host -Prompt "Enter User's Last Name"

# Take the first letter of the first name and the full last name to create the username in lowercase
$UserPrincipalName = $FirstName.Substring(0,1).ToLower() + $LastName.ToLower()

# Check if the user principal name is already in use, if so, make it unique
$UserPrincipalName = Get-UniqueUserPrincipalName $UserPrincipalName

# Take the first letter of the first name and the full last name to create the email alias
$MailNickName = $FirstName.Substring(0,1) + $LastName
$Department = Read-Host -Prompt "Enter User's Department"
$AlternateEmail = Read-Host -Prompt "Enter User's Alternate Email Address"

# Set Display Name using First and Last Name
$DisplayName = $FirstName + " " + $LastName

# Create PasswordProfile object
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = $Password

# Create User
New-AzureADUser -AccountEnabled $true -GivenName $FirstName -Surname $LastName -DisplayName $DisplayName -PasswordProfile $PasswordProfile -UserPrincipalName $UserPrincipalName -MailNickName $MailNickName -Department $Department -OtherMails $AlternateEmail

Write-Host "------------------------------------------------------------------------------------------------------------------------"
# Print the user principal name to the screen
Write-Host "User's User Principal Name is $UserPrincipalName"

# Print the display name to the screen
Write-Host "User's Display Name is $DisplayName"

# Print Password to screen
Write-Host "User's Pre-Generated Password is $Password - Please provide this to the user and ask them to change it on first login"
Write-Host "------------------------------------------------------------------------------------------------------------------------"
