# 🌐 Enhanced Ollama Web Tools for Warp AI Enhancement Suite
# Combines local Ollama models with web search capabilities
# Created: July 26, 2025

param(
    [string]$Query,
    [string]$Model = "hermes3:8b",  # Default to Hermes3 for best tool calling
    [switch]$WebSearch,
    [switch]$TestConnection,
    [switch]$ListModels,
    [switch]$ConfigureStorage,
    [switch]$InstallModels,
    [string]$SearchEngine = "duckduckgo"  # duckduckgo, bing, google
)

# Configuration
$script:LogPath = "G:\master_it\log\ollama_web_tools.log"
$script:OllamaModelsPath = "G:\master_it\ollama"

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

function Test-OllamaConnection {
    Write-LogMessage "🔍 Testing Ollama connection..."
    
    try {
        $result = ollama list 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-LogMessage "✅ Ollama connection successful" "SUCCESS"
            return $true
        } else {
            Write-LogMessage "❌ Ollama connection failed: $result" "ERROR"
            return $false
        }
    } catch {
        Write-LogMessage "❌ Ollama connection error: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Get-WebSearchResults {
    param(
        [string]$SearchQuery,
        [string]$Engine = "duckduckgo",
        [int]$MaxResults = 5
    )
    
    Write-LogMessage "🌐 Performing web search: '$SearchQuery' using $Engine"
    
    try {
        switch ($Engine.ToLower()) {
            "duckduckgo" {
                # Use DuckDuckGo Instant Answer API (no API key required)
                $searchUrl = "https://api.duckduckgo.com/?q=$([System.Web.HttpUtility]::UrlEncode($SearchQuery))&format=json&no_html=1&skip_disambig=1"
                $response = Invoke-RestMethod -Uri $searchUrl -Method Get -TimeoutSec 10
                
                $results = @()
                if ($response.AbstractText) {
                    $results += @{
                        Title = $response.Heading
                        Snippet = $response.AbstractText
                        Url = $response.AbstractURL
                        Source = "DuckDuckGo Instant Answer"
                    }
                }
                
                # Add related topics if available
                if ($response.RelatedTopics) {
                    foreach ($topic in ($response.RelatedTopics | Select-Object -First $MaxResults)) {
                        if ($topic.Text) {
                            $results += @{
                                Title = $topic.FirstURL -replace ".*\/([^\/]+)$", '$1'
                                Snippet = $topic.Text
                                Url = $topic.FirstURL
                                Source = "DuckDuckGo Related"
                            }
                        }
                    }
                }
                
                return $results
            }
            
            "bing" {
                # Note: This would require Bing Search API key
                Write-LogMessage "⚠️ Bing search requires API key - using DuckDuckGo fallback" "WARNING"
                return Get-WebSearchResults -SearchQuery $SearchQuery -Engine "duckduckgo" -MaxResults $MaxResults
            }
            
            default {
                Write-LogMessage "⚠️ Unknown search engine '$Engine' - using DuckDuckGo" "WARNING"
                return Get-WebSearchResults -SearchQuery $SearchQuery -Engine "duckduckgo" -MaxResults $MaxResults
            }
        }
    } catch {
        Write-LogMessage "❌ Web search failed: $($_.Exception.Message)" "ERROR"
        return @()
    }
}

function Invoke-OllamaWithWebSearch {
    param(
        [string]$QueryText,
        [string]$ModelName = "hermes3:8b",
        [bool]$IncludeWebSearch = $true
    )
    
    Write-LogMessage "🤖 Processing query with web-enhanced Ollama model: $ModelName"
    Write-LogMessage "📝 Query: $QueryText"
    
    # Test connection first
    if (-not (Test-OllamaConnection)) {
        Write-LogMessage "❌ Cannot connect to Ollama" "ERROR"
        return "Error: Ollama connection failed"
    }
    
    # Determine if web search is needed
    $needsWebSearch = $IncludeWebSearch -and ($QueryText -match "latest|current|recent|news|today|now|2025|2024|what's new|search|find|lookup")
    
    if ($needsWebSearch) {
        Write-LogMessage "🌐 Query requires web search - fetching latest information..."
        
        # Extract search terms from the query
        $searchQuery = $QueryText -replace "what are|what is|how to|tell me about|explain|describe", "" -replace "^\s+|\s+$", ""
        
        # Get web search results
        $webResults = Get-WebSearchResults -SearchQuery $searchQuery -Engine $SearchEngine -MaxResults 3
        
        if ($webResults.Count -gt 0) {
            # Prepare context with web search results
            $webContext = "Based on the latest web search results:`n`n"
            foreach ($result in $webResults) {
                $webContext += "Title: $($result.Title)`n"
                $webContext += "Summary: $($result.Snippet)`n"
                $webContext += "Source: $($result.Url)`n`n"
            }
            
            # Combine original query with web context
            $enhancedQuery = @"
$webContext

Based on the above search results and your knowledge, please answer this question:
$QueryText

Please provide a comprehensive answer that incorporates both the latest information from the search results and your general knowledge.
"@
        } else {
            Write-LogMessage "⚠️ Web search returned no results - using model knowledge only" "WARNING"
            $enhancedQuery = $QueryText
        }
    } else {
        $enhancedQuery = $QueryText
    }
    
    try {
        # Run the query through Ollama
        Write-LogMessage "🧠 Processing with $ModelName..."
        $result = ollama run $ModelName $enhancedQuery 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-LogMessage "✅ Query processed successfully" "SUCCESS"
            return $result
        } else {
            Write-LogMessage "❌ Ollama query failed: $result" "ERROR"
            return "Error: Ollama query failed - $result"
        }
    } catch {
        Write-LogMessage "❌ Ollama error: $($_.Exception.Message)" "ERROR"
        return "Error: $($_.Exception.Message)"
    }
}

