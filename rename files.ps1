$files = Get-ChildItem -Path "C:\Users\User\Documents"

foreach ($file in $files) {
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $newName = "$timestamp" + "_" + $file.Name
    Rename-Item $file.FullName $newName
}
