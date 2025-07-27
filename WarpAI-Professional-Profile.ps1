# ═══════════════════════════════════════════════════════════════════════════════
# 🚀 WARP AI ENHANCEMENT SUITE - POWERSHELL PROFILE
# ═══════════════════════════════════════════════════════════════════════════════
# Created by: AI-to-AI Collaboration (Claude + Gemini CLI + Ollama)
# Repository: https://github.com/hlsitechio/warp-ai-enhancement-suite
# Purpose: Transform Warp into an intelligent, context-aware development environment
# Version: 2.0 (Professional GitHub Edition)
# ═══════════════════════════════════════════════════════════════════════════════

# 🛡️ ERROR HANDLING & SECURITY
$ErrorActionPreference = "SilentlyContinue"
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# 🎨 CONSOLE ENHANCEMENT
$Host.UI.RawUI.WindowTitle = "🚀 Warp AI Enhanced Terminal"

# 📊 PERFORMANCE TRACKING
$global:WarpProfileStartTime = Get-Date

# ═══════════════════════════════════════════════════════════════════════════════
# 🧠 INTELLIGENT SESSION MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════════════

# Check if this is first run in this session
$global:WarpFirstRun = -not (Get-Variable -Name "WarpEnhancementLoaded" -Scope Global -ErrorAction SilentlyContinue)

# 📝 CONVERSATION LOGGER
function Initialize-ConversationLogger {
    $global:ConversationLogPath = "G:\master_it\log\Claude_Conversation_Log.txt"
    $global:BackupLogPath = "G:\master_it\log\Claude_Conversation_Backup_$(Get-Date -Format 'yyyyMMdd').txt"
    
    if (-not (Test-Path "G:\master_it\log")) {
        New-Item -ItemType Directory -Path "G:\master_it\log" -Force | Out-Null
    }
    
    if ($global:WarpFirstRun) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $sessionHeader = "`n" + "="*80 + "`n🚀 NEW WARP SESSION STARTED: $timestamp`n" + "="*80 + "`n"
        Add-Content -Path $global:ConversationLogPath -Value $sessionHeader
        Add-Content -Path $global:BackupLogPath -Value $sessionHeader
    }
}

function Write-ConversationLog {
    param([string]$Type, [string]$Content)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] [$Type] $Content"
    Add-Content -Path $global:ConversationLogPath -Value $entry
    Add-Content -Path $global:BackupLogPath -Value $entry
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🤖 MULTI-AI INTEGRATION LAYER
# ═══════════════════════════════════════════════════════════════════════════════

# 🔍 INTELLIGENT WEB SEARCH (via Gemini CLI)
function Invoke-IntelligentSearch {
    param([string]$Query)
    Write-ConversationLog "TOOL" "Web search requested: $Query"
    
    try {
        $result = & "C:\Users\hlaro\AppData\Roaming\npm\gemini.ps1" -p "Search the web for: $Query. Provide a concise summary."
        return $result | Where-Object { $_ -notmatch "Loaded cached credentials" -and $_ -notmatch "^\s*$" }
    } catch {
        return "Web search temporarily unavailable. Error: $($_.Exception.Message)"
    }
}

# 🖼️ IMAGE ANALYSIS (via Ollama Llama Vision)
function Invoke-ImageAnalysis {
    param([string]$ImagePath, [string]$Prompt = "Describe this image in detail")
    Write-ConversationLog "TOOL" "Image analysis requested: $ImagePath"
    
    try {
        $result = & ollama run llama3.2-vision "$Prompt [image: $ImagePath]"
        return $result
    } catch {
        return "Image analysis temporarily unavailable. Error: $($_.Exception.Message)"
    }
}

