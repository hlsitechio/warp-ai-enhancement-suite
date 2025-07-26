# 🚀 OLLAMA QUICK REFERENCE CHEAT SHEET

## ⚡ **INSTANT COMMANDS**

### **Check System Status**
```powershell
ollama list                                    # Show available models
curl -s http://localhost:11434/api/version    # Check if Ollama is running
```

### **Quick AI Query**
```powershell
# Template for instant AI response
$query = "Your question here"
$body = @{model="llama3.1:8b"; prompt=$query; stream=$false} | ConvertTo-Json
$response = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method POST -Body $body -ContentType "application/json"
Write-Host $response.response
```

### **Web Search + AI**
```powershell
.\simple-weather.ps1                          # Working weather example
# Adapt the pattern for any search topic
```

---

## 🤖 **MODEL SELECTION GUIDE**

| Task Type | Best Model | Why |
|-----------|------------|-----|
| **Code Review** | `qwen2.5-coder:latest` | Specialized for programming |
| **Complex Analysis** | `hermes3:8b` | Best reasoning capabilities |
| **General Questions** | `llama3.1:8b` | Balanced, good explanations |
| **Quick Answers** | `gemma2:2b` | Fastest, lightweight |

---

## 🌐 **WEB SEARCH TEMPLATE**

```powershell
# Universal web search pattern
$topic = "your search topic"
$searchUrl = "https://api.duckduckgo.com/?q=$([System.Web.HttpUtility]::UrlEncode($topic))&format=json"
$webResults = Invoke-RestMethod -Uri $searchUrl

# Then analyze with AI
$analysisPrompt = "Analyze these search results and summarize: $($webResults.AbstractText)"
# Send to your chosen Ollama model
```

---

## 🛠️ **TROUBLESHOOTING**

| Problem | Solution |
|---------|----------|
| **Ollama not responding** | `ollama serve` |
| **Model not found** | `ollama pull model-name` |
| **Tool calling fails** | Use direct API calls instead |
| **Slow responses** | Switch to `gemma2:2b` for speed |

---

## 💡 **DAILY WORKFLOW**

1. **Morning**: `.\simple-weather.ps1` 
2. **Development**: Use `qwen2.5-coder:latest` for code review
3. **Research**: Web search → `hermes3:8b` analysis  
4. **Quick questions**: `llama3.1:8b` or `gemma2:2b`

**Remember**: Your Ollama models are stored at `G:\master_it\ollama` and work completely offline! 🔒
