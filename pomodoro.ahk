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
; pomo_time_len := 3 * 1000 * -1
; shortbreak_time_len := 3 * 1000 * -1
; longbreak_time_len := 3 * 1000 * -1

; Production paremeters
pomo_time_len := 25 * 60 * 1000 * -1
shortbreak_time_len := 5 * 60 * 1000 * -1
longbreak_time_len := 15 * 60 * 1000 * -1

; Internal varables
npomodone = 0

;; Ctrl-1: Start a pomodoro
^1::
  If (PomoInProgress = 1) {
    Msgbox, Err: Another pomodoro in progress.
    Return
  }

  PomoInProgress = 1
  Msgbox, Start a new pomodoro.
  ;SetTimer PomoComplete, -1500000
  SetTimer PomoEnd, %pomo_time_len%
  Return

;; Ctrl-2: Interrupt the current pomodoro
^2::
  If (PomoInProgress = 1) {
    Msgbox, Cancel current Pomodoro.
    SetTimer PomoEnd, Off
    WinActivate %tasklist_win%
    PomoInProgress = 0
  }
  Return

PomoEnd:
  WinActivate %tasklist_win%

  npomodone := npomodone + 1
  SoundPlay, *48
  Msgbox, Completed %npomodone% pomodoro.

  If (mod(npomodone, 4) != 0) {
    MsgBox Start short break.
    SetTimer ShortBreakEnd, %shortbreak_time_len%
  }
  Else {
    MsgBox Completed 4 pomodoroes.  Start long break.
    SetTimer LongBreakEnd, %longbreak_time_len%
  }
  
  PomoInProgress = 0
  Return

ShortBreakEnd:
  SoundPlay, *48
  Msgbox, Completed short break.
  Return 

LongBreakEnd:
  SoundPlay, *48
  Msgbox, Completed long break.
  Return 

; vim: expandtab tabstop=2 shiftwidth=2
