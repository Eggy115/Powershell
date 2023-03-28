$csvFilePath = "C:\Users\User\Documents\users.csv"

Get-ADUser -Filter * -Properties * | Select-Object Name, SamAccountName, EmailAddress | Export-Csv -Path $csvFilePath -NoTypeInformation
