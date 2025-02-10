# Ensure PowerShell uses UTF-8 encoding for correct character rendering
[console]::OutputEncoding = [System.Text.Encoding]::UTF8

# User-configurable settings
$useNerdFonts = 1   # Set to 1 to use NerdFonts, 0 for regular characters

$colIndexWidth = 3   # Space for the index number (up to 3 digits)
$colTypeWidth = 6    # Space for the type column (max 6 characters)
$colNameWidth = 46   # Fixed width for the application name
$padding = 5         # Extra spacing between columns
$colExtraInfoWidth = 0

# Define colors
$colorHeader = "Cyan"
$colorSelected = "Green"
$colorSystemApp = "DarkYellow"
$colorNormalApp = "White"
$colorWarning = "Yellow"
$colorError = "Red"

# Define table characters based on font type
if ($useNerdFonts -eq 1) {
    $charHorizontal = [char]0x2500  # ─
    $charVertical = [char]0x2502    # │
    $charCornerTopLeft = [char]0x256D   # ╭
    $charCornerTopRight = [char]0x256E  # ╮
    $charCornerBottomLeft = [char]0x2570 # ╰
    $charCornerBottomRight = [char]0x256F # ╯
} else {
    $charHorizontal = "-"
    $charVertical = "|"
    $charCornerTopLeft = "+"
    $charCornerTopRight = "+"
    $charCornerBottomLeft = "+"
    $charCornerBottomRight = "+"
}

# Get the list of provisioned and installed applications, excluding developer mode apps
$apps = Get-AppxPackage -AllUsers | Where-Object { $_.SignatureKind -ne 'Developer' } | Select-Object Name, PackageFullName, SignatureKind, PublisherId, Version, InstallLocation, Architecture

# Ensure the apps list is not null or empty
if (-not $apps) {
    Write-Host "No applications found." -ForegroundColor $colorError
    exit
}

# Sort applications by SignatureKind first, then by Name
$apps = $apps | Sort-Object SignatureKind, Name

# Determine terminal window width and height
$windowWidth = $host.UI.RawUI.WindowSize.Width
$windowHeight = $host.UI.RawUI.WindowSize.Height - 6  # Leave space for instructions and borders
$pageSize = [Math]::Min($windowHeight, $apps.Count)  # Ensure the page size does not exceed available apps
$totalPages = [Math]::Ceiling($apps.Count / $pageSize)
$currentPage = 0

if ($windowWidth -gt ($colIndexWidth + $colNameWidth + $colTypeWidth + (2 * $padding))) {
    $colExtraInfoWidth = $windowWidth - ($colIndexWidth + $colNameWidth + $colTypeWidth + (2 * $padding))
}

# Function to truncate strings
function Truncate-String {
    param (
        [string]$inputString,
        [int]$maxLength
    )
    if ($inputString.Length -gt $maxLength) {
        return $inputString.Substring(0, $maxLength - 1) + "…"
    }
    return $inputString
}

