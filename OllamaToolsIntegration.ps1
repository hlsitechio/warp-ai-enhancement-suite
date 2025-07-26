# 🛠️ Native Ollama Tools Integration for Warp AI Enhancement Suite
# Uses Ollama's official tool calling capabilities
# Created: July 26, 2025

param(
    [string]$Query,
    [string]$Model = "hermes3:8b",  # Default to Hermes3 for best tool calling
    [switch]$ListAvailableTools,
    [switch]$TestConnection,
    [switch]$ListModels,
    [string]$ToolsToUse = "auto"  # auto, web_search, file_operations, calculations
)

# Configuration
$script:LogPath = "G:\master_it\log\ollama_tools_integration.log"
$script:OllamaModelsPath = "G:\master_it\ollama"
$script:OllamaServerURL = "http://localhost:11434"

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
        $response = Invoke-RestMethod -Uri "$script:OllamaServerURL/api/tags" -Method Get -TimeoutSec 5
        if ($response) {
            Write-LogMessage "✅ Ollama server is running and accessible" "SUCCESS"
            return $true
        }
    } catch {
        Write-LogMessage "❌ Ollama server not accessible: $($_.Exception.Message)" "ERROR"
        Write-LogMessage "💡 Make sure Ollama is running: ollama serve" "INFO"
        return $false
    }
}

function Get-AvailableToolEnabledModels {
    Write-LogMessage "📋 Checking for tool-enabled models..."
    
    try {
        $response = Invoke-RestMethod -Uri "$script:OllamaServerURL/api/tags" -Method Get
        $toolEnabledModels = @()
        
        foreach ($model in $response.models) {
            # Check model details for tool capabilities
            try {
                $modelInfo = Invoke-RestMethod -Uri "$script:OllamaServerURL/api/show" -Method Post -Body (@{
                    name = $model.name
                } | ConvertTo-Json) -ContentType "application/json"
                
                if ($modelInfo.capabilities -contains "tools") {
                    $toolEnabledModels += @{
                        Name = $model.name
                        Size = [math]::Round($model.size / 1GB, 2)
                        Modified = $model.modified_at
                        HasTools = $true
                    }
                }
            } catch {
                # If we can't get model info, skip
                continue
            }
        }
        
        return $toolEnabledModels
    } catch {
        Write-LogMessage "❌ Failed to get model list: $($_.Exception.Message)" "ERROR"
        return @()
    }
}

function Get-WebSearchTool {
    return @{
        type = "function"
        function = @{
            name = "web_search"
            description = "Search the web for current information on any topic"
            parameters = @{
                type = "object"
                properties = @{
                    query = @{
                        type = "string"
                        description = "The search query to find information about"
                    }
                    max_results = @{
                        type = "integer"
                        description = "Maximum number of search results to return (default: 5)"
                        default = 5
                    }
                }
                required = @("query")
            }
        }
    }
}

function Get-CalculatorTool {
    return @{
        type = "function"
        function = @{
            name = "calculator"
            description = "Perform mathematical calculations and conversions"
            parameters = @{
                type = "object"
                properties = @{
                    expression = @{
                        type = "string"
                        description = "Mathematical expression to evaluate (e.g., '2+2', 'sqrt(16)', 'sin(30)')"
                    }
                }
                required = @("expression")
            }
        }
    }
}

function Get-FileOperationsTool {
    return @{
        type = "function"
        function = @{
            name = "file_operations"
            description = "Read, write, or get information about files on the system"
            parameters = @{
                type = "object"
                properties = @{
                    operation = @{
                        type = "string"
                        enum = @("read", "list", "info")
                        description = "Operation to perform: read file contents, list directory, or get file info"
                    }
                    path = @{
                        type = "string"
                        description = "File or directory path"
                    }
                }
                required = @("operation", "path")
            }
        }
    }
}

