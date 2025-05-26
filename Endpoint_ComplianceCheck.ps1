<#
.SYNOPSIS
    Minimal script to check kernel, Edge, Firefox, and Chrome on a remote system,
    showing whether they're installed and if they are older than 60 days.
#>

# 1. Prompt for remote hostname
$RemoteComputer = Read-Host "Enter the hostname or IP address of the remote computer"

# 2. Define local array of paths
$paths = @(
    [PSCustomObject]@{
        FriendlyName = "Windows Kernel"
        Path         = "C:\Windows\System32\ntoskrnl.exe"
    },
    [PSCustomObject]@{
        FriendlyName = "Microsoft Edge (x86)"
        Path         = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    },
    [PSCustomObject]@{
        FriendlyName = "Mozilla Firefox"
        Path         = "C:\Program Files\Mozilla Firefox\firefox.exe"
    },
    [PSCustomObject]@{
        FriendlyName = "Google Chrome"
        Path         = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    }
)

# 3. Invoke-Command with $Using:paths
Invoke-Command -ComputerName $RemoteComputer -ScriptBlock {
    $today = Get-Date

    foreach ($item in $Using:paths) {

        # Attempt to get info
        if (Test-Path $item.Path) {
            $file = Get-Item $item.Path
            $daysOld = ($today - $file.LastWriteTime).Days
            $status = if ($daysOld -gt 60) { "[OUT OF COMPLIANCE]" } else { "OK" }

            # Print result
            [PSCustomObject]@{
                Component     = $item.FriendlyName
                FilePath      = $file.FullName
                LastWriteTime = $file.LastWriteTime
                DaysOld       = $daysOld
                Status        = $status
            }
        }
        else {
            # File not found
            [PSCustomObject]@{
                Component     = $item.FriendlyName
                FilePath      = $item.Path
                LastWriteTime = $null
                DaysOld       = $null
                Status        = "[NOT INSTALLED]"
            }
        }
    }
} -ErrorAction Stop -Verbose
