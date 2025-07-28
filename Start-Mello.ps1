<#
.SYNOPSIS
    Script to create a Start Menu shortcut for Mello.Ops and ensure AutoHotkey is downloaded and configured.

.DESCRIPTION
    This script downloads AutoHotkey, creates a Start Menu folder, and generates a shortcut to launch Mello.Ops.
    It includes error handling and modularized functions for better maintainability.

.NOTES
    Compatible with PowerShell 5.1 and later.
#>

#region Configuration
$InstallDir = Join-Path $env:LOCALAPPDATA 'Mello.Ops'
$ShortcutName = "Mello.Ops.lnk"
$ShortcutDisplayName = "Mello.Ops"
$AHKExecutableName = "AutoHotkey32.exe"
$AHKBinPath = Join-Path -Path $InstallDir -ChildPath "ahkbin"
$Arguments = Join-Path -Path $InstallDir -ChildPath "Mello.Ops.ahk"
$Description = "Start Mello.Ops"
$IconPath = Join-Path -Path $InstallDir -ChildPath "media\icons\Mello.Ops.ico"
$StartMenuFolderName = "Mello"
$AHKZipUrl = "https://www.autohotkey.com/download/2.0/AutoHotkey_2.0.19.zip"
$AHKZipPath = Join-Path -Path $InstallDir -ChildPath "AutoHotkey.zip"
$RepoZipUrl = "https://github.com/voltaire-toledo/Mello.Ops/archive/refs/heads/main.zip"
$RepoZipPath = Join-Path $env:TEMP "Mello.Ops-main.zip"
$TempExtractPath = Join-Path $env:TEMP "Mello.Ops-extract"
$StartMenuPath = [Environment]::GetFolderPath("StartMenu")
$StartMenuProgramsPath = Join-Path -Path $StartMenuPath -ChildPath "Programs"
$StartMenuFolderPath = Join-Path -Path $StartMenuProgramsPath -ChildPath $StartMenuFolderName
$ShortcutPath = Join-Path -Path $StartMenuFolderPath -ChildPath $ShortcutName
$TargetPath = Join-Path -Path $AHKBinPath -ChildPath $AHKExecutableName
$isRunFromUrl = $false
#endregion

#region Helper Functions
function New-Directory {
  # ╭───────────────────────────────────────────────────────╮
  # │ Function: New-Directory                               │
  # | General Create-Directory function with error handling │
  # ╰───────────────────────────────────────────────────────╯
  param([string] $Path)
  if (!(Test-Path -Path $Path -PathType Container)) {
    try {
      New-Item -ItemType Directory -Path $Path -Force | Out-Null
      Write-Output "Created directory: $Path"
    }
    catch {
      Write-Error "Failed to create directory ${Path}:  $($_.Exception.Message)"
      return $false
    }
  }
  return $true
}

function Get-AutoHotkey {
  # ╭─────────────────────────────────────────────────────╮
  # │ Function: Get-AutoHotkey                            │
  # | Download and extract an approved AutoHotkey version │
  # ╰─────────────────────────────────────────────────────╯
  if (!(New-Directory -Path $AHKBinPath)) {
    return $false
  }
  Write-Output "Downloading AutoHotkey..."
  try {
    # Force strong TLS
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Set up headers to mimic curl
    $headers = @{
        "User-Agent" = "curl/8.14.1"
        "Accept"     = "*/*"
        "Host"       = "www.autohotkey.com"
    }

    # Run the request
    Invoke-WebRequest -Uri $AHKZipUrl -Headers $headers -OutFile $AHKZipPath -ErrorAction Stop
    Expand-Archive -Path $AHKZipPath -DestinationPath $AHKBinPath -Force
    Remove-Item -Path $AHKZipPath -Force
    Write-Output "AutoHotkey downloaded and extracted to '$AHKBinPath'."
    return $true
  }
  catch {
    Write-Error "Failed to download or extract AutoHotkey: $($_.Exception.Message)"
    return $false
  }
}

function New-Shortcut {
  # ╭─────────────────────────────────────────────────╮
  # │ Function: New-Shortcut                          │
  # | Creates a shortcut to a target file or folder.  │
  # ╰─────────────────────────────────────────────────╯
  param(
    [string] $ShortcutPath,
    [string] $TargetPath,
    [string] $Arguments,
    [string] $Description,
    [string] $WorkingDirectory,
    [string] $IconPath,
    [string] $ShortcutDisplayName
  )
  try {
    if (Test-Path $ShortcutPath) {
      Write-Warning "Shortcut '$ShortcutDisplayName' already exists at '$ShortcutPath'. Overwriting."
    }
    $Shell = New-Object -ComObject WScript.Shell
    $Shortcut = $Shell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $TargetPath
    $Shortcut.Arguments = $Arguments
    $Shortcut.Description = $Description
    $Shortcut.WorkingDirectory = $WorkingDirectory
    $Shortcut.IconLocation = $IconPath
    $Shortcut.Save()

    # Rename the shortcut display name
    $objShell = New-Object -ComObject Shell.Application
    $objFolder = $objShell.Namespace((Split-Path -Path $ShortcutPath -Parent))
    $objItem = $objFolder.ParseName((Split-Path -Path $ShortcutPath -Leaf))
    $objItem.Name = $ShortcutDisplayName

    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Shell)
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($objShell)
    Remove-Variable -Name Shell, objShell
  }
  catch {
    Write-Error "Failed to create shortcut: $($_.Exception.Message)"
    return $false
  }
  Write-Output "Shortcut created at '$ShortcutPath'."
  return $true
}
#endregion

