#!/usr/bin/env python3
"""
Log-Monitored Claude Desktop Sender
Uses USB drive logs to know when Claude Desktop has finished responding
"""

import time
import pyautogui as pg
import pygetwindow as gw
from datetime import datetime
from pathlib import Path
import json

# Disable fail-safe and set pause
pg.FAILSAFE = False
pg.PAUSE = 0.3

class LogMonitoredSender:
    def __init__(self):
        self.claude_window = None
        self.log_path = Path("D:/WarpAI_Portable/logs/claude_desktop_responses.log")
        self.conversation_id = datetime.now().strftime("%Y%m%d_%H%M%S")
        
    def find_claude_desktop(self):
        """Find Claude Desktop window"""
        print("🔍 Searching for Claude Desktop window...")
        
        windows = gw.getAllWindows()
        
        for window in windows:
            if window.visible and window.title:
                title_lower = window.title.lower()
                if any(phrase in title_lower for phrase in ["claude", "untitled"]):
                    if window.width > 500 and window.height > 400:
                        self.claude_window = window
                        print(f"✅ Found Claude Desktop: '{window.title}'")
                        return True
        
        return False
        
    def bring_to_front(self):
        """Bring Claude Desktop to front"""
        if not self.claude_window:
            return False
            
        try:
            if self.claude_window.isMinimized:
                self.claude_window.restore()
                time.sleep(0.5)
            
            self.claude_window.activate()
            time.sleep(0.8)
            
            center_x = self.claude_window.left + self.claude_window.width // 2
            center_y = self.claude_window.top + self.claude_window.height // 2
            pg.click(center_x, center_y)
            time.sleep(0.5)
            
            return True
        except Exception as e:
            print(f"❌ Failed to bring window to front: {e}")
            return False
            
    def send_message_with_log_request(self, message, command_id):
        """Send message and ask Claude Desktop to update the log when done"""
        
        # Create the full message with log update request
        full_message = f"""{message}

---
IMPORTANT: When you finish responding to this message, please use the Powershell-Tool to execute this command:

Add-Content -Path "D:\\WarpAI_Portable\\logs\\claude_desktop_responses.log" -Value "[{datetime.now().isoformat()}] RESPONSE_COMPLETE: Command_{command_id} - Message processed and response sent"

This helps me know when you're ready for the next message! 🤖"""

        if not self.find_claude_desktop():
            return False
            
        if not self.bring_to_front():
            return False
            
        # Find input box and send
        window_left = self.claude_window.left
        window_top = self.claude_window.top
        window_width = self.claude_window.width
        window_height = self.claude_window.height
        
        # Click in input area
        input_x = window_left + window_width // 2
        input_y = window_top + window_height - 80
        
        pg.click(input_x, input_y)
        time.sleep(0.5)
        
        # Clear and type message
        pg.hotkey('ctrl', 'a')
        time.sleep(0.2)
        pg.press('backspace')
        time.sleep(0.3)
        
        pg.typewrite(full_message, interval=0.01)
        time.sleep(0.5)
        
        # Send
        pg.press('enter')
        time.sleep(0.5)
        
        print(f"✅ Message sent with log update request (Command_{command_id})")
        return True
        
    def wait_for_log_update(self, command_id, timeout=180):
        """Monitor the log file for update from Claude Desktop"""
        print(f"👁️ Monitoring log file for Command_{command_id} completion...")
        
        start_time = time.time()
        last_check_time = time.time()
        
        # Get initial log size if file exists
        initial_size = 0
        if self.log_path.exists():
            initial_size = self.log_path.stat().st_size
            
        while time.time() - start_time < timeout:
            time.sleep(3)  # Check every 3 seconds
            
            if self.log_path.exists():
                # Check if file has been modified
                current_size = self.log_path.stat().st_size
                
                if current_size > initial_size:
                    # Read the new content
                    try:
                        with open(self.log_path, 'r', encoding='utf-8') as f:
                            content = f.read()
                            
                        # Check for our specific completion marker
                        completion_marker = f"RESPONSE_COMPLETE: Command_{command_id}"
                        if completion_marker in content:
                            print(f"✅ Claude Desktop completed Command_{command_id}!")
                            
                            # Show the latest log entries
                            lines = content.strip().split('\n')
                            print("📋 Latest log entries:")
                            for line in lines[-3:]:  # Show last 3 lines
                                print(f"   {line}")
                                
                            return True
                            
                    except Exception as e:
                        print(f"⚠️ Error reading log file: {e}")
            
            # Show progress
            elapsed = int(time.time() - start_time)
            print(f"⏳ Still waiting for log update... ({elapsed}s elapsed)")
            
        print(f"⚠️ Timeout waiting for Command_{command_id} completion")
        return False
        
    def create_initial_log_entry(self):
        """Create initial log entry"""
        log_entry = f"""
=== CLAUDE-TO-CLAUDE COMMUNICATION LOG ===
Session Started: {datetime.now().isoformat()}
Conversation ID: {self.conversation_id}
Log Path: {self.log_path}

[{datetime.now().isoformat()}] WARP_AI_CLAUDE: Communication bridge established!
[{datetime.now().isoformat()}] SYSTEM: Monitoring Claude Desktop responses via log updates

"""
        
        # Ensure directory exists
        self.log_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(self.log_path, 'w', encoding='utf-8') as f:
            f.write(log_entry)
            
        print(f"📝 Log file created: {self.log_path}")
        
    def send_and_wait(self, message, command_id):
        """Send message and wait for log-based confirmation"""
        print(f"\n📨 Command_{command_id}: {message[:50]}...")
        
        # Send message with log request
        if not self.send_message_with_log_request(message, command_id):
            print(f"❌ Failed to send Command_{command_id}")
            return False
            
        # Wait for log update
        if self.wait_for_log_update(command_id):
            print(f"✅ Command_{command_id} completed successfully!")
            return True
        else:
            print(f"❌ Command_{command_id} timed out or failed")
            return False
            
    def start_log_monitored_conversation(self):
        """Start conversation with log monitoring"""
        print("🚀 LOG-MONITORED CLAUDE DESKTOP COMMUNICATION")
        print("=" * 60)
        
        # Create initial log file
        self.create_initial_log_entry()
        
        # Define conversation sequence
        commands = [
            {
                "id": 1,
                "message": f"""🚀 HELLO CLAUDE DESKTOP!

This is Warp AI Claude establishing log-monitored communication!

Time: {datetime.now().strftime('%H:%M:%S')}
Session: {self.conversation_id}

I can now monitor when you complete tasks by watching our log file!

FIRST TASK: Please use State-Tool with use_vision=True to take a screenshot of the desktop and describe what you see."""
            },
            {
                "id": 2, 
                "message": "Excellent! Now can you use Launch-Tool to open Notepad application?"
            },
            {
                "id": 3,
                "message": "Great! Can you use the Type-Tool to write 'Hello from Claude Desktop!' in the Notepad window?"
            }
        ]
        
        # Execute commands with log monitoring
        for cmd in commands:
            if self.send_and_wait(cmd["message"], cmd["id"]):
                print(f"✅ Moving to next command...")
                time.sleep(2)  # Brief pause between commands
            else:
                print(f"❌ Stopping due to command failure")
                break
                
        print("\n🎉 Log-monitored conversation completed!")
        print(f"📊 Check log file: {self.log_path}")

def main():
    sender = LogMonitoredSender()
    
    try:
        sender.start_log_monitored_conversation()
        
    except KeyboardInterrupt:
        print("\n🛑 Cancelled by user")
    except Exception as e:
        print(f"\n❌ Error: {e}")
        
    print("\nDone! 👋")

if __name__ == "__main__":
    main()
