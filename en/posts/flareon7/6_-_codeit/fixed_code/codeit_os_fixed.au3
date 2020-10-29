#Region
	#AutoIt3Wrapper_UseUpx=y
#EndRegion
Global Const $str_nocasesense = 0
Global Const $str_casesense = 1
Global Const $str_nocasesensebasic = 2
Global Const $str_stripleading = 1
Global Const $str_striptrailing = 2
Global Const $str_stripspaces = 4
Global Const $str_stripall = 8
Global Const $str_chrsplit = 0
Global Const $str_entiresplit = 1
Global Const $str_nocount = 2
Global Const $str_regexpmatch = 0
Global Const $str_regexparraymatch = 1
Global Const $str_regexparrayfullmatch = 2
Global Const $str_regexparrayglobalmatch = 3
Global Const $str_regexparrayglobalfullmatch = 4
Global Const $str_endisstart = 0
Global Const $str_endnotstart = 1
Global Const $sb_ansi = 1
Global Const $sb_utf16le = 2
Global Const $sb_utf16be = 3
Global Const $sb_utf8 = 4
Global Const $se_utf16 = 0
Global Const $se_ansi = 1
Global Const $se_utf8 = 2
Global Const $str_utf16 = 0
Global Const $str_ucs2 = 1

Func _hextostring($shex)
	If NOT (StringLeft($shex, 2) == "0x") Then $shex = "0x" & $shex
	Return BinaryToString($shex, $sb_utf8)
EndFunc

Func _stringbetween($sstring, $sstart, $send, $imode = $str_endisstart, $bcase = False)
	$sstart = $sstart ? "\Q" & $sstart & "\E" : "\A"
	If $imode <> $str_endnotstart Then $imode = $str_endisstart
	If $imode = $str_endisstart Then
		$send = $send ? "(?=\Q" & $send & "\E)" : "\z"
	Else
		$send = $send ? "\Q" & $send & "\E" : "\z"
	EndIf
	If $bcase = Default Then
		$bcase = False
	EndIf
	Local $areturn = StringRegExp($sstring, "(?s" & (NOT $bcase ? "i" : "") & ")" & $sstart & "(.*?)" & $send, $str_regexparrayglobalmatch)
	If @error Then Return SetError(1, 0, 0)
	Return $areturn
EndFunc

Func _stringexplode($sstring, $sdelimiter, $ilimit = 0)
	If $ilimit = Default Then $ilimit = 0
	If $ilimit > 0 Then
		Local Const $null = Chr(0)
		$sstring = StringReplace($sstring, $sdelimiter, $null, $ilimit)
		$sdelimiter = $null
	ElseIf $ilimit < 0 Then
		Local $iindex = StringInStr($sstring, $sdelimiter, $str_nocasesensebasic, $ilimit)
		If $iindex Then
			$sstring = StringLeft($sstring, $iindex - 1)
		EndIf
	EndIf
	Return StringSplit($sstring, $sdelimiter, BitOR($str_entiresplit, $str_nocount))
EndFunc

Func _stringinsert($sstring, $sinsertion, $iposition)
	Local $ilength = StringLen($sstring)
	$iposition = Int($iposition)
	If $iposition < 0 Then $iposition = $ilength + $iposition
	If $ilength < $iposition OR $iposition < 0 Then Return SetError(1, 0, $sstring)
	Return StringLeft($sstring, $iposition) & $sinsertion & StringRight($sstring, $ilength - $iposition)
EndFunc

Func _stringproper($sstring)
	Local $bcapnext = True, $schr = "", $sreturn = ""
	For $i = 1 To StringLen($sstring)
		$schr = StringMid($sstring, $i, 1)
		Select 
			Case $bcapnext = True
				If StringRegExp($schr, "[a-zA-ZÀ-ÿšœžŸ]") Then
					$schr = StringUpper($schr)
					$bcapnext = False
				EndIf
			Case NOT StringRegExp($schr, "[a-zA-ZÀ-ÿšœžŸ]")
				$bcapnext = True
			Case Else
				$schr = StringLower($schr)
		EndSelect
		$sreturn &= $schr
	Next
	Return $sreturn
EndFunc

