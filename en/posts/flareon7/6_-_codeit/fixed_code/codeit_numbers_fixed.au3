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

#OnAutoItStartRegister "AREIHNVAPWN"
Global $os

Func areoxaohpta($flmojocqtz, $fljzkjrgzs, $flsgxlqjno)
	Local $flfzxxyxzg[2]
	$flfzxxyxzg[0] = DllStructCreate(arehdidxrgk($os[1]))
	DllStructSetData($flfzxxyxzg[0], arehdidxrgk($os[2]), (3 * $flmojocqtz + Mod($flmojocqtz, 4) * Abs($fljzkjrgzs)))
	DllStructSetData($flfzxxyxzg[0], arehdidxrgk($os[3]), 0)
	DllStructSetData($flfzxxyxzg[0], arehdidxrgk($os[4]), 54)
	DllStructSetData($flfzxxyxzg[0], arehdidxrgk($os[5]), 40)
	DllStructSetData($flfzxxyxzg[0], arehdidxrgk($os[6]), $flmojocqtz)
	DllStructSetData($flfzxxyxzg[0], arehdidxrgk($os[7]), $fljzkjrgzs)
	DllStructSetData($flfzxxyxzg[0], arehdidxrgk($os[8]), 1)
	DllStructSetData($flfzxxyxzg[0], arehdidxrgk($os[9]), 24)
	DllStructSetData($flfzxxyxzg[0], arehdidxrgk($os[10]), 0)
	DllStructSetData($flfzxxyxzg[0], arehdidxrgk($os[11]), 0)
	DllStructSetData($flfzxxyxzg[0], arehdidxrgk($os[12]), 0)
	DllStructSetData($flfzxxyxzg[0], arehdidxrgk($os[13]), 0)
	DllStructSetData($flfzxxyxzg[0], arehdidxrgk($os[14]), 0)
	DllStructSetData($flfzxxyxzg[0], arehdidxrgk($os[15]), 0)
	$flfzxxyxzg[1] = DllStructCreate(arehdidxrgk($os[16]) & _stringrepeat(arehdidxrgk($os[17]) & DllStructGetData($flfzxxyxzg[0], arehdidxrgk($os[6])) * 3 & arehdidxrgk($os[18]), DllStructGetData($flfzxxyxzg[0], arehdidxrgk($os[7]))) & arehdidxrgk($os[19]))
	Return $flfzxxyxzg
EndFunc

Func arewuoknzvh($flyoojibbo, $fltyapmigo)
	Local $fldknagjpd = arehdidxrgk($os[20])
	For $flezmzowno = 0 To Random($flyoojibbo, $fltyapmigo, 1)
		$fldknagjpd &= Chr(Random(97, 122, 1))
	Next
	Return $fldknagjpd
EndFunc

Func aregfmwbsqd($flslbknofv)
	Local $flxgrwiiel = arewuoknzvh(15, 20)
	Switch $flslbknofv
		Case 10 To 15
			$flxgrwiiel &= arehdidxrgk($os[21])
			FileInstall(".\sprite.bmp", @ScriptDir & arehdidxrgk($os[22]) & $flxgrwiiel)
		Case 25 To 30
			$flxgrwiiel &= arehdidxrgk($os[23])
			FileInstall(".\qr_encoder.dll", @ScriptDir & arehdidxrgk($os[22]) & $flxgrwiiel)
	EndSwitch
	Return $flxgrwiiel
EndFunc

Func areuznaqfmn()
	Local $flfnvbvvfi = -1
	Local $flfnvbvvfiraw = DllStructCreate(arehdidxrgk($os[24]))
	DllStructSetData($flfnvbvvfiraw, 2, 1024)
	Local $flmyeulrox = DllCall(arehdidxrgk($os[25]), arehdidxrgk($os[26]), arehdidxrgk($os[27]), arehdidxrgk($os[28]), DllStructGetPtr($flfnvbvvfiraw, 2), arehdidxrgk($os[28]), DllStructGetPtr($flfnvbvvfiraw, 1))
	If $flmyeulrox[0] <> 0 Then
		$flfnvbvvfi = BinaryMid(DllStructGetData($flfnvbvvfiraw, 2), 1, DllStructGetData($flfnvbvvfiraw, 1))
	EndIf
	Return $flfnvbvvfi
EndFunc

GUICreate(arehdidxrgk($os[29]), 300, 375, -1, -1)