# Function to display paginated list
function Show-AppsList {
    param ($currentPage, $selectedIndex)
    Clear-Host
    Write-Host "Installed Applications List (Page $($currentPage+1) of $totalPages, Use UP/DOWN to navigate, PGUP/PGDN to switch pages, ENTER to select, ESC/Q to exit):" -ForegroundColor $colorHeader
    
# Cabecera de la tabla
$headerLine = "$charCornerTopLeft" +
              ([string]::new($charHorizontal, $colIndexWidth + 2)) +
              "$charTJoint" +
              ([string]::new($charHorizontal, $colNameWidth + 2)) +
              "$charTJoint" +
              ([string]::new($charHorizontal, $colTypeWidth + 2))

if ($colExtraInfoWidth -gt 0) {
    $headerLine += "$charTJoint" + ([string]::new($charHorizontal, $colExtraInfoWidth + 2))
}

$headerLine += "$charCornerTopRight"
Write-Host $headerLine

# Cabecera con los títulos de las columnas
$header = "$charVertical {0,-$colIndexWidth} $charVertical {1,-$colNameWidth} $charVertical {2,-$colTypeWidth}" -f "No", "Application Name", "Type"
if ($colExtraInfoWidth -gt 0) {
    $header += " $charVertical Extra Info"
}
Write-Host $header

# Línea inferior de la cabecera
$headerBottom = "$charCornerBottomLeft" +
                ([string]::new($charHorizontal, $colIndexWidth + 2)) +
                "$charTJoint" +
                ([string]::new($charHorizontal, $colNameWidth + 2)) +
                "$charTJoint" +
                ([string]::new($charHorizontal, $colTypeWidth + 2))

if ($colExtraInfoWidth -gt 0) {
    $headerBottom += "$charTJoint" + ([string]::new($charHorizontal, $colExtraInfoWidth + 2))
}
$headerBottom += "$charCornerBottomRight"
Write-Host $headerBottom

    $startIndex = $currentPage * $pageSize
    $endIndex = [Math]::Min($startIndex + $pageSize, $apps.Count) - 1
    $visibleApps = $apps[$startIndex..$endIndex]
    
    if (-not $visibleApps) {
        Write-Host "No applications to display." -ForegroundColor $colorWarning
        return
    }
    
    foreach ($app in $visibleApps) {
        $index = [array]::IndexOf($apps, $app)
        
        # Truncate strings if necessary
        $appName = Truncate-String -inputString $app.Name -maxLength $colNameWidth
        $appType = Truncate-String -inputString $app.SignatureKind -maxLength $colTypeWidth

        # Use extra info to differentiate duplicate entries
        $extraInfo = ""
        if ($colExtraInfoWidth -gt 0) {
            $extraInfo = " $charVertical Ver. $($app.Version), Arch: $($app.Architecture)"
        }
        
        # Define colors for different types
        $appTypeColor = if ($app.SignatureKind -eq "System") { $colorSystemApp } else { $colorNormalApp }
        $isSelected = ($index -eq $selectedIndex)
        
        # Print row with formatting
        if ($isSelected) {
            Write-Host ">" -ForegroundColor $colorSelected -NoNewline
        } else {
            Write-Host " " -NoNewline
        }
        Write-Host (" {0,-$colIndexWidth} $charVertical" -f $index) -NoNewline
        Write-Host (" {0,-$colNameWidth} $charVertical" -f $appName) -ForegroundColor $colorNormalApp -NoNewline
        Write-Host (" {0,-$colTypeWidth}" -f $appType) -ForegroundColor $appTypeColor -NoNewline
        if ($colExtraInfoWidth -gt 0) { Write-Host $extraInfo -ForegroundColor $colorNormalApp }
    }
}

# Navigation and selection
$selectedIndex = 0

while ($true) {
    Show-AppsList -currentPage $currentPage -selectedIndex $selectedIndex
    
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode
    
    switch ($key) {
        38 { if ($selectedIndex -gt 0) { $selectedIndex-- } }  # Up Arrow
        40 { if ($selectedIndex -lt $apps.Count - 1) { $selectedIndex++ } }  # Down Arrow
        33 { if ($currentPage -gt 0) { $currentPage--; $selectedIndex = $currentPage * $pageSize } }  # Page Up
        34 { if ($currentPage -lt ($totalPages - 1)) { $currentPage++; $selectedIndex = $currentPage * $pageSize } }  # Page Down
        27 { Write-Host "Exiting..."; exit }  # Escape Key
        81 { Write-Host "Exiting..."; exit }  # Q Key
        13 {
            $selectedApp = $apps[$selectedIndex]
            $confirmation = Read-Host "Are you sure you want to uninstall $($selectedApp.Name)? (Y/N)"
            if ($confirmation -match "^[Yy]$") {
                Write-Host "Uninstalling $($selectedApp.Name) ..."
                Get-AppXPackage -AllUsers -Name $selectedApp.PackageFullName | Remove-AppXPackage
                Write-Host "Uninstallation completed."
                exit
            }
        }
    }
}
