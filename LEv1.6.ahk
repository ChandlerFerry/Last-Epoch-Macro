#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetKeyDelay, -1
SetMouseDelay, -1

; SetTimer, SetUseAegis, 14300 ; Flame Ward Cooldown
; Increased Cast Speed Stat (86% = 0.86 | 195% = 1.95)
castSpeed := 0.87

; Equipment
wrongWarp := false
stunIdolsSeconds := 6

; Runemaster Passives
runeOfDilationLevel := 2

; Sorc Passives
arcaneMomentumLevel := 5

; Runic Invocation Specialization
runeSlingerLevel := 3
transcriberOfPowerLevel := 1

; Runebolt Specialization
arcanistLevel := 4

; Frost Wall Specialization
boostedKickoffLevel := 1

; Key documentation: https://documentation.help/AutoHotkey-en/KeyList.htm
; Hotkey declaration NOTE: each declaration needs to be encapsulated with quotes ex := "x"
; CHANGE THE BELOW KEYS TO THE KEYS YOU WANT TO USE
runebolt_key := "q" 
runicinvocation_key := "r"
icerune_key := "e" ; Frost Wall
firerune_key := "g" ; Flame Ward
teleport_hotkey := "w"
potion_key := "1"

centerScreenX := 1715
centerScreenY := 663

; State Variables
runeBoltAnimationSpeed := 600
runicInvocationAnimationSpeed := 800
iceRuneAnimationSpeed := 500
warpBuff := 0
arcaneMomentumStacks := 0
transcriberOfPower := 0
warp_position := 0
castSpeedShrine := 0
wrongWarpCastSpeed := 0
frenzyCastSpeed := 0
runicInvocationSpecificCastSpeed := runeSlingerLevel*0.05
runeboltSpecificCastSpeed := runeSlingerLevel*0.04
stunImmune := false
useAegis := false
castSpeed -= 0.01 ; Rounding Sanity

; Hotkeys
Hotkey, IfWinActive, Last Epoch
Hotkey, *~%teleport_hotkey%, TeleportHandling
Hotkey, IfWinActive

NumpadMult::Reload

#IfWinActive Last Epoch

; Cast plasma orb
*XButton2::
While (GetKeyState("XButton2", "P"))
{
   BecomeStunImmune()
   skey(runebolt_key)
   CastSpeedSleep(runeBoltAnimationSpeed, runeboltSpecificCastSpeed)
   BecomeStunImmune()
   skey(runebolt_key)
   CastSpeedSleep(runeBoltAnimationSpeed, runeboltSpecificCastSpeed)
   BecomeStunImmune()
   skey(runebolt_key)
   CastSpeedSleep(runeBoltAnimationSpeed, runeboltSpecificCastSpeed)
   Sleep, 20
   skey(runicinvocation_key)
   CastSpeedSleep(runicInvocationAnimationSpeed, runicInvocationSpecificCastSpeed)
}
Return