Func aregtfdcyni(ByRef $flkqaovzec)
	Local $flqvizhezm = aregfmwbsqd(14)
	Local $flfwezdbyc = arerujpvsfp($flqvizhezm)
	If $flfwezdbyc <> -1 Then
		Local $flvburiuyd = arenwrbskll($flfwezdbyc)
		If $flvburiuyd <> -1 AND DllStructGetSize($flkqaovzec) < $flvburiuyd - 54 Then
			Local $flnfufvect = DllStructCreate(arehdidxrgk($os[30]) & $flvburiuyd & arehdidxrgk($os[31]))
			Local $flskuanqbg = aremlfozynu($flfwezdbyc, $flnfufvect)
			If $flskuanqbg <> -1 Then
				Local $flxmdchrqd = DllStructCreate(arehdidxrgk($os[32]) & $flvburiuyd - 54 & arehdidxrgk($os[31]), DllStructGetPtr($flnfufvect))
				Local $flqgwnzjzc = 1
				Local $floctxpgqh = arehdidxrgk($os[20])
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
		Local $flisilaylnraw = DllStructCreate(arehdidxrgk($os[30]) & BinaryLen($flisilayln) & arehdidxrgk($os[31]))
		DllStructSetData($flisilaylnraw, 1, $flisilayln)
		aregtfdcyni($flisilaylnraw)
		Local $flnttmjfea = DllStructCreate(arehdidxrgk($os[33]))
		DllStructSetData($flnttmjfea, 3, 32)
		Local $fluzytjacb = DllCall(arehdidxrgk($os[34]), arehdidxrgk($os[26]), arehdidxrgk($os[35]), arehdidxrgk($os[28]), DllStructGetPtr($flnttmjfea, 1), arehdidxrgk($os[28]), 0, arehdidxrgk($os[28]), 0, arehdidxrgk($os[36]), 24, arehdidxrgk($os[36]), 4026531840)
		If $fluzytjacb[0] <> 0 Then
			$fluzytjacb = DllCall(arehdidxrgk($os[34]), arehdidxrgk($os[26]), arehdidxrgk($os[37]), arehdidxrgk($os[28]), DllStructGetData($flnttmjfea, 1), arehdidxrgk($os[36]), 32780, arehdidxrgk($os[36]), 0, arehdidxrgk($os[36]), 0, arehdidxrgk($os[28]), DllStructGetPtr($flnttmjfea, 2))
			If $fluzytjacb[0] <> 0 Then
				$fluzytjacb = DllCall(arehdidxrgk($os[34]), arehdidxrgk($os[26]), arehdidxrgk($os[38]), arehdidxrgk($os[28]), DllStructGetData($flnttmjfea, 2), arehdidxrgk($os[39]), $flisilaylnraw, arehdidxrgk($os[36]), DllStructGetSize($flisilaylnraw), arehdidxrgk($os[36]), 0)
				If $fluzytjacb[0] <> 0 Then
					$fluzytjacb = DllCall(arehdidxrgk($os[34]), arehdidxrgk($os[26]), arehdidxrgk($os[40]), arehdidxrgk($os[28]), DllStructGetData($flnttmjfea, 2), arehdidxrgk($os[36]), 2, arehdidxrgk($os[28]), DllStructGetPtr($flnttmjfea, 4), arehdidxrgk($os[28]), DllStructGetPtr($flnttmjfea, 3), arehdidxrgk($os[36]), 0)
					If $fluzytjacb[0] <> 0 Then
						Local $flmtvyzrsy = Binary(arehdidxrgk($os[41]) & arehdidxrgk($os[42]) & arehdidxrgk($os[43]) & arehdidxrgk($os[44]) & arehdidxrgk($os[45]) & arehdidxrgk($os[46])) & DllStructGetData($flnttmjfea, 4)
						Local $flkpzlqkch = Binary(arehdidxrgk($os[41]) & arehdidxrgk($os[47]) & arehdidxrgk($os[48]) & arehdidxrgk($os[49]) & arehdidxrgk($os[50]) & arehdidxrgk($os[51]) & arehdidxrgk($os[52]) & arehdidxrgk($os[53]) & arehdidxrgk($os[54]) & arehdidxrgk($os[55]) & arehdidxrgk($os[56]) & arehdidxrgk($os[57]) & arehdidxrgk($os[58]) & arehdidxrgk($os[59]) & arehdidxrgk($os[60]) & arehdidxrgk($os[61]) & arehdidxrgk($os[62]) & arehdidxrgk($os[63]) & arehdidxrgk($os[64]) & arehdidxrgk($os[65]) & arehdidxrgk($os[66]) & arehdidxrgk($os[67]) & arehdidxrgk($os[68]) & arehdidxrgk($os[69]) & arehdidxrgk($os[70]) & arehdidxrgk($os[71]) & arehdidxrgk($os[72]) & arehdidxrgk($os[73]) & arehdidxrgk($os[74]) & arehdidxrgk($os[75]) & arehdidxrgk($os[76]) & arehdidxrgk($os[77]) & arehdidxrgk($os[78]) & arehdidxrgk($os[79]) & arehdidxrgk($os[80]) & arehdidxrgk($os[81]) & arehdidxrgk($os[82]) & arehdidxrgk($os[83]) & arehdidxrgk($os[84]) & arehdidxrgk($os[85]) & arehdidxrgk($os[86]) & arehdidxrgk($os[87]) & arehdidxrgk($os[88]) & arehdidxrgk($os[89]) & arehdidxrgk($os[90]) & arehdidxrgk($os[91]) & arehdidxrgk($os[92]) & arehdidxrgk($os[93]) & arehdidxrgk($os[94]) & arehdidxrgk($os[95]) & arehdidxrgk($os[96]) & arehdidxrgk($os[97]) & arehdidxrgk($os[98]) & arehdidxrgk($os[99]) & arehdidxrgk($os[100]) & arehdidxrgk($os[101]) & arehdidxrgk($os[102]) & arehdidxrgk($os[103]) & arehdidxrgk($os[104]) & arehdidxrgk($os[105]) & arehdidxrgk($os[106]) & arehdidxrgk($os[107]) & arehdidxrgk($os[108]) & arehdidxrgk($os[109]) & arehdidxrgk($os[110]) & arehdidxrgk($os[111]) & arehdidxrgk($os[112]) & arehdidxrgk($os[113]) & arehdidxrgk($os[114]) & arehdidxrgk($os[115]) & arehdidxrgk($os[116]) & arehdidxrgk($os[117]))
						Local $fluelrpeax = DllStructCreate(arehdidxrgk($os[118]) & BinaryLen($flmtvyzrsy) & arehdidxrgk($os[119]))
						DllStructSetData($fluelrpeax, 3, BinaryLen($flkpzlqkch))
						DllStructSetData($fluelrpeax, 4, $flkpzlqkch)
						DllStructSetData($fluelrpeax, 5, $flmtvyzrsy)
						DllStructSetData($fluelrpeax, 6, BinaryLen($flmtvyzrsy))
						Local $fluzytjacb = DllCall(arehdidxrgk($os[34]), arehdidxrgk($os[26]), arehdidxrgk($os[35]), arehdidxrgk($os[28]), DllStructGetPtr($fluelrpeax, 1), arehdidxrgk($os[28]), 0, arehdidxrgk($os[28]), 0, arehdidxrgk($os[36]), 24, arehdidxrgk($os[36]), 4026531840)
						If $fluzytjacb[0] <> 0 Then
							$fluzytjacb = DllCall(arehdidxrgk($os[34]), arehdidxrgk($os[26]), arehdidxrgk($os[120]), arehdidxrgk($os[28]), DllStructGetData($fluelrpeax, 1), arehdidxrgk($os[28]), DllStructGetPtr($fluelrpeax, 5), arehdidxrgk($os[36]), DllStructGetData($fluelrpeax, 6), arehdidxrgk($os[36]), 0, arehdidxrgk($os[36]), 0, arehdidxrgk($os[28]), DllStructGetPtr($fluelrpeax, 2))
							If $fluzytjacb[0] <> 0 Then
								$fluzytjacb = DllCall(arehdidxrgk($os[34]), arehdidxrgk($os[26]), arehdidxrgk($os[121]), arehdidxrgk($os[28]), DllStructGetData($fluelrpeax, 2), arehdidxrgk($os[36]), 0, arehdidxrgk($os[36]), 1, arehdidxrgk($os[36]), 0, arehdidxrgk($os[28]), DllStructGetPtr($fluelrpeax, 4), arehdidxrgk($os[28]), DllStructGetPtr($fluelrpeax, 3))
								If $fluzytjacb[0] <> 0 Then
									Local $flsekbkmru = BinaryMid(DllStructGetData($fluelrpeax, 4), 1, DllStructGetData($fluelrpeax, 3))
									$flfzfsuaoz = Binary(arehdidxrgk($os[122]))
									$fltvwqdotg = Binary(arehdidxrgk($os[123]))
									$flgggftges = BinaryMid($flsekbkmru, 1, BinaryLen($flfzfsuaoz))
									$flnmiatrft = BinaryMid($flsekbkmru, BinaryLen($flsekbkmru) - BinaryLen($fltvwqdotg) + 1, BinaryLen($fltvwqdotg))
									If $flfzfsuaoz = $flgggftges AND $fltvwqdotg = $flnmiatrft Then
										DllStructSetData($flodiutpuy, 1, BinaryMid($flsekbkmru, 6, 4))
										DllStructSetData($flodiutpuy, 2, BinaryMid($flsekbkmru, 10, 4))
										DllStructSetData($flodiutpuy, 3, BinaryMid($flsekbkmru, 14, BinaryLen($flsekbkmru) - 18))
									EndIf
								EndIf
								DllCall(arehdidxrgk($os[34]), arehdidxrgk($os[26]), arehdidxrgk($os[124]), arehdidxrgk($os[28]), DllStructGetData($fluelrpeax, 2))
							EndIf
							DllCall(arehdidxrgk($os[34]), arehdidxrgk($os[26]), arehdidxrgk($os[125]), arehdidxrgk($os[28]), DllStructGetData($fluelrpeax, 1), arehdidxrgk($os[36]), 0)
						EndIf
					EndIf
				EndIf
				DllCall(arehdidxrgk($os[34]), arehdidxrgk($os[26]), arehdidxrgk($os[126]), arehdidxrgk($os[28]), DllStructGetData($flnttmjfea, 2))
			EndIf
			DllCall(arehdidxrgk($os[34]), arehdidxrgk($os[26]), arehdidxrgk($os[125]), arehdidxrgk($os[28]), DllStructGetData($flnttmjfea, 1), arehdidxrgk($os[36]), 0)
		EndIf
	EndIf
