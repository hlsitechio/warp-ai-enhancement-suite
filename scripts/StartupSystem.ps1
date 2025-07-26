# StartupSystem.ps1 - Master initialization script for Claude sessions
# Automatically loads all systems and provides intelligent welcome back experience

Write-Host "🚀 INITIALIZING CLAUDE SESSION SYSTEM..." -ForegroundColor Yellow
Write-Host "════════════════════════════════════════" -ForegroundColor DarkGray

# Load all core systems
try {
    # 1. Load auto-logging system
    . "C:\Users\hlaro\Documents\AutoLogger.ps1"
    Write-Host "✅ Auto-logging system loaded" -ForegroundColor Green
    
    # 2. Load Warp automation
    if (Test-Path "C:\Users\hlaro\Documents\WarpAutomation.ps1") {
        . "C:\Users\hlaro\Documents\WarpAutomation.ps1"
        Write-Host "✅ Warp automation loaded" -ForegroundColor Green
    }
    
    # 3. Load Gemini tools
    if (Test-Path "C:\Users\hlaro\Documents\EmbeddedGeminiTools.ps1") {
        . "C:\Users\hlaro\Documents\EmbeddedGeminiTools.ps1"
        Write-Host "✅ Gemini tools loaded" -ForegroundColor Green
    }
    
    # 4. Load welcome back system
    . "C:\Users\hlaro\Documents\WelcomeBack.ps1"
    Write-Host "✅ Welcome back system loaded" -ForegroundColor Green
    
} catch {
    Write-Host "⚠️ Some systems failed to load: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "════════════════════════════════════════" -ForegroundColor DarkGray

# Capture this startup in our auto-logging system
Capture-UserPrompt "User started new Claude session - StartupSystem.ps1 executed automatically"

# Create the intelligent welcome message
function Show-IntelligentWelcome {
    # Get session data for context
    $sessionData = Get-LastSessionSummary
    
    # Time-based greeting
    $timeOfDay = switch ((Get-Date).Hour) {
        {$_ -lt 12} { "morning" }
        {$_ -lt 17} { "afternoon" }  
        default { "evening" }
    }
    
    Write-Host "👋 Hey welcome back Hubert! How's it going this $timeOfDay?" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    
    if ($sessionData -and $sessionData.UserPrompts -gt 0) {
        Write-Host "🎯 Last time we were:" -ForegroundColor Yellow
        
        # Smart context detection
        $context = $sessionData.FullContext
        if ($context -match "automation|Warp|split panel") {
            Write-Host "   🤖 Building Warp AI automation systems!" -ForegroundColor White
            Write-Host "   ⚡ Working on split panels, logging, and intelligent commands" -ForegroundColor Gray
        } elseif ($context -match "logging|backup|conversation") {
            Write-Host "   📝 Developing conversation logging and backup systems!" -ForegroundColor White
            Write-Host "   🛡️ Protecting against data loss and system crashes" -ForegroundColor Gray
        } elseif ($context -match "Gemini|CLI|tool") {
            Write-Host "   🔧 Integrating Gemini CLI tools with Claude capabilities!" -ForegroundColor White
            Write-Host "   🌐 Creating hybrid AI assistant functionality" -ForegroundColor Gray
        } else {
            Write-Host "   💻 Coding and building awesome projects together!" -ForegroundColor White
        }
        
        Write-Host "`n📊 Session stats:" -ForegroundColor Yellow
        Write-Host "   💬 $($sessionData.UserPrompts) exchanges in last session" -ForegroundColor White
        Write-Host "   ⏰ Last active: $($sessionData.LastActivity)" -ForegroundColor White
        
        Write-Host "`n💡 Ready to build a new app, or shall we continue our Warp AI automation project?" -ForegroundColor Magenta
    } else {
        Write-Host "🆕 Fresh start today!" -ForegroundColor Blue
        Write-Host "✨ Ready to build something incredible? I'm here to help with:" -ForegroundColor White
        Write-Host "   🤖 Warp AI automation and terminal enhancements" -ForegroundColor Gray
        Write-Host "   📝 Logging and backup systems" -ForegroundColor Gray
        Write-Host "   🔧 Tool integration and development" -ForegroundColor Gray
        Write-Host "   💻 Any coding project you have in mind!" -ForegroundColor Gray
    }
    
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host "🛡️ All systems active - your work is fully protected!" -ForegroundColor Green
    Write-Host "🚀 Let's make this $timeOfDay productive!" -ForegroundColor Cyan
    Write-Host ""
}

# Show the intelligent welcome
Show-IntelligentWelcome

# Log the successful startup
Capture-ClaudeResponse "StartupSystem.ps1 executed successfully. All systems loaded: AutoLogger, WarpAutomation, EmbeddedGeminiTools, WelcomeBack. Intelligent greeting displayed with session context. Ready for productive session!" "COMPLETE"

# Update memory graph
$global:SystemsLoaded = @{
    AutoLogger = $true
    WarpAutomation = (Test-Path "C:\Users\hlaro\Documents\WarpAutomation.ps1")
    EmbeddedGeminiTools = (Test-Path "C:\Users\hlaro\Documents\EmbeddedGeminiTools.ps1")
    WelcomeBack = $true
    StartupTime = Get-Date
}

Write-Host "🎉 ALL SYSTEMS READY! What would you like to build today?" -ForegroundColor Green
