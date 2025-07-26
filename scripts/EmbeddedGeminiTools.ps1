# Embedded Gemini CLI Tools for Warp AI Integration
# These functions allow Claude to seamlessly use Gemini CLI capabilities

function Invoke-WebSearch {
    param([string]$Query)
    
    try {
        $result = & gemini -p "Use google_web_search to find current information about: $Query" 2>&1
        if ($LASTEXITCODE -eq 0) {
            $cleanResult = ($result | Where-Object { $_ -notmatch "Loaded cached credentials" }) -join "`n"
            return $cleanResult.Trim()
        } else {
            return "❌ Web search failed: $result"
        }
    }
    catch {
        return "❌ Error performing web search: $($_.Exception.Message)"
    }
}

function Read-FileContent {
    param([string]$FilePath)
    
    try {
        $result = & gemini -p "Use read_file tool to read the contents of: $FilePath" 2>&1
        if ($LASTEXITCODE -eq 0) {
            $cleanResult = ($result | Where-Object { $_ -notmatch "Loaded cached credentials" }) -join "`n"
            return $cleanResult.Trim()
        } else {
            return "❌ File read failed: $result"
        }
    }
    catch {
        return "❌ Error reading file: $($_.Exception.Message)"
    }
}

function Search-FileContent {
    param([string]$Pattern, [string]$Directory = ".")
    
    try {
        $result = & gemini -p "Use search_file_content tool to search for '$Pattern' in directory: $Directory" 2>&1
        if ($LASTEXITCODE -eq 0) {
            $cleanResult = ($result | Where-Object { $_ -notmatch "Loaded cached credentials" }) -join "`n"
            return $cleanResult.Trim()
        } else {
            return "❌ File content search failed: $result"
        }
    }
    catch {
        return "❌ Error searching file content: $($_.Exception.Message)"
    }
}

function Get-DirectoryListing {
    param([string]$Path = ".")
    
    try {
        $result = & gemini -p "Use list_directory tool to list contents of: $Path" 2>&1
        if ($LASTEXITCODE -eq 0) {
            $cleanResult = ($result | Where-Object { $_ -notmatch "Loaded cached credentials" }) -join "`n"
            return $cleanResult.Trim()
        } else {
            return "❌ Directory listing failed: $result"
        }
    }
    catch {
        return "❌ Error getting directory listing: $($_.Exception.Message)"
    }
}

function Invoke-ShellCommand {
    param([string]$Command)
    
    try {
        $result = & gemini -p "Use run_shell_command tool to execute: $Command" 2>&1
        if ($LASTEXITCODE -eq 0) {
            $cleanResult = ($result | Where-Object { $_ -notmatch "Loaded cached credentials" }) -join "`n"
            return $cleanResult.Trim()
        } else {
            return "❌ Shell command failed: $result"
        }
    }
    catch {
        return "❌ Error executing shell command: $($_.Exception.Message)"
    }
}

# Functions are now available for use
