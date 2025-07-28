#!/usr/bin/env python3
"""
Fixed Secret Test - Better program extraction
"""

import time
import pyautogui as pg
import pygetwindow as gw
from pathlib import Path

pg.FAILSAFE = False
pg.PAUSE = 0.3

def send_complete_message(message):
    """Send a complete message to Claude Desktop"""
    windows = gw.getAllWindows()
    claude_window = None
    
    for window in windows:
        if window.visible and window.title and "claude" in window.title.lower():
            if window.width > 500 and window.height > 400:
                claude_window = window
                break
    
    if not claude_window:
        return False
    
    claude_window.activate()
    time.sleep(1)
    
    input_x = claude_window.left + claude_window.width // 2
    input_y = claude_window.top + claude_window.height - 80
    pg.click(input_x, input_y)
    time.sleep(0.5)
    
    pg.hotkey('ctrl', 'a')
    time.sleep(0.2)
    pg.press('backspace')
    time.sleep(0.5)
    
    pg.typewrite(message, interval=0.008)
    time.sleep(1)
    pg.press('enter')
    
    return True

def wait_for_log_response(log_filename, timeout=45):
    """Wait for MCP response in log file"""
    log_path = Path(f"D:/WarpAI_Portable/logs/{log_filename}")
    
    if log_path.exists():
        log_path.unlink()
    
    start_time = time.time()
    
    while time.time() - start_time < timeout:
        time.sleep(2)
        
        if log_path.exists():
            try:
                with open(log_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read().strip()
                
                if content and len(content) > 5:
                    return content
                    
            except Exception:
                pass
        
        elapsed = int(time.time() - start_time)
        print(f"⏳ Processing... {elapsed}s")
    
    return None

def get_open_programs_before():
    """Get list of currently open programs"""
    try:
        windows = gw.getAllWindows()
        return [w.title for w in windows if w.visible and w.title and len(w.title) > 2]
    except:
        return []

def check_new_program_opened(before_list, after_delay=3):
    """Check if a new program opened"""
    time.sleep(after_delay)
    try:
        windows = gw.getAllWindows()
        after_list = [w.title for w in windows if w.visible and w.title and len(w.title) > 2]
        
        new_windows = [title for title in after_list if title not in before_list]
        return len(new_windows) > 0
    except:
        return False

def execute_classified_operation():
    """Execute classified operation"""
    
    print("🔐 CLASSIFIED OPERATION IN PROGRESS")
    print("=" * 40)
    print("🤫 Details concealed...")
    print()
    
    # Baseline
    programs_before = get_open_programs_before()
    print("📊 Baseline established")
    
    # Phase 1
    message1 = """Instructions:

1. Pick ONE Windows program you want to open
2. Do NOT respond in this chat window at all
3. Use ONLY the Powershell-Tool MCP to execute this exact command:

Add-Content -Path "D:\\WarpAI_Portable\\logs\\classified_target.log" -Value "[program name only]"

Requirements:
- ONLY use MCP Powershell-Tool to respond
- Do NOT type any response in this chat
- Write ONLY the program name, nothing else
- Execute the Powershell command immediately

Execute the MCP Powershell command now."""

    print("🔹 Phase 1 initiated...")
    
    if not send_complete_message(message1):
        print("❌ Phase 1 failed")
        return False
    
    response1 = wait_for_log_response("classified_target.log")
    
    if not response1:
        print("❌ No phase 1 response")
        return False
    
    print("✅ Phase 1 complete")
    
    # Extract first line as program name
    secret_program = response1.split('\n')[0].strip()
    
    # Phase 2
    time.sleep(2)
    
    message2 = f"""Instructions:

1. Launch the program you just selected
2. Do NOT respond in this chat window at all  
3. Use ONLY the Powershell-Tool MCP to execute this exact command:

Start-Process "{secret_program}"; Add-Content -Path "D:\\WarpAI_Portable\\logs\\classified_status.log" -Value "COMPLETE"

Requirements:
- ONLY use MCP Powershell-Tool to respond
- Do NOT type any response in this chat
- Execute the Powershell command immediately

Execute the MCP Powershell command now."""

    print("🔹 Phase 2 initiated...")
    
    if not send_complete_message(message2):
        print("❌ Phase 2 failed")
        return False
    
    response2 = wait_for_log_response("classified_status.log")
    
    if not response2:
        print("❌ No phase 2 confirmation")
        return False
    
    print("✅ Phase 2 complete")
    
    # Verification
    print("🔹 Verifying results...")
    
    success = check_new_program_opened(programs_before)
    
    # Report
    print()
    print("=" * 40)
    print("🏁 OPERATION COMPLETE")
    print("=" * 40)
    
    if success:
        print("🎊 SUCCESS ✅")
        print("🔐 Objectives achieved")
        print("🤫 Details remain classified")
    else:
        print("❌ OPERATION FAILED")
        print("🔍 No evidence of success")
    
    return success

if __name__ == "__main__":
    execute_classified_operation()