function Get-AvailableModels {
    Write-LogMessage "📋 Listing available Ollama models..."
    
    try {
        $models = ollama list 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-LogMessage "✅ Models retrieved successfully" "SUCCESS"
            return $models
        } else {
            Write-LogMessage "❌ Failed to get models: $models" "ERROR"
            return "Error: Failed to retrieve models"
        }
    } catch {
        Write-LogMessage "❌ Error retrieving models: $($_.Exception.Message)" "ERROR"
        return "Error: $($_.Exception.Message)"
    }
}

function Install-RecommendedWebModels {
    Write-LogMessage "📦 Installing recommended models for web-enhanced queries..."
    
    $recommendedModels = @(
        @{ Name = "hermes3:8b"; Description = "Excellent for tool calling and reasoning" }
        @{ Name = "llama3.1:8b"; Description = "Great general purpose with tool support" }
        @{ Name = "qwen2.5:7b"; Description = "Strong coding and analysis capabilities" }
    )
    
    foreach ($model in $recommendedModels) {
        Write-LogMessage "📥 Installing $($model.Name) - $($model.Description)" "INFO"
        try {
            ollama pull $model.Name
            if ($LASTEXITCODE -eq 0) {
                Write-LogMessage "✅ Successfully installed $($model.Name)" "SUCCESS"
            } else {
                Write-LogMessage "⚠️ Failed to install $($model.Name)" "WARNING"
            }
        } catch {
            Write-LogMessage "❌ Error installing $($model.Name): $($_.Exception.Message)" "ERROR"
        }
    }
}

function Set-OllamaStorage {
    Write-LogMessage "🗂️ Configuring Ollama storage to G:\master_it\ollama..."
    
    try {
        # Set environment variable for current session
        $env:OLLAMA_MODELS = $script:OllamaModelsPath
        
        # Set permanent environment variable
        [System.Environment]::SetEnvironmentVariable("OLLAMA_MODELS", $script:OllamaModelsPath, [System.EnvironmentVariableTarget]::User)
        
        # Create directory if it doesn't exist
        New-Item -Path $script:OllamaModelsPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
        
        Write-LogMessage "✅ Ollama storage configured to $script:OllamaModelsPath" "SUCCESS"
        Write-LogMessage "📁 Models will be stored on G: drive to keep C: clean" "SUCCESS"
        
        return $true
    } catch {
        Write-LogMessage "❌ Failed to configure storage: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Main execution logic
try {
    if ($ConfigureStorage) {
        Set-OllamaStorage
        exit 0
    }
    
    if ($TestConnection) {
        Test-OllamaConnection
        exit 0
    }
    
    if ($ListModels) {
        Get-AvailableModels
        exit 0
    }
    
    if ($InstallModels) {
        Install-RecommendedWebModels
        exit 0
    }
    
    if ($Query) {
        $result = Invoke-OllamaWithWebSearch -QueryText $Query -ModelName $Model -IncludeWebSearch $WebSearch
        Write-Output $result
        exit 0
    }
    
    # If no specific action, show help
    Write-LogMessage "🌐 Enhanced Ollama Web Tools for Warp AI Enhancement Suite" "INFO"
    Write-LogMessage "Available parameters:" "INFO"
    Write-LogMessage "  -Query 'text'           : Ask a question (with optional web search)" "INFO"
    Write-LogMessage "  -Model 'name'           : Specify model (default: hermes3:8b)" "INFO"
    Write-LogMessage "  -WebSearch             : Enable web search for current queries" "INFO"
    Write-LogMessage "  -SearchEngine 'name'    : Search engine (duckduckgo, bing)" "INFO"
    Write-LogMessage "  -TestConnection        : Test Ollama connection" "INFO"
    Write-LogMessage "  -ListModels           : List available models" "INFO"
    Write-LogMessage "  -ConfigureStorage     : Set up G: drive storage" "INFO"
    Write-LogMessage "  -InstallModels        : Install recommended web-enhanced models" "INFO"
    Write-LogMessage "" "INFO"
    Write-LogMessage "Examples:" "INFO"
    Write-LogMessage "  .\EmbeddedOllamaWebTools.ps1 -Query 'What are the latest AI developments?' -WebSearch" "INFO"
    Write-LogMessage "  .\EmbeddedOllamaWebTools.ps1 -Query 'Explain PowerShell functions' -Model hermes3:8b" "INFO"
    Write-LogMessage "  .\EmbeddedOllamaWebTools.ps1 -TestConnection" "INFO"
    
    # Show current status
    Write-LogMessage "" "INFO"
    Write-LogMessage "📊 Current Status:" "INFO"
    Write-LogMessage "   Storage: $env:OLLAMA_MODELS" "INFO"
    Test-OllamaConnection | Out-Null
    Get-AvailableModels | Out-Null
    
} catch {
    Write-LogMessage "❌ Unexpected error: $($_.Exception.Message)" "ERROR"
    exit 1
}
