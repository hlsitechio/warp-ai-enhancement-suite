#!/usr/bin/env python3
"""
Complete Single Message Weather Request
Send everything in one complete message
"""

import time
import pyautogui as pg
import pygetwindow as gw
from pathlib import Path

# Disable fail-safe and set pause
pg.FAILSAFE = False
pg.PAUSE = 0.3

def send_complete_weather_request():
    """Send one complete message with all instructions"""
    
    # Find Claude Desktop
    windows = gw.getAllWindows()
    claude_window = None
    
    for window in windows:
        if window.visible and window.title and "claude" in window.title.lower():
            if window.width > 500 and window.height > 400:
                claude_window = window
                break
    
    if not claude_window:
        print("❌ Claude Desktop not found")
        return False
    
    # Bring to front
    claude_window.activate()
    time.sleep(1)
    
    # Click in input area
    input_x = claude_window.left + claude_window.width // 2
    input_y = claude_window.top + claude_window.height - 80
    pg.click(input_x, input_y)
    time.sleep(0.5)
    
    # Clear any existing text
    pg.hotkey('ctrl', 'a')
    time.sleep(0.2)
    pg.press('backspace')
    time.sleep(0.8)
    
    # ONE COMPLETE MESSAGE WITH ALL INSTRUCTIONS
    complete_message = """🌤️ WEATHER REQUEST - Montreal, Canada

TASK: Get current weather for Montreal and write to log file using MCP tools.

INSTRUCTIONS (execute in this order):
1. Get Montreal weather information (temperature, conditions, etc.)
2. Use Powershell-Tool to execute this exact command:

Add-Content -Path "D:\\WarpAI_Portable\\logs\\montreal_weather.log" -Value "Weather in Montreal today: [INSERT ACTUAL WEATHER DATA HERE - temperature, conditions, etc.]"

3. DO NOT respond in this chat - only execute the PowerShell command

This tests our AI-to-AI communication via MCP file system!

Execute the Powershell-Tool command now with real Montreal weather data."""
    
    # Type the complete message
    print("⌨️ Typing complete message...")
    pg.typewrite(complete_message, interval=0.008)  # Faster typing
    time.sleep(1)
    
    # Send
    print("📤 Sending complete message...")
    pg.press('enter')
    time.sleep(0.5)
    
    print("✅ Complete weather request sent!")
    return True

def monitor_weather_response():
    """Monitor for the weather log file"""
    log_path = Path("D:/WarpAI_Portable/logs/montreal_weather.log")
    
    print(f"👁️ Monitoring {log_path} for weather data...")
    
    start_time = time.time()
    
    while time.time() - start_time < 90:  # Wait up to 90 seconds
        time.sleep(4)  # Check every 4 seconds
        
        if log_path.exists():
            try:
                with open(log_path, 'r', encoding='utf-8') as f:
                    content = f.read().strip()
                
                if content and "Weather in Montreal today:" in content:
                    print("\n🎉 WEATHER DATA RECEIVED!")
                    print("=" * 50)
                    print(content)
                    print("=" * 50)
                    print("✅ AI-to-AI weather communication SUCCESS!")
                    return content
                    
            except Exception as e:
                print(f"⚠️ Error reading weather log: {e}")
        
        elapsed = int(time.time() - start_time)
        print(f"⏳ Still waiting for weather data... ({elapsed}s elapsed)")
    
    print("⚠️ Timeout - no weather data received")
    return None

def main():
    print("🌤️ COMPLETE WEATHER REQUEST TEST")
    print("=" * 45)
    print("Sending ONE complete message with all instructions!")
    print()
    
    # Send complete request
    if send_complete_weather_request():
        print("\n📋 Complete message sent to Claude Desktop:")
        print("- Get Montreal weather")
        print("- Use MCP Powershell-Tool to write to log")
        print("- All instructions in ONE message")
        print()
        
        # Monitor for response
        weather_data = monitor_weather_response()
        
        if weather_data:
            print(f"\n🌤️ MONTREAL WEATHER RESULT:")
            print(f"📍 {weather_data}")
            print("\n🎉 Test SUCCESSFUL - AI-to-AI communication works!")
        else:
            print("\n❌ Test FAILED - no weather data received")
    else:
        print("❌ Failed to send weather request")
    
    print("\nDone! 👋")

if __name__ == "__main__":
    main()