Func _stringrepeat($sstring, $irepeatcount)
	$irepeatcount = Int($irepeatcount)
	If $irepeatcount = 0 Then Return ""
	If StringLen($sstring) < 1 OR $irepeatcount < 0 Then Return SetError(1, 0, "")
	Local $sresult = ""
	While $irepeatcount > 1
		If BitAND($irepeatcount, 1) Then $sresult &= $sstring
		$sstring &= $sstring
		$irepeatcount = BitShift($irepeatcount, 1)
	WEnd
	Return $sstring & $sresult
EndFunc

Func _stringtitlecase($sstring)
	Local $bcapnext = True, $schr = "", $sreturn = ""
	For $i = 1 To StringLen($sstring)
		$schr = StringMid($sstring, $i, 1)
		Select 
			Case $bcapnext = True
				If StringRegExp($schr, "[a-zA-Z\xC0-\xFF0-9]") Then
					$schr = StringUpper($schr)
					$bcapnext = False
				EndIf
			Case NOT StringRegExp($schr, "[a-zA-Z\xC0-\xFF'0-9]")
				$bcapnext = True
			Case Else
				$schr = StringLower($schr)
		EndSelect
		$sreturn &= $schr
	Next
	Return $sreturn
EndFunc

Func _stringtohex($sstring)
	Return Hex(StringToBinary($sstring, $sb_utf8))
EndFunc

Func areoxaohpta($flmojocqtz, $fljzkjrgzs, $flsgxlqjno)
	Local $flfzxxyxzg[2]
	$flfzxxyxzg[0] = DllStructCreate("struct;uint bfSize;uint bfReserved;uint bfOffBits;uint biSize;int biWidth;int biHeight;ushort biPlanes;ushort biBitCount;uint biCompression;uint biSizeImage;int biXPelsPerMeter;int biYPelsPerMeter;uint biClrUsed;uint biClrImportant;endstruct;")
	DllStructSetData($flfzxxyxzg[0], "bfSize", (3 * $flmojocqtz + Mod($flmojocqtz, 4) * Abs($fljzkjrgzs)))
	DllStructSetData($flfzxxyxzg[0], "bfReserved", 0)
	DllStructSetData($flfzxxyxzg[0], "bfOffBits", 54)
	DllStructSetData($flfzxxyxzg[0], "biSize", 40)
	DllStructSetData($flfzxxyxzg[0], "biWidth", $flmojocqtz)
	DllStructSetData($flfzxxyxzg[0], "biHeight", $fljzkjrgzs)
	DllStructSetData($flfzxxyxzg[0], "biPlanes", 1)
	DllStructSetData($flfzxxyxzg[0], "biBitCount", 24)
	DllStructSetData($flfzxxyxzg[0], "biCompression", 0)
	DllStructSetData($flfzxxyxzg[0], "biSizeImage", 0)
	DllStructSetData($flfzxxyxzg[0], "biXPelsPerMeter", 0)
	DllStructSetData($flfzxxyxzg[0], "biYPelsPerMeter", 0)
	DllStructSetData($flfzxxyxzg[0], "biClrUsed", 0)
	DllStructSetData($flfzxxyxzg[0], "biClrImportant", 0)
	$flfzxxyxzg[1] = DllStructCreate("struct;" & _stringrepeat("byte[" & DllStructGetData($flfzxxyxzg[0], "biWidth") * 3 & "];", DllStructGetData($flfzxxyxzg[0], "biHeight")) & "endstruct")
	Return $flfzxxyxzg
EndFunc

Func arewuoknzvh($flyoojibbo, $fltyapmigo)
	Local $fldknagjpd = ""
	For $flezmzowno = 0 To Random($flyoojibbo, $fltyapmigo, 1)
		$fldknagjpd &= Chr(Random(97, 122, 1))
	Next
	Return $fldknagjpd
EndFunc

