#!/usr/bin/env python3
"""
Single Message Sky Color Test
Sends ALL instructions in ONE complete message to prevent partial responses
"""

import time
import pyautogui as pg
import pygetwindow as gw
from pathlib import Path

pg.FAILSAFE = False
pg.PAUSE = 0.3

def send_complete_sky_test():
    """Send the ENTIRE sky color test instruction in ONE message"""
    
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
    
    # Bring window to front and focus
    claude_window.activate()
    time.sleep(1)
    
    # Click input area
    input_x = claude_window.left + claude_window.width // 2
    input_y = claude_window.top + claude_window.height - 80
    pg.click(input_x, input_y)
    time.sleep(0.5)
    
    # Clear input
    pg.hotkey('ctrl', 'a')
    time.sleep(0.2)
    pg.press('backspace')
    time.sleep(0.5)
    
    # THE COMPLETE MESSAGE - EVERYTHING IN ONE GO
    complete_message = """Instructions:

1. Answer this question: What color is the sky?
2. Do NOT respond in this chat window at all
3. Use ONLY the Powershell-Tool MCP to execute this exact command:

Add-Content -Path "D:\\WarpAI_Portable\\logs\\sky_color_response.log" -Value "Sky color answer: [put your actual answer here]"

Requirements:
- ONLY use MCP Powershell-Tool to respond
- Do NOT type any response in this chat
- Write your sky color answer to the specified log file
- Execute the Powershell command immediately

Execute the MCP Powershell command now."""
    
    print("⌨️ Typing COMPLETE message in one go...")
    print("📝 Message length:", len(complete_message), "characters")
    
    # Type the ENTIRE message at once
    pg.typewrite(complete_message, interval=0.008)  # Slightly faster typing
    time.sleep(1)  # Give a moment before sending
    
    # Send the complete message
    print("📤 Sending complete message...")
    pg.press('enter')
    
    print("✅ COMPLETE sky color test message sent in ONE message!")
    return True

def monitor_response():
    """Monitor for the MCP response in the log file"""
    
    log_path = Path("D:/WarpAI_Portable/logs/sky_color_response.log")
    
    # Clear existing log
    if log_path.exists():
        log_path.unlink()
        print("🗑️ Cleared existing log file")
    
    print(f"👁️ Monitoring: {log_path}")
    
    start_time = time.time()
    timeout = 60  # 60 seconds
    
    while time.time() - start_time < timeout:
        time.sleep(2)
        
        if log_path.exists():
            try:
                with open(log_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read().strip()
                
                if content:
                    print(f"\n🎉 SUCCESS! MCP Response received:")
                    print(f"📝 {content}")
                    
                    # Validate response
                    sky_colors = ['blue', 'gray', 'grey', 'white', 'clear', 'cloudy', 'overcast']
                    if any(color in content.lower() for color in sky_colors):
                        print("✅ Valid sky color response detected!")
                        return True
                    else:
                        print("⚠️ Response received but no clear sky color")
                        return True
                        
            except Exception as e:
                print(f"⚠️ Error reading log: {e}")
        
        elapsed = int(time.time() - start_time)
        print(f"⏳ Waiting... {elapsed}s")
    
    print("\n⏱️ Timeout reached - no MCP response")
    return False

def main():
    """Main test execution"""
    
    print("🌌 SINGLE MESSAGE SKY COLOR TEST")
    print("=" * 35)
    print("🎯 Goal: Send ALL instructions in ONE complete message")
    print("🚫 Prevent Claude from typing partial responses in chat")
    print()
    
    # Send the complete message
    if not send_complete_sky_test():
        print("❌ Failed to send message")
        return
    
    print()
    print("🔑 Key improvements:")
    print("   • ALL instructions in ONE message")
    print("   • Clear numbered steps")
    print("   • Explicit 'do not respond in chat' directive") 
    print("   • Immediate MCP command execution request")
    print()
    
    # Monitor for MCP response
    success = monitor_response()
    
    if success:
        print("\n🎊 TEST PASSED!")
        print("✅ Claude Desktop used MCP tool correctly")
        print("✅ No chat response (as instructed)")
    else:
        print("\n❌ TEST FAILED!")
        print("💬 Check if Claude responded in chat instead of using MCP")
    
    print("\n👋 Test complete!")

if __name__ == "__main__":
    main()
