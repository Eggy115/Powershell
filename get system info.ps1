$os = Get-CimInstance Win32_OperatingSystem
$processor = Get-CimInstance Win32_Processor
$memory = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum

"Operating System: $($os.Caption) $($os.Version)"
"Processor: $($processor.Name)"
"Memory: $([math]::Round($memory.Sum / 1MB, 2)) GB"