EndFunc

Func areaqwbmtiz(ByRef $flkhfbuyon)
	Local $fluupfrkdz = -1
	Local $flqbsfzezk = DllStructCreate(arehdidxrgk($os[127]))
	DllStructSetData($flqbsfzezk, 3, 16)
	Local $fltrtsuryd = DllCall(arehdidxrgk($os[34]), arehdidxrgk($os[26]), arehdidxrgk($os[35]), arehdidxrgk($os[28]), DllStructGetPtr($flqbsfzezk, 1), arehdidxrgk($os[28]), 0, arehdidxrgk($os[28]), 0, arehdidxrgk($os[36]), 24, arehdidxrgk($os[36]), 4026531840)
	If $fltrtsuryd[0] <> 0 Then
		$fltrtsuryd = DllCall(arehdidxrgk($os[34]), arehdidxrgk($os[26]), arehdidxrgk($os[37]), arehdidxrgk($os[28]), DllStructGetData($flqbsfzezk, 1), arehdidxrgk($os[36]), 32771, arehdidxrgk($os[36]), 0, arehdidxrgk($os[36]), 0, arehdidxrgk($os[28]), DllStructGetPtr($flqbsfzezk, 2))
		If $fltrtsuryd[0] <> 0 Then
			$fltrtsuryd = DllCall(arehdidxrgk($os[34]), arehdidxrgk($os[26]), arehdidxrgk($os[38]), arehdidxrgk($os[28]), DllStructGetData($flqbsfzezk, 2), arehdidxrgk($os[39]), $flkhfbuyon, arehdidxrgk($os[36]), DllStructGetSize($flkhfbuyon), arehdidxrgk($os[36]), 0)
			If $fltrtsuryd[0] <> 0 Then
				$fltrtsuryd = DllCall(arehdidxrgk($os[34]), arehdidxrgk($os[26]), arehdidxrgk($os[40]), arehdidxrgk($os[28]), DllStructGetData($flqbsfzezk, 2), arehdidxrgk($os[36]), 2, arehdidxrgk($os[28]), DllStructGetPtr($flqbsfzezk, 4), arehdidxrgk($os[28]), DllStructGetPtr($flqbsfzezk, 3), arehdidxrgk($os[36]), 0)
				If $fltrtsuryd[0] <> 0 Then
					$fluupfrkdz = DllStructGetData($flqbsfzezk, 4)
				EndIf
			EndIf
			DllCall(arehdidxrgk($os[34]), arehdidxrgk($os[26]), arehdidxrgk($os[126]), arehdidxrgk($os[28]), DllStructGetData($flqbsfzezk, 2))
		EndIf
		DllCall(arehdidxrgk($os[34]), arehdidxrgk($os[26]), arehdidxrgk($os[125]), arehdidxrgk($os[28]), DllStructGetData($flqbsfzezk, 1), arehdidxrgk($os[36]), 0)
	EndIf
	Return $fluupfrkdz