function Invoke-WebSearch {
    param([string]$Query, [int]$MaxResults = 5)
    
    Write-LogMessage "🌐 Performing web search for: $Query"
    
    try {
        # Use DuckDuckGo API for web search
        $searchUrl = "https://api.duckduckgo.com/?q=$([System.Web.HttpUtility]::UrlEncode($Query))&format=json&no_html=1&skip_disambig=1"
        $response = Invoke-RestMethod -Uri $searchUrl -Method Get -TimeoutSec 10
        
        $results = @()
        if ($response.AbstractText) {
            $results += "Main result: $($response.AbstractText) (Source: $($response.AbstractURL))"
        }
        
        if ($response.RelatedTopics) {
            $count = 0
            foreach ($topic in $response.RelatedTopics) {
                if ($count -ge $MaxResults) { break }
                if ($topic.Text) {
                    $results += "Related: $($topic.Text) (Source: $($topic.FirstURL))"
                    $count++
                }
            }
        }
        
        if ($results.Count -eq 0) {
            return "No specific results found for '$Query'. This might be a very recent topic or require more specific search terms."
        }
        
        return ($results -join "`n`n")
    } catch {
        return "Web search failed: $($_.Exception.Message). Try rephrasing the query or search manually."
    }
}

function Invoke-Calculator {
    param([string]$Expression)
    
    Write-LogMessage "🧮 Calculating: $Expression"
    
    try {
        # Safe mathematical evaluation using PowerShell
        $sanitized = $Expression -replace '[^0-9+\-*/().\s]', ''
        if ($sanitized -ne $Expression) {
            return "Error: Expression contains invalid characters. Only numbers and basic math operators are allowed."
        }
        
        $result = Invoke-Expression $sanitized
        return "Result: $result"
    } catch {
        return "Calculation error: $($_.Exception.Message)"
    }
}

function Invoke-FileOperations {
    param([string]$Operation, [string]$Path)
    
    Write-LogMessage "📁 File operation: $Operation on $Path"
    
    try {
        switch ($Operation) {
            "read" {
                if (Test-Path $Path -PathType Leaf) {
                    $content = Get-Content $Path -Raw -ErrorAction Stop
                    if ($content.Length -gt 2000) {
                        return "File content (first 2000 chars): $($content.Substring(0, 2000))..."
                    }
                    return "File content: $content"
                } else {
                    return "File not found: $Path"
                }
            }
            "list" {
                if (Test-Path $Path -PathType Container) {
                    $items = Get-ChildItem $Path -ErrorAction Stop | Select-Object -First 20
                    $result = "Directory contents of $Path`:`n"
                    foreach ($item in $items) {
                        $type = if ($item.PSIsContainer) { "[DIR]" } else { "[FILE]" }
                        $result += "$type $($item.Name)`n"
                    }
                    return $result
                } else {
                    return "Directory not found: $Path"
                }
            }
            "info" {
                if (Test-Path $Path) {
                    $item = Get-Item $Path -ErrorAction Stop
                    return "Path: $($item.FullName)`nType: $($item.GetType().Name)`nSize: $($item.Length) bytes`nModified: $($item.LastWriteTime)"
                } else {
                    return "Path not found: $Path"
                }
            }
            default {
                return "Unknown operation: $Operation"
            }
        }
    } catch {
        return "File operation failed: $($_.Exception.Message)"
    }
}

function Invoke-OllamaWithTools {
    param(
        [string]$QueryText,
        [string]$ModelName = "hermes3:8b",
        [array]$Tools = @()
    )
    
    Write-LogMessage "🤖 Processing query with tool-enabled model: $ModelName"
    Write-LogMessage "📝 Query: $QueryText"
    Write-LogMessage "🛠️ Available tools: $($Tools.Count)"
    
    if (-not (Test-OllamaConnection)) {
        return "Error: Cannot connect to Ollama server"
    }
    
    try {
        # Prepare the chat request with tools
        $requestBody = @{
            model = $ModelName
            messages = @(
                @{
                    role = "user"
                    content = $QueryText
                }
            )
            tools = $Tools
            stream = $false
        }
        
        $response = Invoke-RestMethod -Uri "$script:OllamaServerURL/api/chat" -Method Post -Body ($requestBody | ConvertTo-Json -Depth 10) -ContentType "application/json"
        
        # Handle tool calls in the response
        if ($response.message.tool_calls) {
            Write-LogMessage "🔧 Model requested tool execution" "INFO"
            
            $toolResults = @()
            foreach ($toolCall in $response.message.tool_calls) {
                $toolName = $toolCall.function.name
                $toolArgs = $toolCall.function.arguments | ConvertFrom-Json
                
                Write-LogMessage "⚙️ Executing tool: $toolName with args: $($toolArgs | ConvertTo-Json -Compress)" "INFO"
                
                $toolResult = switch ($toolName) {
                    "web_search" {
                        Invoke-WebSearch -Query $toolArgs.query -MaxResults ($toolArgs.max_results ?? 5)
                    }
                    "calculator" {
                        Invoke-Calculator -Expression $toolArgs.expression
                    }
                    "file_operations" {
                        Invoke-FileOperations -Operation $toolArgs.operation -Path $toolArgs.path
                    }
                    default {
                        "Unknown tool: $toolName"
                    }
                }
                
                $toolResults += @{
                    call = $toolCall
                    result = $toolResult
                }
            }
            
            # Send tool results back to the model for final response
            $followUpBody = @{
                model = $ModelName
                messages = @(
                    @{
                        role = "user"
                        content = $QueryText
                    },
                    $response.message,
                    @{
                        role = "tool"
                        content = ($toolResults | ForEach-Object { "Tool: $($_.call.function.name) Result: $($_.result)" }) -join "`n`n"
                    }
                )
                stream = $false
            }
            
            $finalResponse = Invoke-RestMethod -Uri "$script:OllamaServerURL/api/chat" -Method Post -Body ($followUpBody | ConvertTo-Json -Depth 10) -ContentType "application/json"
            return $finalResponse.message.content
        } else {
            # Direct response without tools
            return $response.message.content
        }
        
    } catch {
        Write-LogMessage "❌ Ollama query failed: $($_.Exception.Message)" "ERROR"
        return "Error: $($_.Exception.Message)"
    }
}

