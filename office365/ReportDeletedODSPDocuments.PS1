# ReportDeletedODSPDocuments.PS1
# A script to report deletion activity for SharePoint Online and OneDrive for Business documents based on information in the Office 365 audit log
# https://github.com/12Knocksinna/Office365itpros/blob/master/ReportDeletedODSPDocuments.PS1

$Operations = "FileDeleted, FileDeletedFirstStageRecycleBin, FileDeletedSecondStageRecycleBin" 
$StartDate = (Get-Date).AddDays(-90); $EndDate = (Get-Date) 
$FirstStageDeletions = 0; $SecondStageDeletions = 0; $UserDeletions = 0
$OutputFile = "c:\temp\ODSPFileDeletions.CSV"

CLS; Write-Host "Searching Office 365 Audit Records to find deletion records for SharePoint and OneDrive documents"
[array]$Records = (Search-UnifiedAuditLog -Operations $Operations -StartDate $StartDate -EndDate $EndDate -ResultSize 5000 -Formatted)
If ($Records.Count -eq 0) {
    Write-Host "No audit records for ODSP deletions found." }
Else {
    Write-Host "Processing" $Records.Count "ODSP file deletion records..."
    $Report = [System.Collections.Generic.List[Object]]::new() # Create output file 
    # Scan each audit record to extract information
    ForEach ($Rec in $Records) {
      $AuditData = ConvertFrom-Json $Rec.Auditdata
      Switch ($AuditData.Operation) {
       "FileDeleted" { # Normal deletion
          $Reason = "Deleted document from site"
          $UserDeletions++
         }
       "FileDeletedFirstStageRecycleBin" { # Deletion from the first stage recycle bin
          $Reason = "Deleted document from first stage recycle bin"
          $FirstStageDeletions++
         }
       "FileDeletedSecondStageRecycleBin" { # Deletion from the second stage recycle bin 
          $Reason = "Deleted document from second stage recycle bin"  
          $SecondStageDeletions++  
         }
      } #End switch 
      Switch ($AuditData.UserType) {
       "Regular" { # Normal user
           $DeletedBy = "User" 
           If ($AuditData.UserId -eq "SHAREPOINT\System") { $DeletedBy = "SharePoint System Account" }
       }
       "CustomPolicy" { #Retention policy
           $DeletedBy = "Retention policy"
       }
      } #End Switch

      If ([string]::IsNullOrWhiteSpace($AuditData.UserAgent)) {
          $UserAgent = "Background process" }
      Else {
          $UserAgent = $AuditData.UserAgent }
      $Workload = "SharePoint Online"
      If ($AuditData.SiteUrl -match "my.sharepoint.com") { $Workload = "OneDrive for Business"}

          $ReportLine = [PSCustomObject] @{
           TimeStamp    = Get-Date($AuditData.CreationTime) -format g
           "Deleted by" = $DeletedBy
           User         = $AuditData.UserId
           Site         = $AuditData.SiteURL
           "Folder"     = $AuditData.SourceRelativeURL
           "File name"  = $AuditData.SourceFileName
           Workload     = $Workload
           Reason       = $Reason
           Action       = $AuditData.Operation
           Client       = $UserAgent }        
      $Report.Add($ReportLine) }
}
Cls
Write-Host ("All done - ODSP Deletions in the period {0} to {1}" -f $StartDate, $EndDate)
Write-Host ""
Write-Host "Deletions from site:                    "  $UserDeletions
Write-Host "Deletions from first stage recycle bin: "  $FirstStageDeletions
Write-Host "Deletions from second stage recycle bin: " $SecondStageDeletions
Write-Host "----------------------------------------------------------------"
Write-Host ""
Write-Host "CSV file containing records is available in" $OutputFile

$Report | Sort-Object Reason, {$_.TimeStamp -as [datetime]} | Select-Object Timestamp, "Deleted By", Reason, User, "File Name", Site, Workload | Out-GridView
$Report | Sort-Object Reason, {$_.TimeStamp -as [datetime]} | Export-CSV -NoTypeInformation $OutputFile

# An example script used to illustrate a concept. More information about the topic can be found in the Office 365 for IT Pros eBook https://gum.co/O365IT/
# and/or a relevant article on https://office365itpros.com or https://www.practical365.com. See our post about the Office 365 for IT Pros repository # https://office365itpros.com/office-365-github-repository/ for information about the scripts we write.

# Do not use our scripts in production until you are satisfied that the code meets the need of your organization. Never run any code downloaded from the Internet without
# first validating the code in a non-production environment.