EndFunc

Func arepfnkwypw()
	Local $flgqbtjbmi = -1
	Local $fltpvjccvq = DllStructCreate(arehdidxrgk($os[128]))
	DllStructSetData($fltpvjccvq, 1, DllStructGetSize($fltpvjccvq))
	Local $flaghdvgyv = DllCall(arehdidxrgk($os[25]), arehdidxrgk($os[26]), arehdidxrgk($os[129]), arehdidxrgk($os[39]), $fltpvjccvq)
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
	Local $flokwzamxw = GUICtrlCreateInput(arehdidxrgk($os[130]), -1, 5, 300)
	Local $flkhwwzgne = GUICtrlCreateButton(arehdidxrgk($os[131]), -1, 30, 300)
	Local $fluhtsijxf = GUICtrlCreatePic(arehdidxrgk($os[132]), -1, 55, 300, 300)
	Local $flxeuaihlc = GUICtrlCreateMenu(arehdidxrgk($os[133]))
	Local $flxeuaihlcitem = GUICtrlCreateMenuItem(arehdidxrgk($os[134]), $flxeuaihlc)
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
					Local $flnpapeken = DllStructCreate(arehdidxrgk($os[135]))
					Local $fljfojrihf = DllCall($flwxdpsimz, arehdidxrgk($os[136]), arehdidxrgk($os[137]), arehdidxrgk($os[39]), $flnpapeken, arehdidxrgk($os[138]), $flnwbvjljj)
					If $fljfojrihf[0] <> 0 Then
						areyzotafnf($flnpapeken)
						Local $flbvokdxkg = areoxaohpta((DllStructGetData($flnpapeken, 1) * DllStructGetData($flnpapeken, 2)), (DllStructGetData($flnpapeken, 1) * DllStructGetData($flnpapeken, 2)), 1024)
						$fljfojrihf = DllCall($flwxdpsimz, arehdidxrgk($os[136]), arehdidxrgk($os[139]), arehdidxrgk($os[39]), $flnpapeken, arehdidxrgk($os[39]), $flbvokdxkg[1])
						If $fljfojrihf[0] <> 0 Then
							$flpnltlqhh = arewuoknzvh(25, 30) & arehdidxrgk($os[21])
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
				Local $flomtrkawp = arehdidxrgk($os[140])
				$flomtrkawp &= arehdidxrgk($os[141])
				$flomtrkawp &= @CRLF
				$flomtrkawp &= @CRLF
				$flomtrkawp &= arehdidxrgk($os[142])
				$flomtrkawp &= @CRLF
				$flomtrkawp &= arehdidxrgk($os[143])
				$flomtrkawp &= @CRLF
				$flomtrkawp &= @CRLF
				$flomtrkawp &= arehdidxrgk($os[144])
				$flomtrkawp &= @CRLF
				$flomtrkawp &= @CRLF
				$flomtrkawp &= arehdidxrgk($os[145])
				$flomtrkawp &= @CRLF
				$flomtrkawp &= arehdidxrgk($os[146])
				MsgBox(4096, arehdidxrgk($os[134]), $flomtrkawp)
			Case -3
				ExitLoop
		EndSwitch
	WEnd
