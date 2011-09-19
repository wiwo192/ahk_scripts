  ; TODO: improve *_time_len user interface by using middle vars
  ; TODO: Convert break timer into sleep
  ; TODO: convert PomoInProgress into states: idle, pomo, break.
  ; TODO: Display remaining time.
  ; TODO: Warning for remaining time
  ; TODO: Replace Msgbox w/ flash text if possible
  ; TODO: Add sound: SoundPlay to events

tasklist_win = _scratch_
; time_len is in ms. need to be negative.
; Testing parameters
; pomo_time_len := 10 * 1000 * -1
; shortbreak_time_len := 3 * 1000 * -1
; longbreak_time_len := 3 * 1000 * -1

; Production paremeters
pomo_time_len := 25 * 60 * 1000 * -1
shortbreak_time_len := 5 * 60 * 1000 * -1
longbreak_time_len := 15 * 60 * 1000 * -1

; Internal varables
npomodone = 0

;================================= Setup hotkeys =================================
;; Ctrl-space: Toggle Start/Stop a pomodoro
^space::
  PomoInProgress := Not PomoInProgress
  If (PomoInProgress = 1) {
    Goto StartPomodoro
  }
  Else {
    Goto StopPomodoro
  }

~LCtrl & ~LShift::
  start := A_TickCount
  KeyWait, LShift, T1
  end := A_TickCount
  holdTime := end - start

  If (holdTime < 1000) {
    Return
  }
  Goto DisplayProgress

;; Double LCtrl: display time progress
~LCtrl::
  If (A_PriorHotKey <> "~LCtrl" or A_TimeSincePriorHotkey > 400) {
    KeyWait, LCtrl
    Return
  }
  ;; LCtrl was double pressed...
  Goto DisplayProgress

;================================= Pomodoro core =================================
DisplayProgress:
  if (PomoInProgress != 1) { 
    Return
  }
  DisplayProgress(startTime, timelen)
  Return 

StartPomodoro:
  Msgbox,,, Start a new pomodoro., 2
  PomoInProgress = 1
  startTime := A_Now
  timeLen := pomo_time_len // 1000 * -1
  SetTimer PomoEnd, %pomo_time_len%
  Return

PomoEnd:
  npomodone := npomodone + 1
  SoundPlay, *48
  Msgbox,,, Completed %npomodone% pomodoro., 2

  If (mod(npomodone, 4) != 0) {
    MsgBox,,, Start short break., 2
    startTime := A_Now
    timeLen := shortbreak_time_len // 1000 * -1
    SetTimer ShortBreakEnd, %shortbreak_time_len%
  }
  Else {
    MsgBox,,, Completed 4 pomodoroes.  Start long break., 2
    startTime := A_Now
    timeLen := longbreak_time_len // 1000 * -1
    SetTimer LongBreakEnd, %longbreak_time_len%
  }

  WinActivate %tasklist_win%

  Return

ShortBreakEnd:
  PomoInProgress = 0
  SoundPlay, *48
  Msgbox,,, Completed short break., 2
  Return

LongBreakEnd:
  PomoInProgress = 0
  SoundPlay, *48
  Msgbox,,, Completed long break., 2
  Return

StopPomodoro:
  Msgbox,,, Cancel current Pomodoro and Breaks., 2
  SetTimer PomoEnd, Off
  SetTimer ShortBreakEnd, Off
  SetTimer LongBreakEnd, Off
  WinActivate %tasklist_win%
  PomoInProgress = 0
  Return

;================================= Functions =================================
;; startTime: date_value in sec.
;; timelen: in sec
DisplayProgress(startTime, timeLen) {
  currTime := A_Now

  elapseInSec := currTime
  elapseInSec -= %startTime%, seconds

  timeLeftInSec := timeLen - elapseInSec
  mm := timeLeftInSec // 60
  ss := mod(timeLeftInSec, 60)

  Progress, B1 W200 R0-%timeLen%, Time remaining: %mm%:%ss%
  Progress, %elapseInSec%
  sleep 1500
  Progress, Off

  Return
}

; vim: expandtab tabstop=2 shiftwidth=2
