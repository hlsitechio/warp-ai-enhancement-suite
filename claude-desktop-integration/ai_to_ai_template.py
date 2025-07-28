#!/usr/bin/env python3
"""
AI-to-AI Communication Template
Use this template for sending instructions to Claude Desktop via MCP
"""

import time
import pyautogui as pg
import pygetwindow as gw
from pathlib import Path

pg.FAILSAFE = False
pg.PAUSE = 0.3

def send_ai_message(question, log_filename, powershell_command=None):
    """
    Send a complete AI-to-AI message to Claude Desktop
    
    Args:
        question (str): The question/task for Claude Desktop
        log_filename (str): Name of log file for response  
        powershell_command (str): Optional custom PowerShell command
    """
    
    # Find Claude Desktop window
    windows = gw.getAllWindows()
    claude_window = None
    
    for window in windows:
        if window.visible and window.title and "claude" in window.title.lower():
            if window.width > 500 and window.height > 400:
                claude_window = window
                break
    
    if not claude_window:
        print("❌ Claude Desktop window not found!")
        return False
    
    print(f"🎯 Found Claude Desktop: {claude_window.title}")
    
    # Activate window and focus input
    claude_window.activate()
    time.sleep(1)
    
    input_x = claude_window.left + claude_window.width // 2
    input_y = claude_window.top + claude_window.height - 80
    pg.click(input_x, input_y)
    time.sleep(0.5)
    
    # Clear input
    pg.hotkey('ctrl', 'a')
    time.sleep(0.2)
    pg.press('backspace')
    time.sleep(0.5)
    
    # Default PowerShell command if not provided
    if not powershell_command:
        powershell_command = f'Add-Content -Path "D:\\\\WarpAI_Portable\\\\logs\\\\{log_filename}" -Value "[your answer here]"'
    
    # Construct the complete message - CRITICAL: ALL IN ONE MESSAGE
    complete_message = f"""Instructions:

1. {question}
2. Do NOT respond in this chat window at all
3. Use ONLY the Powershell-Tool MCP to execute this exact command:

{powershell_command}

Requirements:
- ONLY use MCP Powershell-Tool to respond
- Do NOT type any response in this chat
- Write your answer to the specified log file
- Execute the Powershell command immediately

Execute the MCP Powershell command now."""
    
    print("⌨️ Typing complete message...")
    print(f"📝 Message length: {len(complete_message)} characters")
    
    # Type the ENTIRE message at once - DO NOT BREAK THIS UP
    pg.typewrite(complete_message, interval=0.008)
    time.sleep(1)
    
    # Send the complete message
    pg.press('enter')
    
    print("✅ Complete message sent to Claude Desktop!")
    return True

def monitor_response(log_filename, timeout=60):
    """
    Monitor the log file for Claude Desktop's MCP response
    
    Args:
        log_filename (str): Name of log file to monitor
        timeout (int): Seconds to wait for response
    """
    
    log_path = Path(f"D:/WarpAI_Portable/logs/{log_filename}")
    
    # Clear existing log
    if log_path.exists():
        log_path.unlink()
        print("🗑️ Cleared existing log file")
    
    print(f"👁️ Monitoring: {log_path}")
    
    start_time = time.time()
    
    while time.time() - start_time < timeout:
        time.sleep(2)
        
        if log_path.exists():
            try:
                with open(log_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read().strip()
                
                if content:
                    print(f"\n🎉 SUCCESS! MCP Response received:")
                    print(f"📝 {content}")
                    return True
                    
            except Exception as e:
                print(f"⚠️ Error reading log: {e}")
        
        elapsed = int(time.time() - start_time)
        print(f"⏳ Waiting... {elapsed}s")
    
    print(f"\n⏱️ Timeout ({timeout}s) - no MCP response")
    return False

# EXAMPLE USAGE FUNCTIONS

def test_simple_question():
    """Example: Simple question with default log command"""
    question = "What is 15 + 27?"
    log_file = "math_answer.log"
    
    if send_ai_message(question, log_file):
        return monitor_response(log_file)
    return False

def test_weather_query():
    """Example: Weather query with custom PowerShell command"""
    question = "Get the current weather for New York City"
    log_file = "nyc_weather.log"
    
    # Custom command that fetches weather and writes to log
    custom_cmd = f'''$weather = Invoke-RestMethod "http://wttr.in/NewYork?format=3"
Add-Content -Path "D:\\\\WarpAI_Portable\\\\logs\\\\{log_file}" -Value "NYC Weather: $weather"'''
    
    if send_ai_message(question, log_file, custom_cmd):
        return monitor_response(log_file)
    return False

def test_file_operation():
    """Example: File system operation"""
    question = "List the files in the current directory"
    log_file = "directory_listing.log"
    
    custom_cmd = f'''$files = Get-ChildItem | Select-Object Name, Length | ConvertTo-Json
Add-Content -Path "D:\\\\WarpAI_Portable\\\\logs\\\\{log_file}" -Value "Directory contents: $files"'''
    
    if send_ai_message(question, log_file, custom_cmd):
        return monitor_response(log_file)
    return False

if __name__ == "__main__":
    print("🤖 AI-to-AI Communication Template")
    print("=" * 35)
    
    # Run a simple test
    print("Testing simple math question...")
    success = test_simple_question()
    
    if success:
        print("\n🎊 AI-to-AI communication working perfectly!")
    else:
        print("\n❌ Communication test failed")
        print("Check that:")
        print("- Claude Desktop is open") 
        print("- MCP server is running (uv run main.py)")
        print("- DXT extension is active")
        print("- USB drive is accessible at D:\\WarpAI_Portable\\")
