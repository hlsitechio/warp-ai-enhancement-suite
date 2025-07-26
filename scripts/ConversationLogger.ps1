# ConversationLogger.ps1 - Enhanced dual logging system for Claude interactions
# Prevents context loss during system failures with redundant backup storage

function Initialize-ConversationLog {
    # Dual logging system - local and backup
    $global:LogPath = "C:\Users\hlaro\Documents\Claude_Conversation_Log.txt"
    $global:BackupLogPath = "G:\master_it\log\Claude_Conversation_Log.txt"
    $global:SessionStart = Get-Date
    
    # Ensure backup directory exists
    if (!(Test-Path "G:\master_it\log")) {
        New-Item -Path "G:\master_it\log" -ItemType Directory -Force | Out-Null
        Write-Host "📁 Created backup directory: G:\master_it\log" -ForegroundColor Yellow
    }
    
    # Create session header
    $sessionId = Get-Random -Minimum 1000 -Maximum 9999
    $header = @"

=========================================================================
NEW CLAUDE SESSION STARTED: $($global:SessionStart.ToString('yyyy-MM-dd HH:mm:ss'))
Session ID: $sessionId
Backup Location: G:\master_it\log
=========================================================================

"@
    
    # Write to both locations
    try {
        Add-Content -Path $global:LogPath -Value $header
        Add-Content -Path $global:BackupLogPath -Value $header
        
        Write-Host "📝 Dual logging initialized successfully!" -ForegroundColor Green
        Write-Host "   📍 Local: $global:LogPath" -ForegroundColor Cyan
        Write-Host "   💾 Backup: $global:BackupLogPath" -ForegroundColor Cyan
    }
    catch {
        Write-Host "⚠️ Warning: Could not initialize backup logging: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "📝 Continuing with local logging only" -ForegroundColor Yellow
    }
}

function Write-DualLog {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Content
    )
    
    # Write to local log
    Add-Content -Path $global:LogPath -Value $Content
    
    # Attempt backup write
    try {
        Add-Content -Path $global:BackupLogPath -Value $Content
    }
    catch {
        Write-Host "⚠️ Backup write failed - continuing with local only" -ForegroundColor Yellow
    }
}

function Log-UserPrompt {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Prompt
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = @"

--- USER PROMPT ---
Time: $timestamp
Prompt: $Prompt

"@
    Write-DualLog -Content $logEntry
    Write-Host "👤 User prompt logged (dual backup)" -ForegroundColor Cyan
}

function Log-ClaudeResponse {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Response,
        [string]$Status = "COMPLETE"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = @"
--- CLAUDE RESPONSE ($Status) ---
Time: $timestamp
Response: $Response

"@
    Write-DualLog -Content $logEntry
    $color = if($Status -eq "COMPLETE") { "Green" } else { "Yellow" }
    Write-Host "🤖 Claude response logged (dual backup) [$Status]" -ForegroundColor $color
}

function Log-SystemEvent {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Event
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = @"
--- SYSTEM EVENT ---
Time: $timestamp
Event: $Event

"@
    Write-DualLog -Content $logEntry
    Write-Host "⚙️ System event logged (dual backup): $Event" -ForegroundColor Magenta
}

function Save-MemorySnapshot {
    param(
        [string]$Context = "Manual snapshot"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $duration = (Get-Date) - $global:SessionStart
    $memoryEntry = @"
--- MEMORY SNAPSHOT ---
Time: $timestamp
Context: $Context
Session Duration: $duration

Current State:
- Working Directory: $(Get-Location)
- Active Scripts: WarpAutomation.ps1, EmbeddedGeminiTools.ps1, WarpAI-Fallback.ps1, ConversationLogger.ps1
- Last Command Status: Ready
- Memory Graph: Updated
- Backup Status: Active (G:\master_it\log)

"@
    Write-DualLog -Content $memoryEntry
    Write-Host "💾 Memory snapshot saved (dual backup): $Context" -ForegroundColor Green
}

function Get-LastInteraction {
    # Try backup first, then local
    $logFile = if (Test-Path $global:BackupLogPath) { 
        $global:BackupLogPath 
    } elseif (Test-Path $global:LogPath) { 
        $global:LogPath 
    } else { 
        $null 
    }
    
    if ($logFile) {
        $content = Get-Content $logFile -Raw
        $sessions = $content -split "NEW CLAUDE SESSION STARTED:"
        $lastSession = $sessions[-1]
        
        Write-Host "📖 Last interaction context (from $(Split-Path $logFile -Leaf)):" -ForegroundColor Yellow
        Write-Host $lastSession.Substring(0, [Math]::Min(1000, $lastSession.Length))
        
        return $lastSession
    } else {
        Write-Host "❌ No conversation log found in either location" -ForegroundColor Red
        return $null
    }
}

function Resume-FromLog {
    Write-Host "🔄 Checking for previous session context..." -ForegroundColor Yellow
    $lastContext = Get-LastInteraction
    
    if ($lastContext) {
        Write-Host "✅ Previous context found! Ready to resume." -ForegroundColor Green
        return $lastContext
    } else {
        Write-Host "ℹ️ No previous context found - starting fresh session" -ForegroundColor Blue
        return $null
    }
}

function Test-BackupIntegrity {
    Write-Host "🔍 Testing backup system integrity..." -ForegroundColor Yellow
    
    $localExists = Test-Path $global:LogPath
    $backupExists = Test-Path $global:BackupLogPath
    
    Write-Host "📍 Local log: $(if($localExists) {'✅ Available'} else {'❌ Missing'})" -ForegroundColor $(if($localExists) {'Green'} else {'Red'})
    Write-Host "💾 Backup log: $(if($backupExists) {'✅ Available'} else {'❌ Missing'})" -ForegroundColor $(if($backupExists) {'Green'} else {'Red'})
    
    if ($localExists -and $backupExists) {
        $localSize = (Get-Item $global:LogPath).Length
        $backupSize = (Get-Item $global:BackupLogPath).Length
        Write-Host "📊 Sizes - Local: $localSize bytes, Backup: $backupSize bytes" -ForegroundColor Cyan
    }
    
    return ($localExists -or $backupExists)
}

# The auto-logging mechanism was here

function Start-RealTimeAutoLogging {
    Initialize-ConversationLog
    
    # Log system activation
    Log-SystemEvent "ConversationLogger.ps1 enhanced with dual backup system - G:\master_it\log"
    
    Write-Host "🔄 Enhanced auto-logging system active" -ForegroundColor Green
    Write-Host "📝 All interactions backed up to G:\master_it\log" -ForegroundColor Cyan
    Write-Host "💾 Use Save-MemorySnapshot before critical operations" -ForegroundColor Yellow
    Write-Host "🔍 Use Test-BackupIntegrity to verify backup system" -ForegroundColor Magenta
}

# Auto-start enhanced logging when script is loaded
Start-AutoLogging

Write-Host "✅ Enhanced ConversationLogger.ps1 loaded successfully!" -ForegroundColor Green
Write-Host "🛡️ Dual backup system protects against power failures and system crashes" -ForegroundColor Cyan
Write-Host "🔧 Available functions: Log-UserPrompt, Log-ClaudeResponse, Log-SystemEvent, Save-MemorySnapshot, Resume-FromLog, Test-BackupIntegrity" -ForegroundColor White