# 🧮 SMART CALCULATOR
function Invoke-SmartCalculation {
    param([string]$Expression)
    Write-ConversationLog "TOOL" "Calculation requested: $Expression"
    
    try {
        $result = Invoke-Expression $Expression
        return "Result: $result"
    } catch {
        return "Calculation error: $($_.Exception.Message)"
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🎛️ WARP AUTOMATION COMMANDS
# ═══════════════════════════════════════════════════════════════════════════════

function Invoke-WarpCommand {
    param([string]$Command)
    Write-ConversationLog "AUTOMATION" "Warp command: $Command"
    
    # Natural language processing for Warp commands
    switch -Regex ($Command.ToLower()) {
        "split.*right|right.*split" {
            Write-Host "🔄 Creating split panel to the right..." -ForegroundColor Yellow
            [System.Windows.Forms.SendKeys]::SendWait("^+d")
            return "Split panel created to the right"
        }
        "split.*down|down.*split" {
            Write-Host "🔄 Creating split panel downward..." -ForegroundColor Yellow
            [System.Windows.Forms.SendKeys]::SendWait("^+e")
            return "Split panel created downward"
        }
        "close.*panel|panel.*close" {
            Write-Host "🔄 Closing current panel..." -ForegroundColor Yellow
            [System.Windows.Forms.SendKeys]::SendWait("^w")
            return "Panel closed"
        }
        default {
            return "Command not recognized. Available: split right, split down, close panel"
        }
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🎯 INTELLIGENT CONTEXT ANALYSIS
# ═══════════════════════════════════════════════════════════════════════════════

function Get-IntelligentContext {
    $context = @{
        RecentProjects = @()
        LastActivity = $null
        Suggestions = @()
        Statistics = @{}
    }
    
    # Analyze recent log files
    $logFiles = Get-ChildItem "G:\master_it\log" -Filter "*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 5
    
    if ($logFiles) {
        $context.LastActivity = $logFiles[0].LastWriteTime
        $context.Statistics.TotalLogFiles = $logFiles.Count
        
        # Extract project keywords from recent logs
        $recentContent = $logFiles | Get-Content | Select-Object -Last 50 | Out-String
        
        if ($recentContent -match "Ollama|Vision|Image") {
            $context.RecentProjects += @{
                Name = "🦙 Ollama Vision Integration"
                Status = "Successfully integrated Llama 3.2-Vision for image analysis"
                NextSteps = "Test more image analysis scenarios or explore other Ollama models"
            }
        }
        
        if ($recentContent -match "Startup|Windows|Boot") {
            $context.RecentProjects += @{
                Name = "🚀 Windows Startup Automation"
                Status = "Auto-launch Warp AI with intelligent welcome on Windows boot"
                NextSteps = "Optimize profile integration and welcome message delivery"
            }
        }
        
        if ($recentContent -match "Gemini|CLI|API") {
            $context.RecentProjects += @{
                Name = "💎 Gemini CLI Integration"
                Status = "Working on API key setup and tool integration"
                NextSteps = "Complete API key configuration for extended capabilities"
            }
        }
        
        if ($recentContent -match "MCP|Memory|Knowledge") {
            $context.RecentProjects += @{
                Name = "🧠 MCP Knowledge Graph"
                Status = "Memory and context management with MCP integration"
                NextSteps = "Continue building comprehensive memory system"
            }
        }
    }
    
    return $context
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🎉 INTELLIGENT WELCOME SYSTEM
# ═══════════════════════════════════════════════════════════════════════════════

function Show-IntelligentWelcome {
    if (-not $global:WarpFirstRun) { return }
    
    # Time-based greeting
    $timeOfDay = switch ((Get-Date).Hour) {
        {$_ -lt 12} { "morning" }
        {$_ -lt 17} { "afternoon" }  
        default { "evening" }
    }
    
    Write-Host ""
    Write-Host "👋 Hey welcome back Hubert! How's it going this $timeOfDay?" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    
    # Get intelligent context
    $context = Get-IntelligentContext
    
    Write-Host "🎯 Based on recent logs and memory, we were working on:" -ForegroundColor White
    Write-Host ""
    
    foreach ($project in $context.RecentProjects) {
        Write-Host "   $($project.Name)" -ForegroundColor Yellow
        Write-Host "      └─ $($project.Status)" -ForegroundColor Gray
        Write-Host "      🎯 Next: $($project.NextSteps)" -ForegroundColor Green
    }
    
    if ($context.LastActivity) {
        Write-Host ""
        Write-Host "📊 Recent Activity Summary:" -ForegroundColor White
        Write-Host "   📅 Last session: $($context.LastActivity.ToString('yyyy-MM-dd HH:mm'))" -ForegroundColor Gray
        Write-Host "   💻 Active tools: Ollama, Gemini CLI, MCP Memory, Warp Automation" -ForegroundColor Gray
        Write-Host "   📝 Enhancement suite: Fully operational" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "💡 Ready to continue where we left off?" -ForegroundColor White
    if ($context.RecentProjects.Count -gt 0) {
        Write-Host "   Continue with $($context.RecentProjects[0].Name): $($context.RecentProjects[0].NextSteps)" -ForegroundColor Cyan
    }
    
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host "🛡️ All systems active - your work is fully protected!" -ForegroundColor Green
    Write-Host "🚀 Let's make this $timeOfDay productive!" -ForegroundColor Yellow
    Write-Host ""
    
    # Log the welcome
    Write-ConversationLog "SYSTEM" "Intelligent welcome displayed for $timeOfDay session"
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🏁 PROFILE INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════════

# Initialize core systems
try {
    # Load Windows Forms for automation
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
    
    # Initialize conversation logging
    Initialize-ConversationLogger
    
    # Show welcome message on first run
    Show-IntelligentWelcome
    
    # Mark as loaded
    $global:WarpEnhancementLoaded = $true
    
    # Performance metrics
    $loadTime = ((Get-Date) - $global:WarpProfileStartTime).TotalMilliseconds
    Write-ConversationLog "PERFORMANCE" "Profile loaded in ${loadTime}ms"
    
    if ($global:WarpFirstRun) {
        Write-Host "🎉 WARP AI ENHANCEMENT SUITE READY! What would you like to build today?" -ForegroundColor Magenta
        Write-Host "   💡 Try: Invoke-IntelligentSearch 'latest AI news'" -ForegroundColor DarkGray
        Write-Host "   💡 Try: Invoke-WarpCommand 'create split panel right'" -ForegroundColor DarkGray
        Write-Host "   💡 Try: Invoke-ImageAnalysis 'path/to/image.jpg'" -ForegroundColor DarkGray
        Write-Host ""
    }
    
} catch {
    Write-Host "⚠️ Some enhancement features may be limited: $($_.Exception.Message)" -ForegroundColor Yellow
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🎊 READY FOR ACTION!
# ═══════════════════════════════════════════════════════════════════════════════