EndFunc

Func arepqqkaeto($flmwacufre, $fljxaivjld)
	Local $fljiyeluhx = -1
	Local $flmwacufreheadermagic = DllStructCreate(arehdidxrgk($os[147]))
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
			Local $flwldjlwrq = Abs(DllStructGetData($flbaqvujsl[0], arehdidxrgk($os[7])))
			Local $flumnoetuu = DllStructGetData($flbaqvujsl[0], arehdidxrgk($os[7])) > 0 ? $flwldjlwrq - 1 : 0
			Local $flqphcjgtp = DllStructCreate(arehdidxrgk($os[148]))
			For $fllrcvawmx = 0 To $flwldjlwrq - 1
				$flamtlcncx = aremfkxlayv($flvikmhxwu, DllStructGetPtr($flbaqvujsl[1], Abs($flumnoetuu - $fllrcvawmx) + 1), DllStructGetData($flbaqvujsl[0], arehdidxrgk($os[6])) * 3)
				If $flamtlcncx = -1 Then ExitLoop
				$flamtlcncx = aremfkxlayv($flvikmhxwu, DllStructGetPtr($flqphcjgtp), Mod(DllStructGetData($flbaqvujsl[0], arehdidxrgk($os[6])), 4))
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
	Local $flrichemye = DllCall(arehdidxrgk($os[25]), arehdidxrgk($os[28]), arehdidxrgk($os[149]), arehdidxrgk($os[138]), @ScriptDir & arehdidxrgk($os[22]) & $flrriteuxd, arehdidxrgk($os[150]), 2147483648, arehdidxrgk($os[150]), 0, arehdidxrgk($os[28]), 0, arehdidxrgk($os[150]), 3, arehdidxrgk($os[150]), 128, arehdidxrgk($os[28]), 0)
	Return $flrichemye[0]
EndFunc

Func aremyfdtfqp($flzxepiook, $flzcodzoep = True)
	Local $flogmfcakq = DllCall(arehdidxrgk($os[25]), arehdidxrgk($os[28]), arehdidxrgk($os[149]), arehdidxrgk($os[138]), @ScriptDir & arehdidxrgk($os[22]) & $flzxepiook, arehdidxrgk($os[150]), 1073741824, arehdidxrgk($os[150]), 0, arehdidxrgk($os[28]), 0, arehdidxrgk($os[150]), $flzcodzoep ? 3 : 2, arehdidxrgk($os[150]), 128, arehdidxrgk($os[28]), 0)
	Return $flogmfcakq[0]