#region Main Logic Functions

function Install-FromUrl {
  # ╭───────────────────────────╮
  # │ Function: Install-FromUrl │
  # | Perform the installation  │
  # ╰───────────────────────────╯
  # Ensure install directory exists and copy repo contents if needed
  if (!(Test-Path -Path $InstallDir)) {
    if (!(New-Directory -Path $InstallDir)) {
      Write-Error "Failed to create install directory. Exiting script."
      exit 1
    }
    Write-Output "Copying files to $InstallDir..."
    try {
      try {
        Invoke-WebRequest -Uri $RepoZipUrl -OutFile $RepoZipPath -ErrorAction Stop
        if (Test-Path $TempExtractPath) { Remove-Item $TempExtractPath -Recurse -Force }
        Expand-Archive -Path $RepoZipPath -DestinationPath $TempExtractPath -Force
        $SourceFolder = Join-Path $TempExtractPath "Mello.Ops-main"
        Copy-Item -Path (Join-Path $SourceFolder '*') -Destination $InstallDir -Recurse -Force
        Remove-Item $RepoZipPath -Force
        Remove-Item $TempExtractPath -Recurse -Force
      }
      catch {
        Write-Error "Failed to download or extract Mello.Ops files: $($_.Exception.Message)"
        exit 1
      }
      Copy-Item -Path (Join-Path $PSScriptRoot '*') -Destination $InstallDir -Recurse -Force
      Write-Output "Files copied to $InstallDir."
    }
    catch {
      Write-Error "Failed to copy files: $($_.Exception.Message)"
      exit 1
    }
  }

  # Ensure AutoHotkey is downloaded and extracted.
  if (!(Test-Path -Path $AHKBinPath)) {
    if (!(Get-AutoHotkey)) {
      Write-Error "Failed to set up AutoHotkey. Exiting script."
      exit 1
    }
  }

  # Ensure the Start Menu folder exists.
  if (!(New-Directory -Path $StartMenuFolderPath)) {
    Write-Warning "Failed to create Start Menu folder. Using Start Menu root instead."
    $StartMenuFolderPath = $StartMenuPath
  }

  # Create the shortcut.
  $WorkingDirectory = $InstallDir
  if (!(New-Shortcut -ShortcutPath $ShortcutPath -TargetPath $TargetPath -Arguments $Arguments -Description $Description -WorkingDirectory $InstallDir -IconPath $IconPath -ShortcutDisplayName $ShortcutDisplayName)) {
    Write-Error "Failed to create the shortcut. Exiting script."
    exit 1
  }
}

function Run-FromLocal {
  Write-Output "Running from local copy. Using current directory as install directory."

  # Set InstallDir to the script's current directory for local execution
  $InstallDir = $PSScriptRoot
  $AHKBinPath = Join-Path -Path $InstallDir -ChildPath "ahkbin"
  $Arguments = Join-Path -Path $InstallDir -ChildPath "Mello.Ops.ahk"
  $IconPath = Join-Path -Path $InstallDir -ChildPath "media\icons\Mello.Ops.ico"
  $TargetPath = Join-Path -Path $AHKBinPath -ChildPath $AHKExecutableName

  # Ensure AutoHotkey is downloaded and extracted to the local ahkbin.
  if (!(Test-Path -Path $AHKBinPath)) {
    if (!(Get-AutoHotkey)) {
      Write-Error "Failed to set up AutoHotkey for local run. Exiting script."
      exit 1
    }
  }

  # Ensure the Start Menu folder exists.
  if (!(New-Directory -Path $StartMenuFolderPath)) {
    Write-Warning "Failed to create Start Menu folder. Using Start Menu root instead."
    $StartMenuFolderPath = $StartMenuPath
  }

  # Create the shortcut if it doesn't exist.
  if (!(Test-Path -Path $ShortcutPath)) {
    Write-Output "Shortcut '$ShortcutDisplayName' does not exist. Creating it now."
    $WorkingDirectory = $InstallDir
    if (!(New-Shortcut -ShortcutPath $ShortcutPath -TargetPath $TargetPath -Arguments $Arguments -Description $Description -WorkingDirectory $WorkingDirectory -IconPath $IconPath -ShortcutDisplayName $ShortcutDisplayName)) {
      Write-Error "Failed to create the shortcut. Exiting script."
      exit 1
    }
  }

  try {
    Start-Process -FilePath $ShortcutPath
    Write-Output "Shortcut '$ShortcutDisplayName' started."
  }
  catch {
    Write-Error "Failed to start the shortcut: $($_.Exception.Message)"
    exit 1
  }
}
#endregion

#region Main()
# Determine if the script was invoked from a URL or from a file.
if ($null -eq $MyInvocation.MyCommand.Path -or $MyInvocation.MyCommand.Path -eq '-') {
  write-host "$MyInvocation.MyCommand.Path is null or empty. Assuming script is run from URL."
  $isRunFromUrl = $true
}

if ($isRunFromUrl) {
  Install-FromUrl
}
else {
  Run-FromLocal
}
#endregion