function Get-AvailableTools {
    $tools = @()
    
    # Add web search tool
    $tools += Get-WebSearchTool
    
    # Add calculator tool
    $tools += Get-CalculatorTool
    
    # Add file operations tool
    $tools += Get-FileOperationsTool
    
    return $tools
}

# Main execution logic
try {
    if ($TestConnection) {
        Test-OllamaConnection
        exit 0
    }
    
    if ($ListModels) {
        $models = Get-AvailableToolEnabledModels
        if ($models.Count -gt 0) {
            Write-LogMessage "🛠️ Tool-enabled models:" "SUCCESS"
            foreach ($model in $models) {
                Write-LogMessage "  📦 $($model.Name) - $($model.Size)GB - Modified: $($model.Modified)" "INFO"
            }
        } else {
            Write-LogMessage "❌ No tool-enabled models found" "ERROR"
        }
        exit 0
    }
    
    if ($ListAvailableTools) {
        $tools = Get-AvailableTools
        Write-LogMessage "🛠️ Available Tools:" "SUCCESS"
        foreach ($tool in $tools) {
            Write-LogMessage "  🔧 $($tool.function.name): $($tool.function.description)" "INFO"
        }
        exit 0
    }
    
    if ($Query) {
        $tools = Get-AvailableTools
        $result = Invoke-OllamaWithTools -QueryText $Query -ModelName $Model -Tools $tools
        Write-Output $result
        exit 0
    }
    
    # If no specific action, show help
    Write-LogMessage "🛠️ Native Ollama Tools Integration for Warp AI Enhancement Suite" "INFO"
    Write-LogMessage "Available parameters:" "INFO"
    Write-LogMessage "  -Query 'text'           : Ask a question with tool support" "INFO"
    Write-LogMessage "  -Model 'name'           : Specify model (default: hermes3:8b)" "INFO"
    Write-LogMessage "  -ListAvailableTools     : Show all available tools" "INFO"
    Write-LogMessage "  -TestConnection         : Test Ollama server connection" "INFO"
    Write-LogMessage "  -ListModels            : List tool-enabled models" "INFO"
    Write-LogMessage "" "INFO"
    Write-LogMessage "Examples:" "INFO"
    Write-LogMessage "  .\OllamaToolsIntegration.ps1 -Query 'What is the latest news about AI?'" "INFO"
    Write-LogMessage "  .\OllamaToolsIntegration.ps1 -Query 'Calculate the square root of 144'" "INFO"
    Write-LogMessage "  .\OllamaToolsIntegration.ps1 -ListAvailableTools" "INFO"
    
    # Show current status
    Write-LogMessage "" "INFO"
    Write-LogMessage "📊 Current Status:" "INFO"
    Write-LogMessage "   Storage: $env:OLLAMA_MODELS" "INFO"
    Test-OllamaConnection | Out-Null
    
} catch {
    Write-LogMessage "❌ Unexpected error: $($_.Exception.Message)" "ERROR"
    exit 1
}
