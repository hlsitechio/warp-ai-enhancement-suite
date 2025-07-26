# Warp AI Enhancement Suite - One-Click Installation
# https://github.com/hlsitechio/warp-ai-enhancement-suite

Write-Host "🚀 WARP AI ENHANCEMENT SUITE INSTALLER" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Warning "PowerShell 7.5+ required. Current version: $($PSVersionTable.PSVersion)"
    Write-Host "Install PowerShell 7.5+: https://github.com/PowerShell/PowerShell"
    exit 1
}

# Create installation directory
$InstallPath = "$env:USERPROFILE\Documents\WarpAI-Enhancement"
Write-Host "📁 Creating installation directory: $InstallPath" -ForegroundColor Green
New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null

# Download and install scripts
$Scripts = @(
    "StartupSystem.ps1",
    "ConversationLogger.ps1", 
    "EmbeddedGeminiTools.ps1",
    "WarpAI-Fallback.ps1",
    "WindowsStartup.ps1"
)

Write-Host "⬇️ Downloading enhancement scripts..." -ForegroundColor Green
foreach ($Script in $Scripts) {
    $Url = "https://raw.githubusercontent.com/hlsitechio/warp-ai-enhancement-suite/main/scripts/$Script"
    $Path = Join-Path $InstallPath $Script
    
    try {
        Invoke-RestMethod -Uri $Url -OutFile $Path
        Write-Host "   ✅ Downloaded $Script" -ForegroundColor DarkGreen
    } catch {
        Write-Error "❌ Failed to download $Script: $($_.Exception.Message)"
        exit 1
    }
}

# Set up logging directory
$LogPath = "G:\master_it\log"
Write-Host "📝 Setting up logging directory: $LogPath" -ForegroundColor Green
New-Item -ItemType Directory -Path $LogPath -Force -ErrorAction SilentlyContinue | Out-Null

# Configure Windows startup (optional)
Write-Host ""
$StartupChoice = Read-Host "🚀 Configure Windows startup automation? (y/N)"
if ($StartupChoice -eq 'y' -or $StartupChoice -eq 'Y') {
    Write-Host "⚙️ Configuring Windows startup integration..." -ForegroundColor Green
    
    # Create startup script
    $StartupScript = Join-Path $InstallPath "WindowsStartup.ps1"
    
    # Add to Windows startup (current user)
    $StartupFolder = [Environment]::GetFolderPath("Startup")
    $ShortcutPath = Join-Path $StartupFolder "WarpAI-Enhancement.lnk"
    
    # Create PowerShell shortcut
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = "powershell.exe"
    $Shortcut.Arguments = "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$StartupScript`""
    $Shortcut.WorkingDirectory = $InstallPath
    $Shortcut.Save()
    
    Write-Host "   ✅ Windows startup configured" -ForegroundColor DarkGreen
}

# Test installation
Write-Host ""
Write-Host "🧪 Testing installation..." -ForegroundColor Green

try {
    # Load main startup system
    $StartupPath = Join-Path $InstallPath "StartupSystem.ps1"
    if (Test-Path $StartupPath) {
        . $StartupPath
        Write-Host "   ✅ StartupSystem.ps1 loaded successfully" -ForegroundColor DarkGreen
    } else {
        throw "StartupSystem.ps1 not found"
    }
} catch {
    Write-Error "❌ Installation test failed: $($_.Exception.Message)"
    exit 1
}

# Success message
Write-Host ""
Write-Host "🎉 INSTALLATION COMPLETE!" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green
Write-Host ""
Write-Host "✅ All enhancement scripts installed" -ForegroundColor DarkGreen
Write-Host "✅ Logging system configured" -ForegroundColor DarkGreen
Write-Host "✅ System tested and operational" -ForegroundColor DarkGreen
Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Restart Warp AI to see the enhanced welcome message"
Write-Host "2. Try the AI-to-AI collaboration features"
Write-Host "3. Test crash recovery (your context will be preserved!)"
Write-Host ""
Write-Host "📚 Documentation: https://github.com/hlsitechio/warp-ai-enhancement-suite"
Write-Host "🐛 Issues: https://github.com/hlsitechio/warp-ai-enhancement-suite/issues"
Write-Host ""
Write-Host "Thank you for trying the Warp AI Enhancement Suite! 🙏" -ForegroundColor Yellow
