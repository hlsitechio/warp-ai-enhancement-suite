# 🤖 Multi-AI Integration for Warp AI Enhancement Suite
# Provides seamless integration between Claude, Gemini CLI, and Ollama
# Created: July 26, 2025

param(
    [string]$Query,
    [string]$PreferredAI = "auto",  # auto, gemini, ollama, claude
    [switch]$TestAll,
    [switch]$Status,
    [switch]$InstallOllamaModels,
    [switch]$ConfigureAll
)

# Configuration
$script:LogPath = "G:\master_it\log\multi_ai_integration.log"
$script:OllamaToolsPath = ".\EmbeddedOllamaTools.ps1"
$script:GeminiToolsPath = ".\EmbeddedGeminiTools.ps1"

# Ensure log directory exists
New-Item -Path (Split-Path $script:LogPath) -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

function Write-LogMessage {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $script:LogPath -Value $logEntry -ErrorAction SilentlyContinue
    
    switch ($Level) {
        "ERROR" { Write-Host $Message -ForegroundColor Red }
        "WARNING" { Write-Host $Message -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $Message -ForegroundColor Green }
        "INFO" { Write-Host $Message -ForegroundColor Cyan }
        default { Write-Host $Message -ForegroundColor White }
    }
}

function Test-GeminiCLI {
    Write-LogMessage "🔍 Testing Gemini CLI availability..."
    
    try {
        $result = gemini -p "Test connection - respond with 'Gemini CLI working'" 2>&1
        if ($LASTEXITCODE -eq 0 -and $result -notmatch "429|quota|error") {
            Write-LogMessage "✅ Gemini CLI is available and working" "SUCCESS"
            return $true
        } elseif ($result -match "429|quota") {
            Write-LogMessage "⚠️ Gemini CLI quota reached - will use fallbacks" "WARNING"
            return $false
        } else {
            Write-LogMessage "⚠️ Gemini CLI issues: $result" "WARNING"
            return $false
        }
    } catch {
        Write-LogMessage "❌ Gemini CLI not available: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Test-OllamaAI {
    Write-LogMessage "🦙 Testing Ollama AI availability..."
    
    if (-not (Test-Path $script:OllamaToolsPath)) {
        Write-LogMessage "❌ EmbeddedOllamaTools.ps1 not found" "ERROR"
        return $false
    }
    
    try {
        # Run Ollama test connection and capture exit code instead of output
        $null = & $script:OllamaToolsPath -TestConnection 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-LogMessage "✅ Ollama AI is available and working" "SUCCESS"
            return $true
        } else {
            Write-LogMessage "⚠️ Ollama AI connection failed (Exit code: $LASTEXITCODE)" "WARNING"
            return $false
        }
    } catch {
        Write-LogMessage "❌ Ollama AI not available: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Get-AICapabilities {
    Write-LogMessage "📊 Checking AI capabilities..."
    
    $capabilities = @{
        GeminiCLI = @{
            Available = Test-GeminiCLI
            Strengths = @("Internet search", "Real-time data", "Web analysis", "GitHub integration")
            Models = @("Gemini 2.5 Pro", "Gemini Flash")
        }
        OllamaAI = @{
            Available = Test-OllamaAI
            Strengths = @("Local processing", "Code analysis", "Privacy", "Offline capability")
            Models = @("Qwen2.5-Coder", "Llama3.3", "Gemma2")
        }
        Claude = @{
            Available = $true
            Strengths = @("Terminal integration", "Complex reasoning", "Multi-step tasks", "System orchestration")
            Models = @("Claude 3.5 Sonnet")
        }
    }
    
    return $capabilities
}

function Invoke-SmartAIRouter {
    param(
        [string]$QueryText,
        [string]$PreferredProvider = "auto",
        [string[]]$TriedProviders = @()
    )
    
    Write-LogMessage "🧠 Smart AI routing for query: $QueryText"
    
    $capabilities = Get-AICapabilities
    
    # Determine best AI for the query (excluding already tried providers)
    $bestAI = switch ($PreferredProvider) {
        "gemini" {
            if ($capabilities.GeminiCLI.Available -and "gemini" -notin $TriedProviders) { "gemini" } 
            elseif ($capabilities.OllamaAI.Available -and "ollama" -notin $TriedProviders) { "ollama" } 
            else { "claude" }
        }
        "ollama" {
            if ($capabilities.OllamaAI.Available -and "ollama" -notin $TriedProviders) { "ollama" } 
            elseif ($capabilities.GeminiCLI.Available -and "gemini" -notin $TriedProviders) { "gemini" } 
            else { "claude" }
        }
        "claude" {
            "claude"
        }
        "auto" {
            # Smart routing based on query content
            if ($QueryText -match "search|internet|web|current|latest|github|repository") {
                if ($capabilities.GeminiCLI.Available -and "gemini" -notin $TriedProviders) { "gemini" } 
                elseif ($capabilities.OllamaAI.Available -and "ollama" -notin $TriedProviders) { "ollama" } 
                else { "claude" }
            } elseif ($QueryText -match "code|programming|script|function|debug") {
                if ($capabilities.OllamaAI.Available -and "ollama" -notin $TriedProviders) { "ollama" } 
                elseif ($capabilities.GeminiCLI.Available -and "gemini" -notin $TriedProviders) { "gemini" } 
                else { "claude" }
            } else {
                # For general queries, prefer available local AI
                if ($capabilities.OllamaAI.Available -and "ollama" -notin $TriedProviders) { "ollama" } 
                elseif ($capabilities.GeminiCLI.Available -and "gemini" -notin $TriedProviders) { "gemini" } 
                else { "claude" }
            }
        }
        default { "claude" }
    }
    
    Write-LogMessage "🎯 Selected AI: $bestAI for query (Tried: $($TriedProviders -join ', '))"
    
    # Add current selection to tried providers
    $newTriedProviders = $TriedProviders + $bestAI
    
    # Execute query with selected AI
    switch ($bestAI) {
        "gemini" {
            try {
                Write-LogMessage "🌐 Processing with Gemini CLI..."
                $result = gemini -p $QueryText 2>&1
                if ($LASTEXITCODE -eq 0 -and $result -notmatch "429|quota|error") {
                    Write-LogMessage "✅ Gemini query successful" "SUCCESS"
                    return @{
                        AI = "Gemini CLI"
                        Result = $result
                        Status = "Success"
                    }
                } else {
                    Write-LogMessage "⚠️ Gemini failed (Exit: $LASTEXITCODE), trying fallback" "WARNING"
                    if ($newTriedProviders.Count -lt 3) {
                        return Invoke-SmartAIRouter -QueryText $QueryText -PreferredProvider "ollama" -TriedProviders $newTriedProviders
                    } else {
                        return @{ AI = "Claude (Fallback)"; Result = "All AI providers failed. Query: '$QueryText'"; Status = "AllFailed" }
                    }
                }
            } catch {
                Write-LogMessage "❌ Gemini error: $($_.Exception.Message)" "ERROR"
                if ($newTriedProviders.Count -lt 3) {
                    return Invoke-SmartAIRouter -QueryText $QueryText -PreferredProvider "ollama" -TriedProviders $newTriedProviders
                } else {
                    return @{ AI = "Claude (Fallback)"; Result = "All AI providers failed. Query: '$QueryText'"; Status = "AllFailed" }
                }
            }
        }
        "ollama" {
            try {
                Write-LogMessage "🦙 Processing with Ollama..."
                $result = & $script:OllamaToolsPath -Query $QueryText 2>&1
                if ($result -and $result -notmatch "error|failed|connection failed") {
                    Write-LogMessage "✅ Ollama query successful" "SUCCESS"
                    return @{
                        AI = "Ollama AI"
                        Result = $result
                        Status = "Success"
                    }
                } else {
                    Write-LogMessage "⚠️ Ollama failed: $result" "WARNING"
                    if ($newTriedProviders.Count -lt 3) {
                        return Invoke-SmartAIRouter -QueryText $QueryText -PreferredProvider "gemini" -TriedProviders $newTriedProviders
                    } else {
                        return @{ AI = "Claude (Fallback)"; Result = "All AI providers failed. Query: '$QueryText'"; Status = "AllFailed" }
                    }
                }
            } catch {
                Write-LogMessage "❌ Ollama error: $($_.Exception.Message)" "ERROR"
                if ($newTriedProviders.Count -lt 3) {
                    return Invoke-SmartAIRouter -QueryText $QueryText -PreferredProvider "gemini" -TriedProviders $newTriedProviders
                } else {
                    return @{ AI = "Claude (Fallback)"; Result = "All AI providers failed. Query: '$QueryText'"; Status = "AllFailed" }
                }
            }
        }
        "claude" {
            return @{
                AI = "Claude (Warp AI)"
                Result = "This query is best handled by Claude in the Warp AI terminal. Please continue the conversation directly."
                Status = "Redirect"
            }
        }
    }
}

function Show-AIStatus {
    Write-LogMessage "📊 Multi-AI System Status Report" "INFO"
    Write-LogMessage "════════════════════════════════════" "INFO"
    
    $capabilities = Get-AICapabilities
    
    foreach ($ai in $capabilities.Keys) {
        $info = $capabilities[$ai]
        $status = if ($info.Available) { "✅ Available" } else { "❌ Unavailable" }
        $color = if ($info.Available) { "SUCCESS" } else { "ERROR" }
        
        Write-LogMessage "$ai : $status" $color
        Write-LogMessage "   Models: $($info.Models -join ', ')" "INFO"
        Write-LogMessage "   Strengths: $($info.Strengths -join ', ')" "INFO"
        Write-LogMessage "" "INFO"
    }
    
    # Show recommended usage
    Write-LogMessage "🎯 Recommended Usage:" "INFO"
    if ($capabilities.GeminiCLI.Available) {
        Write-LogMessage "   🌐 Use Gemini CLI for: Internet searches, real-time data, GitHub analysis" "INFO"
    }
    if ($capabilities.OllamaAI.Available) {
        Write-LogMessage "   🦙 Use Ollama for: Code analysis, local processing, privacy-focused tasks" "INFO"
    }
    Write-LogMessage "   🤖 Use Claude for: Complex reasoning, terminal integration, system orchestration" "INFO"
}

function Install-OllamaModelsIfNeeded {
    Write-LogMessage "📦 Installing recommended Ollama models..."
    
    if (Test-Path $script:OllamaToolsPath) {
        try {
            & $script:OllamaToolsPath -InstallModels
            Write-LogMessage "✅ Ollama models installation completed" "SUCCESS"
        } catch {
            Write-LogMessage "❌ Error installing Ollama models: $($_.Exception.Message)" "ERROR"
        }
    } else {
        Write-LogMessage "❌ EmbeddedOllamaTools.ps1 not found" "ERROR"
    }
}

function Initialize-MultiAISystem {
    Write-LogMessage "🚀 Initializing Multi-AI Integration System..." "INFO"
    Write-LogMessage "════════════════════════════════════════════" "INFO"
    
    # Configure Ollama storage if needed
    if (Test-Path $script:OllamaToolsPath) {
        try {
            & $script:OllamaToolsPath -ConfigureStorage | Out-Null
            Write-LogMessage "✅ Ollama storage configured to G:\\master_it\\ollama" "SUCCESS"
        } catch {
            Write-LogMessage "⚠️ Ollama storage configuration issues" "WARNING"
        }
    }
    
    # Test all systems
    Write-LogMessage "🔧 Testing all AI systems..." "INFO"
    $capabilities = Get-AICapabilities
    
    $availableCount = ($capabilities.Values | Where-Object { $_.Available }).Count
    Write-LogMessage "✅ $availableCount out of 3 AI systems available" "SUCCESS"
    
    if ($availableCount -eq 0) {
        Write-LogMessage "❌ No AI systems available - check your configuration" "ERROR"
        return $false
    }
    
    Write-LogMessage "🎉 Multi-AI system initialized successfully!" "SUCCESS"
    return $true
}

# Main execution logic
try {
    if ($ConfigureAll) {
        Initialize-MultiAISystem
        exit 0
    }
    
    if ($Status) {
        Show-AIStatus
        exit 0
    }
    
    if ($TestAll) {
        Write-LogMessage "🧪 Testing all AI systems..." "INFO"
        
        # Test with simple queries
        $testQuery = "Hello! Please respond with your name and confirm you're working."
        
        Write-LogMessage "Testing Gemini CLI..." "INFO"
        $geminiResult = Invoke-SmartAIRouter -QueryText $testQuery -PreferredProvider "gemini"
        Write-LogMessage "Gemini Result: $($geminiResult.Status)" "INFO"
        
        Write-LogMessage "Testing Ollama..." "INFO"
        $ollamaResult = Invoke-SmartAIRouter -QueryText $testQuery -PreferredProvider "ollama"
        Write-LogMessage "Ollama Result: $($ollamaResult.Status)" "INFO"
        
        exit 0
    }
    
    if ($InstallOllamaModels) {
        Install-OllamaModelsIfNeeded
        exit 0
    }
    
    if ($Query) {
        $result = Invoke-SmartAIRouter -QueryText $Query -PreferredProvider $PreferredAI
        
        Write-LogMessage "🤖 Response from $($result.AI):" "SUCCESS"
        Write-Output $result.Result
        exit 0
    }
    
    # If no specific action, show help and status
    Write-LogMessage "🤖 Multi-AI Integration for Warp AI Enhancement Suite" "INFO"
    Write-LogMessage "Available parameters:" "INFO"
    Write-LogMessage "  -Query 'text'           : Ask any AI a question (auto-routed)" "INFO"
    Write-LogMessage "  -PreferredAI 'name'     : Prefer specific AI (auto/gemini/ollama/claude)" "INFO"
    Write-LogMessage "  -Status                 : Show all AI systems status" "INFO"
    Write-LogMessage "  -TestAll               : Test all AI systems" "INFO"
    Write-LogMessage "  -ConfigureAll          : Initialize and configure all systems" "INFO"
    Write-LogMessage "  -InstallOllamaModels   : Install recommended Ollama models" "INFO"
    Write-LogMessage "" "INFO"
    Write-LogMessage "Examples:" "INFO"
    Write-LogMessage "  .\\MultiAI-Integration.ps1 -Query 'What is the latest in AI development?'" "INFO"
    Write-LogMessage "  .\\MultiAI-Integration.ps1 -Query 'Help me debug this PowerShell script' -PreferredAI ollama" "INFO"
    Write-LogMessage "  .\\MultiAI-Integration.ps1 -Status" "INFO"
    
    # Show current status
    Write-LogMessage "" "INFO"
    Show-AIStatus
    
} catch {
    Write-LogMessage "❌ Unexpected error: $($_.Exception.Message)" "ERROR"
    exit 1
}
