; Ctrl-middle-click to copy to clipboard
^MButton::
; SetTitleMatchMode, 2
; ClipSaved := ClipboardAll
; Clipboard =
; ; Hack to allow ctrl-c to work in vimperator
; IfWinActive, Vimperator
; {
;   Send ^v
; }
; Send ^c
; ClipWait, 2
; Run gvim -c "put +"
; sleep 300
; WinActivate, GVIM
; ClipSaved =
; Return

SetTitleMatchMode, 2
ClipSaved := ClipboardAll
; If my VNC box is active, just paste the content from the clipboard
; Note: in Unix, the content is already copied to clipboard if highlighted
IfWinNotActive, adc2100791
{
  Clipboard =
  ; Hack to allow ctrl-c to work in vimperator
  IfWinActive, imperator
  {
    Send ^v
  }
  Send ^c
  ClipWait, 2
}
Activate("gvim C:\MyData\_scratch_", "_scratch_")
sleep 300
Send Go{Escape}p
ClipSaved =
Return

; Remap keys:
;  - numpad_/ -> insert
;  - shift-backspace/ -> shift-insert
;  - capslock -> esc (in vim)
NumpadDiv::Insert
+Backspace::+Insert
Capslock::Esc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set transparent if not focus and always on top
; Ctrl-R_click: make win (under mouse) transparent & always on top.
; Ctrl-L_click: reverse Ctrl-R_click.
;;; Disabled: rarely used & conflict with win selection.
; ^RButton::
; MouseGetPos,,,MouseWin
; WinSet,Transparent,60,ahk_id %MouseWin%
; WinSet,AlwaysOnTop,On,ahk_id %MouseWin%
; Return
; 
; ^LButton::
; MouseGetPos,,,MouseWin
; WinSet,Transparent,Off,ahk_id %MouseWin%
; ; WinSet,Transparent,255,ahk_id %MouseWin%
; WinSet,AlwaysOnTop,Off,ahk_id %MouseWin%
; WinActivate, ahk_id %MouseWin% 
; Return

;; TODO: Transparent CAP not working.
;; Disable for now.  Since this is dangerous, windows can disappear and never
;; come back.
; ^WheelDown::
; MouseGetPos,,,MouseWin
; WinGet,Transparent,Transparent,ahk_id %MouseWin%
; Transparent -= 30
; Transparent = Transparent >= 30? Transparent : 30
; WinSet,Transparent,%Transparent%,ahk_id %MouseWin%
; WinSet,AlwaysOnTop,On,ahk_id %MouseWin%
; Return
; 
; ^WheelUp::
; MouseGetPos,,,MouseWin
; WinGet,Transparent,Transparent,ahk_id %MouseWin%
; Transparent += 30
; Transparent = Transparent <= 255? Transparent : 255
; WinSet,Transparent,%Transparent%,ahk_id %MouseWin%
; WinSet,AlwaysOnTop,On,ahk_id %MouseWin%
; Return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Windows key fns:
; Win-numpad_1: todo.otl
; Win-numpad_2: online-countdown.exe
; Win-numpad_7: task.otl
; Ctrl-`: toggle between _scratch_ and previous active window
; 
#Numpad1::
Activate("gvim C:\MyData\work\todo.otl", "todo.otl")
return

#Numpad2::
Activate("C:\public\bin\online-countdown.exe", "Adobe Flash Player 9")
return

#Numpad7::
Activate("c:\public\bin\tasklist.lnk", "task.otl")
return

^`::
IfWinActive, _scratch_
{
  WinMinimize, _scratch_
}
Else
{
  cmd = gvim "+autocmd FocusGained * winpos -10 -26" C:\MyData\_scratch_
  Activate(cmd, "_scratch_")
}

~Numpad1::
RapidHotkey("key_npad1",2,0.2,1)
return

key_npad1:
Activate("gvim C:\MyData\work\todo.otl", "todo.otl")
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

~Numpad2::
RapidHotkey("key_npad2",2,0.2,1)
return

