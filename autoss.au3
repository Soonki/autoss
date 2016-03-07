;
; Name: AutoCapture.exe (by soonki.ji@gmail.com), 2009-11-01
; Author: soonki.ji@gmail.com
; Desc: Take a screenshot for each mouse click, enter key or active window title change.
;
#include <timers.au3>
#include <ScreenCapture.au3>
#include <Date.au3>
#include <Constants.au3>
#include <WinAPI.au3>
#Include <Misc.au3>

Func TakeSnapshotOfFullScreen($jpgName, $ext)
    Local $handle
	$fileName = $jpgName & $ext;
    $handle = _ScreenCapture_Capture ("")	
    _ScreenCapture_SaveImage ($fileName, $handle);
	_WinAPI_DeleteObject($handle);
	If ($beep) Then
		Beep(550, 50)
	EndIf
EndFunc

Func TakeSnapshotOfActiveWindow($jpgName, $ext)
    Local $handle
	$fileName = $jpgName & $ext;
    $handle = WinGetHandle("[active]");
	_ScreenCapture_CaptureWnd ($fileName, $handle);
	_WinAPI_DeleteObject($handle);
	If ($beep) Then
		Beep(550, 50)
	EndIf
EndFunc

func LeftOrRightMouseButtonPressed()
	return _IsPressed("01") or _IsPressed("02");
EndFunc

func AreBothLeftOrRightShiftKeyPressed()
	return _IsPressed("A0") and _IsPressed("A1");
EndFunc

func EnterKeyPressed()
	return _IsPressed("0D");
EndFunc

func CtrlPressed()
	return _IsPressed("11");
EndFunc

Func showAbout()
	Local $s
               $s = "                  AutoCapture v1.0                  ";
	$s = $s & @LF & "";
	$s = $s & @LF & "                 soonki.ji@gmail.com                ";
	$s = $s & @LF & "";
	MsgBox(0, "About AutoCapture 1.0", $s, 1);
EndFunc

Func getDateTimeString()
	return @Year & @MON & @MDAY & "_" & @HOUR & @MIN & @SEC;
EndFunc

Func howMany($num, $noun, $plural)
	if ($num = 0) Then
		return "No " & $noun;
	elseif ($num = 1) Then
		return $num & " " & $noun;
	else 
		return $num & " " & $noun & $plural;
	EndIf
EndFunc

Func GetTrimmedActiveWindowTitle()
	$s = WinGetTitle("[active]")
	$s = StringRegExpReplace($s, "[^a-zA-Z0-9]", "_");
	$s = StringRegExpReplace($s, "__*", "_");
	return $s;
EndFunc

Func msg($s)
	$pos = MouseGetPos();
	$width = 60;
	$height = 18;
	$opt = 1 + 32;
	If ($verbose = 1) Then
		if ($pos[0] <= 250 and $pos[1] <= $height) Then
			SplashTextOn("", $s, 250, $height, 0, @Desktopheight - 35, 1 + 4, "", 8);
		Else
			SplashTextOn("", $s, 250, $height, 0, 0, 1 + 4, "", 8);
		EndIf
	elseif ($verbose >= 2) Then		
		if ($pos[0] <= $width and $pos[1] <= $height) Then
			SplashTextOn("", $s, $width, $height, 0, @DesktopHeight - 35, $opt, "", 8);
		Else			
			SplashTextOn("", $s, $width, $height, 0, 0, $opt, "", 8);
		EndIf
	EndIf
EndFunc

$maxIdle = 60;
$beep = 0;

showAbout();

$filePrefix = getDateTimeString();
$pos = MouseGetPos();
$files = 0;
$display = 0;
$sessionStart = _Timer_Init();
$desc = "";
$verbose = 2;
While (true)
	$event = 0;
	$prevIdle = 0;
	$prevWinTitle = GetTrimmedActiveWindowTitle();
	while ($event = 0)
		If (EnterKeyPressed() or AreBothLeftOrRightShiftKeyPressed()) Then 
			$desc = "keyboard";
			$event = 1;
		EndIf
		If (LeftOrRightMouseButtonPressed()) Then			
			While (LeftOrRightMouseButtonPressed())
				Sleep(10);
			WEnd
			$desc = "mouseclick";
			$event = 1;
		EndIf
		$winTitle = GetTrimmedActiveWindowTitle();
		if ($prevWinTitle <> $winTitle) Then
			$prevWinTitle = $winTitle;
			$desc = "wintitlechanged";
			$event = 1;
		EndIf			
		if ($event = 0) Then
			if ($display = 0) Then
				;msg(howMany($files, "screenshot", "s") & " in session " & $filePrefix & $desc);
				msg($files);
			Else
				$idle = int(_Timer_GetIdleTime() / 1000);
				if ($previdle <> $idle) Then
					if ($idle >= ($maxIdle - 5)) Then
						If ($idle >= $maxIdle) Then
							$filePrefix = getDateTimeString();
							$files = 0;
							$sessionStart = _Timer_Init();
							$desc = "";
							;msg(howMany($files, "screenshot", "s") & " in session " & $filePrefix);
							msg($files);
							While (_Timer_GetIdleTime() > 10)
								Sleep(5);
							WEnd
						Else
							;msg(howMany($files, "screenshot", "s") & " in session " & $filePrefix & ". Idle for " & $idle & " secs (max " & $maxIdle & ")");
							msg($files);
						EndIf
					Else
						;msg(howMany($files, "screenshot", "s") & " in session " & $filePrefix & $desc);
						msg($files);
					EndIf
					$previdle = $idle;
				EndIf
			EndIf
			$display = 1;
			Sleep(10);
		EndIf
	WEnd
	
	Sleep(100);
	SplashOff()
	$display = 0;
	Sleep(200);
	$now = getDateTimeString();
	; TakeSnapshotOfFullScreen($filePrefix & "-" &  $now & "-" & $desc, ".png");
	TakeSnapshotOfFullScreen($filePrefix & "-" &  $now, ".png");
	$files = $files + 1;
WEnd
