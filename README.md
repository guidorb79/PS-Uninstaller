# PS-Uninstaller - PowerShell Script

## Description
PS-Uninstaller is a PowerShell script designed to list, navigate, and uninstall applications installed via the Microsoft Store (Appx packages) on Windows. The script provides a paginated, interactive interface where users can browse the installed applications, and select one for removal. The UI also includes optional **Nerd Fonts** support for improved table aesthetics and future UX tweaks. Use this script at your own risk and with an understanding of what the code does. This script came about after the constant reappearance of bloatware after Windows updates (ex: "Xbox apps on a PC of someone who doesn't play games).

## Features
- **Interactive UI**: Navigate using arrow keys, page up/down, and enter to select an app for removal.
- **Pagination**: Only displays a limited number of applications per page to improve readability.
- **Customizable UI**: Modify column widths, colors, and font styles.
- **Nerd Fonts Support**: Optionally display a more visually appealing table layout.
- **Sorting**: First WebApps, Store apps, then System apps.
- **Safe Removal**: Prompts for confirmation before uninstalling an application.

## Installation
1. **Download the script**
   ```powershell
   git clone https://github.com/guidorb79/PS-Uninstaller.git
   cd PS-Uninstaller
   ```
2. **Run the script with administrator privileges**
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope Process
   .\BorrarAppsx3.ps1
   ```
   Ensure you are running the script in an **elevated PowerShell session** (Run as Administrator).

## Usage
Once the script is executed, you can:
- **Navigate** using:
  - `↑` / `↓` (Up/Down) to move selection
  - `Page Up` / `Page Down` to navigate pages
  - `Enter` to uninstall the selected application (after confirmation)
  - `ESC` or `Q` to exit

## Configuration
At the beginning of the script, you can modify the following variables to customize the display:

### UI Appearance
```powershell
$useNerdFonts = 1   # Set to 1 to use NerdFonts, 0 for regular characters
$colIndexWidth = 3  # Width for index column
$colNameWidth = 46  # Width for application name column
$colTypeWidth = 6   # Width for application type column
$padding = 5        # Extra spacing between columns
```

### Colors
```powershell
$colorHeader = "Cyan"
$colorSelected = "Green"
$colorSystemApp = "DarkYellow"
$colorNormalApp = "White"
$colorWarning = "Yellow"
$colorError = "Red"
```
Modify these values to change the appearance of the table in the terminal.

## Notes
- **Only tested on Windows 11 24H2 (I will test later on other versions of 11 and 10)**
- Requires **PowerShell 5.1+**
- Designed to manage applications installed via **Appx/Microsoft Store** (does not remove traditional `.exe` applications)

## License
This project is licensed under the **GNU General Public License v3.0** (GPL-3.0). See `LICENSE` for details.

## Contributions
Pull requests and improvements are welcome! If you encounter issues, feel free to open an **issue** on GitHub.

---
