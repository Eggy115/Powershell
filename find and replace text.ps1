$folderPath = "C:\Users\User\Documents"
$oldString = "old text"
$newString = "new text"

Get-ChildItem -Path $folderPath -Filter *.txt -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName
    $content | ForEach-Object { $_ -replace $oldString, $newString } | Set-Content $_.FullName
}