key_npad2:
Activate("C:\public\bin\online-countdown.exe", "Adobe Flash Player 9")
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Keep track of how many times the same key is pressed. Invoke label when
; timeWindow expires.
WaitForMoreKeys(ByRef numPresses, label, timeWindow)
{
  If numPresses > 0
  {
    numPresses += 1
    return
  }
  
  numPresses = 1
  SetTimer, %label%, %timeWindow%
  return
}

; If prog with winTitle is running, bring it to focus; otherwise, run cmd, and
; bring it to focus.
Activate(cmd, winTitle)
{
  IfWinExist, %winTitle%
  {
    WinActivate
  }
  else
  {
    Run %cmd%
    WinWait %winTitle%
    WinActivate
  }
}


RapidHotkey(keystroke, times="2", delay=0.2, IsLabel=0)
{
   Pattern := Morse(delay*1000)
   If (StrLen(Pattern) < 2 and Chr(Asc(times)) != "1")
      Return
   If (times = "" and InStr(keystroke, """"))
   {
      Loop, Parse, keystroke,""   
         If (StrLen(Pattern) = A_Index+1)
            continue := A_Index, times := StrLen(Pattern)
   }
   Else if (RegExMatch(times, "^\d+$") and InStr(keystroke, """"))
   {
      Loop, Parse, keystroke,""
         If (StrLen(Pattern) = A_Index+times-1)
            times := StrLen(Pattern), continue := A_Index
   }
   Else if InStr(times, """")
   {
      Loop, Parse, times,""
         If (StrLen(Pattern) = A_LoopField)
            continue := A_Index, times := A_LoopField
   }
   Else if (times = "")
      continue := 1, times := 2
   Else if (times = StrLen(Pattern))
      continue = 1
   If !continue
      Return
   Loop, Parse, keystroke,""
      If (continue = A_Index)
         keystr := A_LoopField
   Loop, Parse, IsLabel,""
      If (continue = A_Index)
         IsLabel := A_LoopField
   hotkey := RegExReplace(A_ThisHotkey, "[\*\~\$\#\+\!\^]")
   IfInString, hotkey, %A_Space%
      StringTrimLeft, hotkey,hotkey,% InStr(hotkey,A_Space,1,0)
  Loop % times
      backspace .= "{Backspace}"
   keywait = Ctrl|Alt|Shift|LWin|RWin
   Loop, Parse, keywait, |
      KeyWait, %A_LoopField%
/*
   If ((!IsLabel or (IsLabel and IsLabel(keystr))) and InStr(A_ThisHotkey, "~") and !RegExMatch(A_ThisHotkey
   , "i)\^[^\!\d]|![^\d]|#|Control|Ctrl|LCtrl|RCtrl|Shift|RShift|LShift|RWin|LWin|Alt|LAlt|RAlt|Escape|BackSpace|F\d\d?|"
   . "Insert|Esc|Escape|BS|Delete|Home|End|PgDn|PgUp|Up|Down|Left|Right|ScrollLock|CapsLock|NumLock|AppsKey|"
   . "PrintScreen|CtrlDown|Pause|Break|Help|Sleep|Browser_Back|Browser_Forward|Browser_Refresh|Browser_Stop|"
   . "Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute|Volume_Down|Volume_Up|MButton|RButton|LButton|"
   . "Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media|Launch_App1|Launch_App2"))
      Send % backspace
*/
   If (WinExist("AHK_class #32768") and hotkey = "RButton")
      WinClose, AHK_class #32768
   If !IsLabel
      Send % keystr
   else if IsLabel(keystr)
      Gosub, %keystr%
   Return
}   

Morse(timeout = 400)
{ ;by Laszo -> http://www.autohotkey.com/forum/viewtopic.php?t=16951 (Modified to return: KeyWait %key%, T%tout%)
   tout := timeout/1000
   key := RegExReplace(A_ThisHotKey,"[\*\~\$\#\+\!\^]")
   IfInString, key, %A_Space%
   StringTrimLeft, key, key,% InStr(key,A_Space,1,0)
   Loop {
      t := A_TickCount
      KeyWait %key%, T%tout%
      Pattern .= A_TickCount-t > timeout
      If(ErrorLevel)
         Return Pattern
      Input,pressed,T%tout% L1 V,{%key%}
      If (ErrorLevel="Timeout")
         Return Pattern
      else if (ErrorLevel="Max")
         Return
   }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
