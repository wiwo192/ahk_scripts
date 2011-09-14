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

;; Ctrl-1: Start a pomodoro
^1::
  If (PomoInProgress = 1) {
    Msgbox, Error: Another pomodoro in progress.
    Return
  }

  Msgbox, Start a new pomodoro.
  PomoInProgress = 1
  startTime := A_Now
  timeLen := pomo_time_len // 1000 * -1
  SetTimer PomoEnd, %pomo_time_len%
  Return

;; Ctrl-2: Interrupt the current pomodoro
^2::
  If (PomoInProgress != 1) {
    Return
  }

  Msgbox, Cancel current Pomodoro and Breaks.
  SetTimer PomoEnd, Off
  SetTimer ShortBreakEnd, Off
  SetTimer LongBreakEnd, Off
  WinActivate %tasklist_win%
  PomoInProgress = 0
  Return

^3::
  if (PomoInProgress != 1) { 
    Return
  }

  DisplayProgress(startTime, timelen)
  Return

PomoEnd:
  npomodone := npomodone + 1
  SoundPlay, *48
  Msgbox, Completed %npomodone% pomodoro.

  If (mod(npomodone, 4) != 0) {
    MsgBox Start short break.
    startTime := A_Now
    timeLen := shortbreak_time_len // 1000 * -1
    SetTimer ShortBreakEnd, %shortbreak_time_len%
  }
  Else {
    MsgBox Completed 4 pomodoroes.  Start long break.
    startTime := A_Now
    timeLen := longbreak_time_len // 1000 * -1
    SetTimer LongBreakEnd, %longbreak_time_len%
  }

  WinActivate %tasklist_win%

  Return

ShortBreakEnd:
  PomoInProgress = 0
  SoundPlay, *48
  Msgbox, Completed short break.
  Return

LongBreakEnd:
  PomoInProgress = 0
  SoundPlay, *48
  Msgbox, Completed long break.
  Return

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