EndFunc

GUIDelete()

Func aremfkxlayv($fllsczdyhr, $flbfzgxbcy, $flutgabjfj)
	If $fllsczdyhr <> -1 Then
		Local $flvfnkosuf = DllCall(arehdidxrgk($os[25]), arehdidxrgk($os[150]), arehdidxrgk($os[151]), arehdidxrgk($os[28]), $fllsczdyhr, arehdidxrgk($os[152]), 0, arehdidxrgk($os[28]), 0, arehdidxrgk($os[150]), 2)
		If $flvfnkosuf[0] <> -1 Then
			Local $flwzfbbkto = DllStructCreate(arehdidxrgk($os[150]))
			$flvfnkosuf = DllCall(arehdidxrgk($os[25]), arehdidxrgk($os[28]), arehdidxrgk($os[153]), arehdidxrgk($os[28]), $fllsczdyhr, arehdidxrgk($os[28]), $flbfzgxbcy, arehdidxrgk($os[150]), $flutgabjfj, arehdidxrgk($os[28]), DllStructGetPtr($flwzfbbkto), arehdidxrgk($os[28]), 0)
			If $flvfnkosuf[0] <> 0 AND DllStructGetData($flwzfbbkto, 1) = $flutgabjfj Then
				Return 0
			EndIf
		EndIf
	EndIf
	Return -1
EndFunc

Func aremlfozynu($flfdnkxwze, ByRef $flgfdykdor)
	Local $flqcvtzthz = DllStructCreate(arehdidxrgk($os[154]))
	Local $flqnsbzfsf = DllCall(arehdidxrgk($os[25]), arehdidxrgk($os[26]), arehdidxrgk($os[155]), arehdidxrgk($os[28]), $flfdnkxwze, arehdidxrgk($os[39]), $flgfdykdor, arehdidxrgk($os[36]), DllStructGetSize($flgfdykdor), arehdidxrgk($os[39]), $flqcvtzthz, arehdidxrgk($os[28]), 0)
	Return $flqnsbzfsf[0]
EndFunc

Func arevtgkxjhu($fldiapcptm)
	Local $flhvhgvtxm = DllCall(arehdidxrgk($os[25]), arehdidxrgk($os[26]), arehdidxrgk($os[156]), arehdidxrgk($os[28]), $fldiapcptm)
	Return $flhvhgvtxm[0]
EndFunc

Func arebbytwcoj($flxljyoycl)
	Local $flaubrmoip = DllCall(arehdidxrgk($os[25]), arehdidxrgk($os[26]), arehdidxrgk($os[157]), arehdidxrgk($os[138]), $flxljyoycl)
	Return $flaubrmoip[0]
EndFunc

Func arenwrbskll($flpxhqhcav)
	Local $flzmcdhzwh = -1
	Local $flztpegdeg = DllStructCreate(arehdidxrgk($os[154]))
	Local $flekmcmpdl = DllCall(arehdidxrgk($os[25]), arehdidxrgk($os[36]), arehdidxrgk($os[158]), arehdidxrgk($os[28]), $flpxhqhcav, arehdidxrgk($os[39]), $flztpegdeg)
	If $flekmcmpdl <> -1 Then
		$flzmcdhzwh = $flekmcmpdl[0] + Number(DllStructGetData($flztpegdeg, 1))
	EndIf
	Return $flzmcdhzwh
EndFunc