Func aregfmwbsqd($flslbknofv)
	Local $flxgrwiiel = arewuoknzvh(15, 20)
	Switch $flslbknofv
		Case 10 To 15
			$flxgrwiiel &= ".bmp"
			FileInstall(".\sprite.bmp", @ScriptDir & "\" & $flxgrwiiel)
		Case 25 To 30
			$flxgrwiiel &= ".dll"
			FileInstall(".\qr_encoder.dll", @ScriptDir & "\" & $flxgrwiiel)
	EndSwitch
	Return $flxgrwiiel
EndFunc

Func areuznaqfmn()
	Local $flfnvbvvfi = -1
	Local $flfnvbvvfiraw = DllStructCreate("struct;dword;char[1024];endstruct")
	DllStructSetData($flfnvbvvfiraw, 2, 1024)
	Local $flmyeulrox = DllCall("kernel32.dll", "int", "GetComputerNameA", "ptr", DllStructGetPtr($flfnvbvvfiraw, 2), "ptr", DllStructGetPtr($flfnvbvvfiraw, 1))
	If $flmyeulrox[0] <> 0 Then
		$flfnvbvvfi = BinaryMid(DllStructGetData($flfnvbvvfiraw, 2), 1, DllStructGetData($flfnvbvvfiraw, 1))
	EndIf
	Return $flfnvbvvfi
EndFunc

GUICreate("CodeIt Plus!", 300, 375, -1, -1)

Func aregtfdcyni(ByRef $flkqaovzec)
	Local $flqvizhezm = aregfmwbsqd(14)
	Local $flfwezdbyc = arerujpvsfp($flqvizhezm)
	If $flfwezdbyc <> -1 Then
		Local $flvburiuyd = arenwrbskll($flfwezdbyc)
		If $flvburiuyd <> -1 AND DllStructGetSize($flkqaovzec) < $flvburiuyd - 54 Then
			Local $flnfufvect = DllStructCreate("struct;byte[" & $flvburiuyd & "];endstruct")
			Local $flskuanqbg = aremlfozynu($flfwezdbyc, $flnfufvect)
			If $flskuanqbg <> -1 Then
				Local $flxmdchrqd = DllStructCreate("struct;byte[54];byte[" & $flvburiuyd - 54 & "];endstruct", DllStructGetPtr($flnfufvect))
				Local $flqgwnzjzc = 1
				Local $floctxpgqh = ""
				For $fltergxskh = 1 To DllStructGetSize($flkqaovzec)
					Local $flydtvgpnc = Number(DllStructGetData($flkqaovzec, 1, $fltergxskh))
					For $fltajbykxx = 6 To 0 Step -1
						$flydtvgpnc += BitShift(BitAND(Number(DllStructGetData($flxmdchrqd, 2, $flqgwnzjzc)), 1), -1 * $fltajbykxx)
						$flqgwnzjzc += 1
					Next
					$floctxpgqh &= Chr(BitShift($flydtvgpnc, 1) + BitShift(BitAND($flydtvgpnc, 1), -7))
				Next
				DllStructSetData($flkqaovzec, 1, $floctxpgqh)
			EndIf
		EndIf
		arevtgkxjhu($flfwezdbyc)
	EndIf
	arebbytwcoj($flqvizhezm)
EndFunc

Func areyzotafnf(ByRef $flodiutpuy)
	Local $flisilayln = areuznaqfmn()
	If $flisilayln <> -1 Then
		$flisilayln = Binary(StringLower(BinaryToString($flisilayln)))
		Local $flisilaylnraw = DllStructCreate("struct;byte[" & BinaryLen($flisilayln) & "];endstruct")
		DllStructSetData($flisilaylnraw, 1, $flisilayln)
		aregtfdcyni($flisilaylnraw)
		Local $flnttmjfea = DllStructCreate("struct;ptr;ptr;dword;byte[32];endstruct")
		DllStructSetData($flnttmjfea, 3, 32)
		Local $fluzytjacb = DllCall("advapi32.dll", "int", "CryptAcquireContextA", "ptr", DllStructGetPtr($flnttmjfea, 1), "ptr", 0, "ptr", 0, "dword", 24, "dword", 4026531840)
		If $fluzytjacb[0] <> 0 Then
			$fluzytjacb = DllCall("advapi32.dll", "int", "CryptCreateHash", "ptr", DllStructGetData($flnttmjfea, 1), "dword", 32780, "dword", 0, "dword", 0, "ptr", DllStructGetPtr($flnttmjfea, 2))
			If $fluzytjacb[0] <> 0 Then
				$fluzytjacb = DllCall("advapi32.dll", "int", "CryptHashData", "ptr", DllStructGetData($flnttmjfea, 2), "struct*", $flisilaylnraw, "dword", DllStructGetSize($flisilaylnraw), "dword", 0)
				If $fluzytjacb[0] <> 0 Then
					$fluzytjacb = DllCall("advapi32.dll", "int", "CryptGetHashParam", "ptr", DllStructGetData($flnttmjfea, 2), "dword", 2, "ptr", DllStructGetPtr($flnttmjfea, 4), "ptr", DllStructGetPtr($flnttmjfea, 3), "dword", 0)
					If $fluzytjacb[0] <> 0 Then
						Local $flmtvyzrsy = Binary("0x" & "08020" & "00010" & "66000" & "02000" & "0000") & DllStructGetData($flnttmjfea, 4)
						Local $flkpzlqkch = Binary("0x" & "CD4B3" & "2C650" & "CF21B" & "DA184" & "D8913" & "E6F92" & "0A37A" & "4F396" & "3736C" & "042C4" & "59EA0" & "7B79E" & "A443F" & "FD189" & "8BAE4" & "9B115" & "F6CB1" & "E2A7C" & "1AB3C" & "4C256" & "12A51" & "9035F" & "18FB3" & "B1752" & "8B3AE" & "CAF3D" & "480E9" & "8BF8A" & "635DA" & "F974E" & "00135" & "35D23" & "1E4B7" & "5B2C3" & "8B804" & "C7AE4" & "D266A" & "37B36" & "F2C55" & "5BF3A" & "9EA6A" & "58BC8" & "F906C" & "C665E" & "AE2CE" & "60F2C" & "DE38F" & "D3026" & "9CC4C" & "E5BB0" & "90472" & "FF9BD" & "26F91" & "19B8C" & "484FE" & "69EB9" & "34F43" & "FEEDE" & "DCEBA" & "79146" & "0819F" & "B21F1" & "0F832" & "B2A5D" & "4D772" & "DB12C" & "3BED9" & "47F6F" & "706AE" & "4411A" & "52")
						Local $fluelrpeax = DllStructCreate("struct;ptr;ptr;dword;byte[8192];byte[" & BinaryLen($flmtvyzrsy) & "];dword;endstruct")
						DllStructSetData($fluelrpeax, 3, BinaryLen($flkpzlqkch))
						DllStructSetData($fluelrpeax, 4, $flkpzlqkch)
						DllStructSetData($fluelrpeax, 5, $flmtvyzrsy)
						DllStructSetData($fluelrpeax, 6, BinaryLen($flmtvyzrsy))
						Local $fluzytjacb = DllCall("advapi32.dll", "int", "CryptAcquireContextA", "ptr", DllStructGetPtr($fluelrpeax, 1), "ptr", 0, "ptr", 0, "dword", 24, "dword", 4026531840)
						If $fluzytjacb[0] <> 0 Then
							$fluzytjacb = DllCall("advapi32.dll", "int", "CryptImportKey", "ptr", DllStructGetData($fluelrpeax, 1), "ptr", DllStructGetPtr($fluelrpeax, 5), "dword", DllStructGetData($fluelrpeax, 6), "dword", 0, "dword", 0, "ptr", DllStructGetPtr($fluelrpeax, 2))
							If $fluzytjacb[0] <> 0 Then
								$fluzytjacb = DllCall("advapi32.dll", "int", "CryptDecrypt", "ptr", DllStructGetData($fluelrpeax, 2), "dword", 0, "dword", 1, "dword", 0, "ptr", DllStructGetPtr($fluelrpeax, 4), "ptr", DllStructGetPtr($fluelrpeax, 3))
								If $fluzytjacb[0] <> 0 Then
									Local $flsekbkmru = BinaryMid(DllStructGetData($fluelrpeax, 4), 1, DllStructGetData($fluelrpeax, 3))
									$flfzfsuaoz = Binary("FLARE")
									$fltvwqdotg = Binary("ERALF")
									$flgggftges = BinaryMid($flsekbkmru, 1, BinaryLen($flfzfsuaoz))
									$flnmiatrft = BinaryMid($flsekbkmru, BinaryLen($flsekbkmru) - BinaryLen($fltvwqdotg) + 1, BinaryLen($fltvwqdotg))
									If $flfzfsuaoz = $flgggftges AND $fltvwqdotg = $flnmiatrft Then
										DllStructSetData($flodiutpuy, 1, BinaryMid($flsekbkmru, 6, 4))
										DllStructSetData($flodiutpuy, 2, BinaryMid($flsekbkmru, 10, 4))
										DllStructSetData($flodiutpuy, 3, BinaryMid($flsekbkmru, 14, BinaryLen($flsekbkmru) - 18))
									EndIf
								EndIf
								DllCall("advapi32.dll", "int", "CryptDestroyKey", "ptr", DllStructGetData($fluelrpeax, 2))
							EndIf
							DllCall("advapi32.dll", "int", "CryptReleaseContext", "ptr", DllStructGetData($fluelrpeax, 1), "dword", 0)
						EndIf
					EndIf
				EndIf
				DllCall("advapi32.dll", "int", "CryptDestroyHash", "ptr", DllStructGetData($flnttmjfea, 2))
			EndIf
			DllCall("advapi32.dll", "int", "CryptReleaseContext", "ptr", DllStructGetData($flnttmjfea, 1), "dword", 0)
		EndIf
	EndIf
EndFunc

Func areaqwbmtiz(ByRef $flkhfbuyon)
	Local $fluupfrkdz = -1
	Local $flqbsfzezk = DllStructCreate("struct;ptr;ptr;dword;byte[16];endstruct")
	DllStructSetData($flqbsfzezk, 3, 16)
	Local $fltrtsuryd = DllCall("advapi32.dll", "int", "CryptAcquireContextA", "ptr", DllStructGetPtr($flqbsfzezk, 1), "ptr", 0, "ptr", 0, "dword", 24, "dword", 4026531840)
	If $fltrtsuryd[0] <> 0 Then
		$fltrtsuryd = DllCall("advapi32.dll", "int", "CryptCreateHash", "ptr", DllStructGetData($flqbsfzezk, 1), "dword", 32771, "dword", 0, "dword", 0, "ptr", DllStructGetPtr($flqbsfzezk, 2))
		If $fltrtsuryd[0] <> 0 Then
			$fltrtsuryd = DllCall("advapi32.dll", "int", "CryptHashData", "ptr", DllStructGetData($flqbsfzezk, 2), "struct*", $flkhfbuyon, "dword", DllStructGetSize($flkhfbuyon), "dword", 0)
			If $fltrtsuryd[0] <> 0 Then
				$fltrtsuryd = DllCall("advapi32.dll", "int", "CryptGetHashParam", "ptr", DllStructGetData($flqbsfzezk, 2), "dword", 2, "ptr", DllStructGetPtr($flqbsfzezk, 4), "ptr", DllStructGetPtr($flqbsfzezk, 3), "dword", 0)
				If $fltrtsuryd[0] <> 0 Then
					$fluupfrkdz = DllStructGetData($flqbsfzezk, 4)
				EndIf
			EndIf
			DllCall("advapi32.dll", "int", "CryptDestroyHash", "ptr", DllStructGetData($flqbsfzezk, 2))
		EndIf
		DllCall("advapi32.dll", "int", "CryptReleaseContext", "ptr", DllStructGetData($flqbsfzezk, 1), "dword", 0)
	EndIf
	Return $fluupfrkdz
EndFunc

Func arepfnkwypw()
	Local $flgqbtjbmi = -1
	Local $fltpvjccvq = DllStructCreate("struct;dword;dword;dword;dword;dword;byte[128];endstruct")
	DllStructSetData($fltpvjccvq, 1, DllStructGetSize($fltpvjccvq))
	Local $flaghdvgyv = DllCall("kernel32.dll", "int", "GetVersionExA", "struct*", $fltpvjccvq)
	If $flaghdvgyv[0] <> 0 Then
		If DllStructGetData($fltpvjccvq, 2) = 6 Then
			If DllStructGetData($fltpvjccvq, 3) = 1 Then
				$flgqbtjbmi = 0
			EndIf
		EndIf
	EndIf
	Return $flgqbtjbmi
EndFunc

Func areialbhuyt()
	Local $flokwzamxw = GUICtrlCreateInput("Enter text to encode", -1, 5, 300)
	Local $flkhwwzgne = GUICtrlCreateButton("Can haz code?", -1, 30, 300)
	Local $fluhtsijxf = GUICtrlCreatePic("", -1, 55, 300, 300)
	Local $flxeuaihlc = GUICtrlCreateMenu("Help")
	Local $flxeuaihlcitem = GUICtrlCreateMenuItem("About CodeIt Plus!", $flxeuaihlc)
	Local $flpnltlqhh = aregfmwbsqd(13)
	GUICtrlSetImage($fluhtsijxf, $flpnltlqhh)
	arebbytwcoj($flpnltlqhh)
	GUISetState(@SW_SHOW)
	While 1
		Switch GUIGetMsg()
			Case $flkhwwzgne
				Local $flnwbvjljj = GUICtrlRead($flokwzamxw)
				If $flnwbvjljj Then
					Local $flwxdpsimz = aregfmwbsqd(26)
					Local $flnpapeken = DllStructCreate("struct;dword;dword;byte[3918];endstruct")
					Local $fljfojrihf = DllCall($flwxdpsimz, "int:cdecl", "justGenerateQRSymbol", "struct*", $flnpapeken, "str", $flnwbvjljj)
					If $fljfojrihf[0] <> 0 Then
						areyzotafnf($flnpapeken)
						Local $flbvokdxkg = areoxaohpta((DllStructGetData($flnpapeken, 1) * DllStructGetData($flnpapeken, 2)), (DllStructGetData($flnpapeken, 1) * DllStructGetData($flnpapeken, 2)), 1024)
						$fljfojrihf = DllCall($flwxdpsimz, "int:cdecl", "justConvertQRSymbolToBitmapPixels", "struct*", $flnpapeken, "struct*", $flbvokdxkg[1])
						If $fljfojrihf[0] <> 0 Then
							$flpnltlqhh = arewuoknzvh(25, 30) & ".bmp"
							arelassehha($flbvokdxkg, $flpnltlqhh)
						EndIf
					EndIf
					arebbytwcoj($flwxdpsimz)
				Else
					$flpnltlqhh = aregfmwbsqd(11)
				EndIf
				GUICtrlSetImage($fluhtsijxf, $flpnltlqhh)
				arebbytwcoj($flpnltlqhh)
			Case $flxeuaihlcitem
				Local $flomtrkawp = "This program generates QR codes using QR Code Generator (https://www.nayuki.io/page/qr-code-generator-library) developed by Nayuki. "
				$flomtrkawp &= "QR Code Generator is available on GitHub (https://github.com/nayuki/QR-Code-generator) and open-sourced under the following permissive MIT License (https://github.com/nayuki/QR-Code-generator#license):"
				$flomtrkawp &= @CRLF
				$flomtrkawp &= @CRLF
				$flomtrkawp &= "Copyright © 2020 Project Nayuki. (MIT License)"
				$flomtrkawp &= @CRLF
				$flomtrkawp &= "https://www.nayuki.io/page/qr-code-generator-library"
				$flomtrkawp &= @CRLF
				$flomtrkawp &= @CRLF
				$flomtrkawp &= "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the Software), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:"
				$flomtrkawp &= @CRLF
				$flomtrkawp &= @CRLF
				$flomtrkawp &= "1. The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software."
				$flomtrkawp &= @CRLF
				$flomtrkawp &= "2. The Software is provided as is, without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. In no event shall the authors or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the Software or the use or other dealings in the Software."
				MsgBox(4096, "About CodeIt Plus!", $flomtrkawp)
			Case -3
				ExitLoop
		EndSwitch
	WEnd
EndFunc

Func arepqqkaeto($flmwacufre, $fljxaivjld)
	Local $fljiyeluhx = -1
	Local $flmwacufreheadermagic = DllStructCreate("struct;ushort;endstruct")
	DllStructSetData($flmwacufreheadermagic, 1, 19778)
	Local $flivpiogmf = aremyfdtfqp($fljxaivjld, False)
	If $flivpiogmf <> -1 Then
		Local $flchlkbend = aremfkxlayv($flivpiogmf, DllStructGetPtr($flmwacufreheadermagic), DllStructGetSize($flmwacufreheadermagic))
		If $flchlkbend <> -1 Then
			$flchlkbend = aremfkxlayv($flivpiogmf, DllStructGetPtr($flmwacufre[0]), DllStructGetSize($flmwacufre[0]))
			If $flchlkbend <> -1 Then
				$fljiyeluhx = 0
			EndIf
		EndIf
		arevtgkxjhu($flivpiogmf)
	EndIf
	Return $fljiyeluhx
EndFunc

areialbhuyt()

Func arelassehha($flbaqvujsl, $flkelsuuiy)
	Local $flefoubdxt = -1
	Local $flamtlcncx = arepqqkaeto($flbaqvujsl, $flkelsuuiy)
	If $flamtlcncx <> -1 Then
		Local $flvikmhxwu = aremyfdtfqp($flkelsuuiy, True)
		If $flvikmhxwu <> -1 Then
			Local $flwldjlwrq = Abs(DllStructGetData($flbaqvujsl[0], "biHeight"))
			Local $flumnoetuu = DllStructGetData($flbaqvujsl[0], "biHeight") > 0 ? $flwldjlwrq - 1 : 0
			Local $flqphcjgtp = DllStructCreate("struct;byte;byte;byte;endstruct")
			For $fllrcvawmx = 0 To $flwldjlwrq - 1
				$flamtlcncx = aremfkxlayv($flvikmhxwu, DllStructGetPtr($flbaqvujsl[1], Abs($flumnoetuu - $fllrcvawmx) + 1), DllStructGetData($flbaqvujsl[0], "biWidth") * 3)
				If $flamtlcncx = -1 Then ExitLoop
				$flamtlcncx = aremfkxlayv($flvikmhxwu, DllStructGetPtr($flqphcjgtp), Mod(DllStructGetData($flbaqvujsl[0], "biWidth"), 4))
				If $flamtlcncx = -1 Then ExitLoop
			Next
			If $flamtlcncx <> -1 Then
				$flefoubdxt = 0
			EndIf
			arevtgkxjhu($flvikmhxwu)
		EndIf
	EndIf
	Return $flefoubdxt
EndFunc

Func arerujpvsfp($flrriteuxd)
	Local $flrichemye = DllCall("kernel32.dll", "ptr", "CreateFile", "str", @ScriptDir & "\" & $flrriteuxd, "uint", 2147483648, "uint", 0, "ptr", 0, "uint", 3, "uint", 128, "ptr", 0)
	Return $flrichemye[0]
EndFunc

Func aremyfdtfqp($flzxepiook, $flzcodzoep = True)
	Local $flogmfcakq = DllCall("kernel32.dll", "ptr", "CreateFile", "str", @ScriptDir & "\" & $flzxepiook, "uint", 1073741824, "uint", 0, "ptr", 0, "uint", $flzcodzoep ? 3 : 2, "uint", 128, "ptr", 0)
	Return $flogmfcakq[0]
EndFunc

GUIDelete()

Func aremfkxlayv($fllsczdyhr, $flbfzgxbcy, $flutgabjfj)
	If $fllsczdyhr <> -1 Then
		Local $flvfnkosuf = DllCall("kernel32.dll", "uint", "SetFilePointer", "ptr", $fllsczdyhr, "long", 0, "ptr", 0, "uint", 2)
		If $flvfnkosuf[0] <> -1 Then
			Local $flwzfbbkto = DllStructCreate("uint")
			$flvfnkosuf = DllCall("kernel32.dll", "ptr", "WriteFile", "ptr", $fllsczdyhr, "ptr", $flbfzgxbcy, "uint", $flutgabjfj, "ptr", DllStructGetPtr($flwzfbbkto), "ptr", 0)
			If $flvfnkosuf[0] <> 0 AND DllStructGetData($flwzfbbkto, 1) = $flutgabjfj Then
				Return 0
			EndIf
		EndIf
	EndIf
	Return -1
EndFunc

Func aremlfozynu($flfdnkxwze, ByRef $flgfdykdor)
	Local $flqcvtzthz = DllStructCreate("struct;dword;endstruct")
	Local $flqnsbzfsf = DllCall("kernel32.dll", "int", "ReadFile", "ptr", $flfdnkxwze, "struct*", $flgfdykdor, "dword", DllStructGetSize($flgfdykdor), "struct*", $flqcvtzthz, "ptr", 0)
	Return $flqnsbzfsf[0]
EndFunc

Func arevtgkxjhu($fldiapcptm)
	Local $flhvhgvtxm = DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $fldiapcptm)
	Return $flhvhgvtxm[0]
EndFunc

Func arebbytwcoj($flxljyoycl)
	Local $flaubrmoip = DllCall("kernel32.dll", "int", "DeleteFileA", "str", $flxljyoycl)
	Return $flaubrmoip[0]
EndFunc

Func arenwrbskll($flpxhqhcav)
	Local $flzmcdhzwh = -1
	Local $flztpegdeg = DllStructCreate("struct;dword;endstruct")
	Local $flekmcmpdl = DllCall("kernel32.dll", "dword", "GetFileSize", "ptr", $flpxhqhcav, "struct*", $flztpegdeg)
	If $flekmcmpdl <> -1 Then
		$flzmcdhzwh = $flekmcmpdl[0] + Number(DllStructGetData($flztpegdeg, 1))
	EndIf
	Return $flzmcdhzwh
EndFunc

