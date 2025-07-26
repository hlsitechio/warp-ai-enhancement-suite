# 🧠 WORK KNOWLEDGE MEMORY
## How to Use New Ollama Tools Integration

*Last Updated: January 26, 2025*

---

## 🎯 **QUICK REFERENCE - NEW TOOLS AVAILABLE**

### **🤖 Ollama AI Models (Local)**
- **Location**: `G:\master_it\ollama` (keeps C: drive clean)
- **Models Available**:
  - `hermes3:8b` (4.7GB) - Best reasoning and analysis
  - `llama3.1:8b` (4.9GB) - General purpose, good responses
  - `qwen2.5-coder:latest` (4.7GB) - Code-specialized
  - `gemma2:2b` (1.6GB) - Lightweight, fast responses

### **🌐 Web Search Integration**
- **DuckDuckGo API**: No API key required, instant search
- **Multiple fallback methods** for reliable results
- **Weather, news, current events** accessible locally

---

## 🚀 **HOW TO USE - PRACTICAL COMMANDS**

### **Method 1: Simple Direct Queries**
```powershell
# Quick AI response from local Ollama
$query = "Explain quantum computing in simple terms"
$requestBody = @{
    model = "llama3.1:8b"
    prompt = $query
    stream = $false
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method POST -Body $requestBody -ContentType "application/json"
Write-Host $response.response
```

### **Method 2: Web Search + AI Analysis**
```powershell
# Run the simple weather script (or adapt for other searches)
.\simple-weather.ps1

# Or create custom search:
$searchQuery = "latest AI developments 2025"
$duckUrl = "https://api.duckduckgo.com/?q=$([System.Web.HttpUtility]::UrlEncode($searchQuery))&format=json"
$searchResults = Invoke-RestMethod -Uri $duckUrl
# Then ask Ollama to analyze the results
```

### **Method 3: Advanced Multi-AI Workflow**
```powershell
# Use the comprehensive integration script
.\OllamaToolsIntegration.ps1 -Query "Your question here"
```

---

## 📋 **PROVEN WORKING EXAMPLES**

### **✅ Weather Queries**
```powershell
# What works: Direct AI knowledge + web search fallback
.\simple-weather.ps1
# Result: Gets current weather info for Montreal + seasonal analysis
```

### **✅ Code Analysis**
```powershell
# Best model for coding tasks
$codeQuery = "Review this PowerShell script for security issues"
$requestBody = @{
    model = "qwen2.5-coder:latest"
    prompt = $codeQuery
    stream = $false
} | ConvertTo-Json
# Then send your code in the prompt
```

### **✅ Research Tasks**
```powershell
# Combine web search + AI analysis
$topic = "artificial intelligence trends 2025"
$searchUrl = "https://api.duckduckgo.com/?q=$([System.Web.HttpUtility]::UrlEncode($topic))&format=json"
$webData = Invoke-RestMethod -Uri $searchUrl
# Then ask hermes3:8b to analyze the results
```

---

## 🛠️ **TROUBLESHOOTING GUIDE**

### **Problem: Tool Calling Not Working**
**Status**: ⚠️ Known Issue
- **Issue**: OpenAI-style tool calling format not triggering in Ollama models
- **Workaround**: Use direct API calls + manual tool execution
- **Files to use**: `simple-weather.ps1`, direct REST API calls

### **Problem: Ollama Not Responding**
**Solutions**:
```powershell
# Check if Ollama is running
curl -s http://localhost:11434/api/version

# If not running, start it
ollama serve

# List available models
ollama list
```

### **Problem: Model Not Found**
**Solutions**:
```powershell
# Pull missing models
ollama pull hermes3:8b
ollama pull llama3.1:8b
ollama pull qwen2.5-coder:latest
```

---

## 🎯 **BEST PRACTICES DISCOVERED**

### **✅ What Works Best**
1. **Direct API calls** instead of tool calling format
2. **Multiple model strategy**: Different models for different tasks
3. **Web search first, then AI analysis** for current information
4. **Fallback systems**: Always have backup methods