Func areihnvapwn()
	Local $dlit = "7374727563743b75696e7420626653697a653b75696e7420626652657365727665643b75696e742062664f6666426974733b"
	$dlit &= "75696e7420626953697a653b696e7420626957696474683b696e742062694865696768743b7573686f7274206269506c616e"
	$dlit &= "65733b7573686f7274206269426974436f756e743b75696e74206269436f6d7072657373696f6e3b75696e7420626953697a"
	$dlit &= "65496d6167653b696e742062695850656c735065724d657465723b696e742062695950656c735065724d657465723b75696e"
	$dlit &= "74206269436c72557365643b75696e74206269436c72496d706f7274616e743b656e647374727563743b4FD5$626653697a6"
	$dlit &= "54FD5$626652657365727665644FD5$62664f6666426974734FD5$626953697a654FD5$626957696474684FD5$6269486569"
	$dlit &= "6768744FD5$6269506c616e65734FD5$6269426974436f756e744FD5$6269436f6d7072657373696f6e4FD5$626953697a65"
	$dlit &= "496d6167654FD5$62695850656c735065724d657465724FD5$62695950656c735065724d657465724FD5$6269436c7255736"
	$dlit &= "5644FD5$6269436c72496d706f7274616e744FD5$7374727563743b4FD5$627974655b4FD5$5d3b4FD5$656e647374727563"
	$dlit &= "744FD5$4FD5$2e626d704FD5$5c4FD5$2e646c6c4FD5$7374727563743b64776f72643b636861725b313032345d3b656e647"
	$dlit &= "374727563744FD5$6b65726e656c33322e646c6c4FD5$696e744FD5$476574436f6d70757465724e616d65414FD5$7074724"
	$dlit &= "FD5$436f6465497420506c7573214FD5$7374727563743b627974655b4FD5$5d3b656e647374727563744FD5$73747275637"
	$dlit &= "43b627974655b35345d3b627974655b4FD5$7374727563743b7074723b7074723b64776f72643b627974655b33325d3b656e"
	$dlit &= "647374727563744FD5$61647661706933322e646c6c4FD5$437279707441637175697265436f6e74657874414FD5$64776f7"
	$dlit &= "2644FD5$4372797074437265617465486173684FD5$437279707448617368446174614FD5$7374727563742a4FD5$4372797"
	$dlit &= "07447657448617368506172616d4FD5$30784FD5$30383032304FD5$30303031304FD5$36363030304FD5$30323030304FD5"
	$dlit &= "$303030304FD5$43443442334FD5$32433635304FD5$43463231424FD5$44413138344FD5$44383931334FD5$45364639324"
	$dlit &= "FD5$30413337414FD5$34463339364FD5$33373336434FD5$30343243344FD5$35394541304FD5$37423739454FD5$413434"
	$dlit &= "33464FD5$46443138394FD5$38424145344FD5$39423131354FD5$46364342314FD5$45324137434FD5$31414233434FD5$3"
	$dlit &= "4433235364FD5$31324135314FD5$39303335464FD5$31384642334FD5$42313735324FD5$38423341454FD5$43414633444"
	$dlit &= "FD5$34383045394FD5$38424638414FD5$36333544414FD5$46393734454FD5$30303133354FD5$33354432334FD5$314534"
	$dlit &= "42374FD5$35423243334FD5$38423830344FD5$43374145344FD5$44323636414FD5$33374233364FD5$46324335354FD5$3"
	$dlit &= "5424633414FD5$39454136414FD5$35384243384FD5$46393036434FD5$43363635454FD5$41453243454FD5$36304632434"
	$dlit &= "FD5$44453338464FD5$44333032364FD5$39434334434FD5$45354242304FD5$39303437324FD5$46463942444FD5$323646"
	$dlit &= "39314FD5$31394238434FD5$34383446454FD5$36394542394FD5$33344634334FD5$46454544454FD5$44434542414FD5$3"
	$dlit &= "7393134364FD5$30383139464FD5$42323146314FD5$30463833324FD5$42324135444FD5$34443737324FD5$44423132434"
	$dlit &= "FD5$33424544394FD5$34374636464FD5$37303641454FD5$34343131414FD5$35324FD5$7374727563743b7074723b70747"
	$dlit &= "23b64776f72643b627974655b383139325d3b627974655b4FD5$5d3b64776f72643b656e647374727563744FD5$437279707"
	$dlit &= "4496d706f72744b65794FD5$4372797074446563727970744FD5$464c4152454FD5$4552414c464FD5$43727970744465737"
	$dlit &= "4726f794b65794FD5$437279707452656c65617365436f6e746578744FD5$437279707444657374726f79486173684FD5$73"
	$dlit &= "74727563743b7074723b7074723b64776f72643b627974655b31365d3b656e647374727563744FD5$7374727563743b64776"
	$dlit &= "f72643b64776f72643b64776f72643b64776f72643b64776f72643b627974655b3132385d3b656e647374727563744FD5$47"
	$dlit &= "657456657273696f6e4578414FD5$456e746572207465787420746f20656e636f64654FD5$43616e2068617a20636f64653f"
	$dlit &= "4FD5$4FD5$48656c704FD5$41626f757420436f6465497420506c7573214FD5$7374727563743b64776f72643b64776f7264"
	$dlit &= "3b627974655b333931385d3b656e647374727563744FD5$696e743a636465636c4FD5$6a75737447656e6572617465515253"
	$dlit &= "796d626f6c4FD5$7374724FD5$6a757374436f6e76657274515253796d626f6c546f4269746d6170506978656c734FD5$546"
	$dlit &= "869732070726f6772616d2067656e65726174657320515220636f646573207573696e6720515220436f64652047656e65726"
	$dlit &= "1746f72202868747470733a2f2f7777772e6e6179756b692e696f2f706167652f71722d636f64652d67656e657261746f722"
	$dlit &= "d6c6962726172792920646576656c6f706564206279204e6179756b692e204FD5$515220436f64652047656e657261746f72"
	$dlit &= "20697320617661696c61626c65206f6e20476974487562202868747470733a2f2f6769746875622e636f6d2f6e6179756b69"
	$dlit &= "2f51522d436f64652d67656e657261746f722920616e64206f70656e2d736f757263656420756e6465722074686520666f6c"
	$dlit &= "6c6f77696e67207065726d697373697665204d4954204c6963656e7365202868747470733a2f2f6769746875622e636f6d2f"
	$dlit &= "6e6179756b692f51522d436f64652d67656e657261746f72236c6963656e7365293a4FD5$436f7079726967687420c2a9203"
	$dlit &= "23032302050726f6a656374204e6179756b692e20284d4954204c6963656e7365294FD5$68747470733a2f2f7777772e6e61"
	$dlit &= "79756b692e696f2f706167652f71722d636f64652d67656e657261746f722d6c6962726172794FD5$5065726d697373696f6"
	$dlit &= "e20697320686572656279206772616e7465642c2066726565206f66206368617267652c20746f20616e7920706572736f6e2"
	$dlit &= "06f627461696e696e67206120636f7079206f66207468697320736f66747761726520616e64206173736f636961746564206"
	$dlit &= "46f63756d656e746174696f6e2066696c6573202874686520536f667477617265292c20746f206465616c20696e207468652"
	$dlit &= "0536f66747761726520776974686f7574207265737472696374696f6e2c20696e636c7564696e6720776974686f7574206c6"
	$dlit &= "96d69746174696f6e207468652072696768747320746f207573652c20636f70792c206d6f646966792c206d657267652c207"
	$dlit &= "075626c6973682c20646973747269627574652c207375626c6963656e73652c20616e642f6f722073656c6c20636f7069657"
	$dlit &= "3206f662074686520536f6674776172652c20616e6420746f207065726d697420706572736f6e7320746f2077686f6d20746"
	$dlit &= "86520536f667477617265206973206675726e697368656420746f20646f20736f2c207375626a65637420746f20746865206"
	$dlit &= "66f6c6c6f77696e6720636f6e646974696f6e733a4FD5$312e205468652061626f766520636f70797269676874206e6f7469"
	$dlit &= "636520616e642074686973207065726d697373696f6e206e6f74696365207368616c6c20626520696e636c7564656420696e"
	$dlit &= "20616c6c20636f70696573206f72207375627374616e7469616c20706f7274696f6e73206f662074686520536f6674776172"
	$dlit &= "652e4FD5$322e2054686520536f6674776172652069732070726f76696465642061732069732c20776974686f75742077617"
	$dlit &= "272616e7479206f6620616e79206b696e642c2065787072657373206f7220696d706c6965642c20696e636c7564696e67206"
	$dlit &= "27574206e6f74206c696d6974656420746f207468652077617272616e74696573206f66206d65726368616e746162696c697"
	$dlit &= "4792c206669746e65737320666f72206120706172746963756c617220707572706f736520616e64206e6f6e696e6672696e6"
	$dlit &= "7656d656e742e20496e206e6f206576656e74207368616c6c2074686520617574686f7273206f7220636f707972696768742"
	$dlit &= "0686f6c64657273206265206c6961626c6520666f7220616e7920636c61696d2c2064616d61676573206f72206f746865722"
	$dlit &= "06c696162696c6974792c207768657468657220696e20616e20616374696f6e206f6620636f6e74726163742c20746f72742"
	$dlit &= "06f72206f74686572776973652c2061726973696e672066726f6d2c206f7574206f66206f7220696e20636f6e6e656374696"
	$dlit &= "f6e20776974682074686520536f667477617265206f722074686520757365206f72206f74686572206465616c696e6773206"
	$dlit &= "96e2074686520536f6674776172652e4FD5$7374727563743b7573686f72743b656e647374727563744FD5$7374727563743"
	$dlit &= "b627974653b627974653b627974653b656e647374727563744FD5$43726561746546696c654FD5$75696e744FD5$53657446"
	$dlit &= "696c65506f696e7465724FD5$6c6f6e674FD5$577269746546696c654FD5$7374727563743b64776f72643b656e647374727"
	$dlit &= "563744FD5$5265616446696c654FD5$436c6f736548616e646c654FD5$44656c65746546696c65414FD5$47657446696c655"
	$dlit &= "3697a65"
	Global $os = StringSplit($dlit, "4FD5$", 1)
EndFunc

Func arehdidxrgk($flqlnxgxbp)
	Local $flqlnxgxbp_
	For $flrctqryub = 1 To StringLen($flqlnxgxbp) Step 2
		$flqlnxgxbp_ &= Chr(Dec(StringMid($flqlnxgxbp, $flrctqryub, 2)))
	Next
	Return $flqlnxgxbp_
EndFunc