; Cast aegis shield (Reowyn's Frostguard)
*MButton::
{
   Aegis()
}
Return

; Warp to positions 1-4
*F1::
{
   warp(59, 103 + warp_position * 113)
}
Return

; Cast Speed Shrine
Up::
   castSpeedShrine := 0.3
   SetTimer, DisableCastSpeedShrine, 55000
Return

; decrement the position of warping
*Down::
{
   warp_position := Mod(warp_position - 1, 4)

   warp_pos := warp_position + 1
   ToolTip, Warp Pos: %warp_pos%
   SetTimer, RemoveToolTip, 1000
}
Return
; increment the position of warping
*Up::
{
   warp_position := Mod(warp_position + 1, 4)

   warp_pos := warp_position + 1
   ToolTip, Warp Pos: %warp_pos%
   SetTimer, RemoveToolTip, 1000
}
Return

; Remove visible tooltip
RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
Return

#IfWinActive

skey(key)
{
   global
   if (key == "RButton")
   {
      Send, {Click, Right}
   }
   else
   {
      Send, {%key% down}
      Sleep, 10
      Send, {%key% up}
   }
}

Aegis()
{
   global
   useAegis := false
   BlockInput, MouseMove
   MouseGetPos, curX, curY
   skey(icerune_key)
   CastSpeedSleep(iceRuneAnimationSpeed)
   skey(firerune_key)
   MouseMove, %centerScreenX%, %centerScreenY%
   skey(icerune_key)
   CastSpeedSleep(iceRuneAnimationSpeed)
   if (boostedKickoffLevel >= 1) {
      frenzyCastSpeed := 0.2
      SetTimer, DisableBoostedKickoffBuff, 1000
   }
   Sleep, 20
   MouseMove, %curX%, %curY%
   BlockInput, MouseMoveOff
   skey(runicinvocation_key)
   CastSpeedSleep(runicInvocationAnimationSpeed, runicInvocationSpecificCastSpeed)
}

; Use potion when teleporting (experimental belt mod: X Seconds of Traversel CDR)
TeleportHandling()
{
   global
   stunImmune := true
   warpBuff := 0.1
   if (wrongWarp) {
      wrongWarpCastSpeed := 0.35
      SetTimer, DisableWrongwarpBuff, 9900
   }
   SetTimer, DisableStunImmune, % stunIdolsSeconds * 1000 * 0.93
   SetTimer, DisableWarpBuff, % runeOfDilationLevel * 950
   SetTimer, DrinkPotion, 100
   Return
}

DisableBoostedKickoffBuff()
{
   global
   SetTimer, DisableBoostedKickoffBuff, Off
   frenzyCastSpeed := 0
}

DisableWrongwarpBuff()
{
   global
   SetTimer, DisableWrongwarpBuff, Off
   wrongWarpCastSpeed := 0
}

DisableWarpBuff()
{
   global
   SetTimer, DisableWarpBuff, Off
   warpBuff := 0
}

DisableStunImmune()
{
   global
   SetTimer, DisableStunImmune, Off
   stunImmune := false
   
}
DisableCastSpeedShrine()
{
   global
   SetTimer, DisableCastSpeedShrine, Off
   castSpeedShrine := 0
}

DrinkPotion()
{
   global
   SetTimer, DrinkPotion, Off
   skey(potion_key)
}

ResetArcaneMomentum()
{
   global
   SetTimer, ResetArcaneMomentum, Off
   arcaneMomentumStacks := 0
}

ResetTranscriberOfPower()
{
   global
   SetTimer, ResetTranscriberOfPower, Off
   transcriberOfPower := 0
}

SetUseAegis()
{
   global
   useAegis := true
}

BecomeStunImmune()
{
   global
   if (!stunImmune)
   {
      stunImmune := true
      skey(teleport_hotkey)
      TeleportHandling()
      CastSpeedSleep(750)
   }
}

CastSpeedSleep(baseSpeed, specificSkillCastSpeed = 0)
{
   global
   SetTimer, ResetArcaneMomentum, 1900
   
   Sleep, Ceil((baseSpeed / (1 + castSpeed + warpBuff + (arcaneMomentumStacks*0.05) + transcriberOfPower + specificSkillCastSpeed + castSpeedShrine + wrongWarpCastSpeed + frenzyCastSpeed)))
   if(arcaneMomentumStacks < arcaneMomentumLevel)
   {
      arcaneMomentumStacks += 1
   }
}
; Function to store original position of mouse
warp(x, y)
{
   BlockInput, MouseMove
   ; Get the current mouse position
   MouseGetPos, OriginalMouseX, OriginalMouseY

   ; Click at the specified position
   Click, %x%, %y%
   Sleep, 10
   Click, %x%, %y%   ; Second click to (hopefully) ensure the click goes through

   ; Return the mouse to its original position
   MouseMove, %OriginalMouseX%, %OriginalMouseY%, 0
   BlockInput, MouseMoveOff
}


Mod(x, y) 
{
   return x - y * Floor(x / y)
}