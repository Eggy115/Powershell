$computerName = "COMPUTERNAME"
$eventID = "1000"
$emailFrom = "sender@example.com"
$emailTo = "recipient@example.com"
$smtpServer = "smtp.example.com"

while ($true) {
    $events = Get-EventLog -LogName Application -ComputerName $computerName -InstanceId $eventID -Newest 1

    if ($events) {
        $subject = "Event $eventID detected on $computerName"
        $body = "The following event was detected: $($events.Message)"
        Send-MailMessage -From $emailFrom -To $emailTo -Subject $subject -Body $body -SmtpServer $smtpServer
    }

    Start-Sleep -Seconds 60
}