### **📊 Model Selection Guide**
- **hermes3:8b**: Complex reasoning, analysis, problem-solving
- **llama3.1:8b**: General questions, creative tasks, explanations
- **qwen2.5-coder**: Code review, debugging, technical analysis
- **gemma2:2b**: Quick simple questions, fast responses

### **🌐 Web Search Strategy**
```powershell
# Template for any web search + AI analysis
$searchTopic = "your search here"
$searchUrl = "https://api.duckduckgo.com/?q=$([System.Web.HttpUtility]::UrlEncode($searchTopic))&format=json"
$webResults = Invoke-RestMethod -Uri $searchUrl

# Then analyze with appropriate Ollama model
$analysisPrompt = "Analyze these search results: $($webResults | ConvertTo-Json)"
# Send to Ollama for intelligent analysis
```

---

## 🚀 **INTEGRATION WITH EXISTING WORKFLOW**

### **Claude AI + Ollama Integration**
- **Claude**: Complex analysis, writing, strategic thinking
- **Ollama**: Local processing, code review, quick research
- **Web Search**: Current information, real-time data
- **Fallback Chain**: Claude → Ollama → Web Search → Manual

### **Files in Your Toolkit**
```
📁 warp-ai-enhancement-suite/
├── 🤖 OllamaToolsIntegration.ps1    # Main integration script
├── 🌤️ simple-weather.ps1           # Working weather example
├── 🧪 test-direct-tool.ps1          # Tool calling tests
├── 📋 WORK_KNOWLEDGE_MEMORY.md      # This file
└── 🚀 Various other enhancement scripts
```

---

## 💡 **QUICK WINS FOR DAILY USE**

### **Morning Routine**
```powershell
# Check if Ollama is ready
ollama list
# Get daily briefing
.\simple-weather.ps1
# Ask Claude for priorities, use Ollama for research
```

### **Development Tasks**
```powershell
# Code review with specialized model
$code = Get-Content "your-script.ps1" -Raw
$requestBody = @{
    model = "qwen2.5-coder:latest"
    prompt = "Review this code for issues: $code"
    stream = $false
} | ConvertTo-Json
# Get analysis
```

### **Research Projects**
```powershell
# Multi-step research process
1. Web search with DuckDuckGo API
2. AI analysis with hermes3:8b
3. Follow-up questions with llama3.1:8b
4. Final synthesis with Claude
```

---

## 🎉 **SUCCESS METRICS**

### **✅ What's Working**
- **Triple-AI System**: Claude + Gemini + Ollama all operational
- **Local Processing**: No API quotas, complete privacy
- **Web Search**: DuckDuckGo integration functional
- **Multiple Models**: Specialized models for different tasks
- **Fallback Systems**: Always have working alternatives

### **📈 Improvements Achieved**
- **0 API costs** for local Ollama processing
- **Instant responses** from local models
- **Privacy preserved** - sensitive code stays local
- **Always available** - no internet dependency for AI
- **Specialized capabilities** - right model for each task

---

## 🔮 **FUTURE ENHANCEMENTS**

### **Next Priority Items**
1. **Fix tool calling format** - Get native function calling working
2. **Model optimization** - Fine-tune models for specific tasks
3. **Automation scripts** - One-click research and analysis
4. **Integration improvements** - Seamless Claude ↔ Ollama handoffs

### **Advanced Features to Explore**
- **Model chaining**: Automatic model selection based on query type
- **Context persistence**: Share context between Claude and Ollama
- **Batch processing**: Analyze multiple files/queries at once
- **Custom model training**: Fine-tune models for your specific needs

---

## 📞 **QUICK HELP COMMANDS**

```powershell
# Essential commands to remember
ollama list                    # Show available models
curl http://localhost:11434/api/version  # Check Ollama status
.\simple-weather.ps1          # Working web search example
gh repo view                  # Check GitHub repository
```

---

**🧠 Remember**: This is a living document. Update it as you discover new techniques and improve the integration!
