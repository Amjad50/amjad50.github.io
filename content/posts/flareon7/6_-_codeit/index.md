---
title: codeit
date: 2020-10-21
ShowToc: true
TocOpen: true
summary: Sixth challenge of FlareOn7
description: Writeup of 6_-_codeit, the sixth challenge in FlareOn7
keywords:
- writeup
- flareon7
- flareon 2020
- autoit3
- reverse engineering

tags:
- writeup
- flareon7
- autoit3
category:
- writeup
series:
- FlareOn7 Writeups
series_weight: 6
---

```txt
Reverse engineer this little compiled script to figure out what you need to do to make it give you the flag (as a QR code).
```

```txt
$ file codeit.exe
codeit.exe:  PE32 executable (GUI) Intel 80386, for MS Windows, UPX compressed
```
> Note: these are not the only files, but are the most important

## Introduction

This looks like a `UPX` packed binary, but its not corrupted, so we can unpack it without trouble.

## Information collecting

When analyzing this file, its noted that it imports a
lot of stuff.

I starting reversing engineering this binary, but could not understand what
is going on, there is about `2235` functions and no clear entry or useful code.
Until I saw a string `"his is a third-party compiled AutoIt script"`.
So I looked into this [AutoIt] and found that its a scripting language result in a compiled binary.

There is a decompiler [Exe2Aut], which can be used to decompile [AutoIt] scripts.

The content of the decompiled script can be found in:

- Decompiled_codeit:
	- [codeit_.au3](./Decompiled_codeit/codeit_.au3)
	- [qr_encoder.dll](./Decompiled_codeit/qr_encoder.dll)
	- [sprite.bmp](./Decompiled_codeit/sprite.bmp)


Looking at the code, its messy, lets try to fix it.

### Fixing numbers

Starting from line `134` a block of variables that are only numbers,
and not reassigned is present. We can fix it with:
```python
import re

d = ''
with open('codeit_.au3') as f:
    d = f.read()

# extract all the pairs
numbers_list = re.findall(r'(\$.*?) = Number\(" (.*?) "\)', d)

for number in numbers_list:
    d = d.replace(number[0], number[1])

print(d)
```

The content of the new script (also removed the whole numbers block manually) is present in
[codeit_numbers_fixed.au3](./fixed_code/codeit_numbers_fixed.au3).

### Fix `$os` strings

```AutoIt
#OnAutoItStartRegister "AREIHNVAPWN"
```
This is used to register a function to run at the beginning,

```AutoIt
Func areihnvapwn()
	Local $dlit = "7374727563743b75..."
	$dlit &= "75696e74206269536..."
    ...
	Global $os = StringSplit($dlit, "4FD5$", 1)
```

This function just splits the large string by `"4FD5$"`.

The `$os` strings are always used with the `arehdidxrgk` function,
which decodes the hex string.

We can fix this also:
```python
import re
import codecs

d = ''
with open('codeit_numbers_fixed.au3') as f:
    d = f.read()

big_str = "7374727563743b75696..."

split_str = big_str.split("4FD5$")

decoded_str_list = [codecs.decode(x, 'hex').decode() for x in split_str]

result = re.sub(r'arehdidxrgk\(\$os\[(\d*?)\]\)', lambda x: f'"{decoded_str_list[int(x.group(1)) - 1]}"', d)

print(result)

```

The content of the new script is present in
[codeit_os_fixed.au3](./fixed_code/codeit_os_fixed.au3).


### Renaming functions

This step might not be necessary, but it makes analysis easier.
This is done through static analysis, example for this:

```AutoIt
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
```

For example this function, seems to setup a `1024` buffer and calls `GetComputerNameA`,
we can assume from this that this function's purpose is to call `GetComputerNameA`
and rename it accordingly. There are many for these, which are easy to analyze so I'll not
go through all of them.

The final result is available in [codeit_renames_fixed.au3](./fixed_code/codeit_renames_fixed.au3).

### `main` function

Now with a clean code, let's start.

This is the most important pieces of main:
```AutoIt
Func main()
        ; ... trimmed ...
		Switch GUIGetMsg()
			Case $input_button
				Local $input_string = GUICtrlRead($input_field)
				If $input_string Then
					Local $qr_encoder_dll = get_qr_encoder_dll()
					Local $flnpapeken = DllStructCreate("struct;dword;dword;byte[3918];endstruct")
					Local $fljfojrihf = DllCall($qr_encoder_dll, "int:cdecl", "justGenerateQRSymbol", "struct*", $flnpapeken, "str", $input_string)
					If $fljfojrihf[0] <> 0 Then
						areyzotafnf($flnpapeken)
						Local $flbvokdxkg = generate_BMP_file_struct((DllStructGetData($flnpapeken, 1) * DllStructGetData($flnpapeken, 2)), (DllStructGetData($flnpapeken, 1) * DllStructGetData($flnpapeken, 2)), 1024)
						$fljfojrihf = DllCall($qr_encoder_dll, "int:cdecl", "justConvertQRSymbolToBitmapPixels", "struct*", $flnpapeken, "struct*", $flbvokdxkg[1])
						If $fljfojrihf[0] <> 0 Then
							$image_file = generate_random_string(25, 30) & ".bmp"
							write_BMP_file($flbvokdxkg, $image_file)
						EndIf
					EndIf
					DeleteFileA($qr_encoder_dll)
				Else
					$image_file = get_sprite_image()
				EndIf
				GUICtrlSetImage($image_controller, $image_file)
        ; ... trimmed ...
```

In these parts, `justGenerateQRSymbol` is called from `qr_encoder.dll` with the input string as
argument. Then `areyzotafnf` is called with the resulting data.
Finally `justConvertQRSymbolToBitmapPixels` is called and the image is being displayed.

From above, `areyzotafnf` looks really suspicious. And looking into this function,
it actually calls some crypto functions, so lets look into it.

### `areyzotafnf` function

The entry of the function:
```AutoIt
Func areyzotafnf(ByRef $arg1)
	Local $flisilayln = GetComputerNameA()
	If $flisilayln <> -1 Then
		$flisilayln = Binary(StringLower(BinaryToString($flisilayln)))
		Local $unkown_buffer = DllStructCreate("struct;byte[" & BinaryLen($flisilayln) & "];endstruct")
		DllStructSetData($unkown_buffer, 1, $flisilayln)
		aregtfdcyni($unkown_buffer)
    ; ... trimmed ...
    ; hash and encryption checks with `$unknown_buffer`
```

In here, we see the computer name is passed to `aregtfdcyni` in lower case,
Looks like the buffer is being edited inplace. Then that buffer is hashed,
then a large chunk of data is decrypted with the hash.
Lastly, the resulting buffer should start with `FLARE` and end with `ERALF`.

If all of this passes, the argument is modified:
```AutoIt
DllStructSetData($arg1, 1, BinaryMid($flsekbkmru, 6, 4))
DllStructSetData($arg1, 2, BinaryMid($flsekbkmru, 10, 4))
DllStructSetData($arg1, 3, BinaryMid($flsekbkmru, 14, BinaryLen($flsekbkmru) - 18))
```

We clearly don't know the correct computer name, but we have `aregtfdcyni` to check.

### `aregtfdcyni` function

The variables in function in the last fixed file are all renamed for easier analysis.

What the function does:
1) Read the sprite image.
1) Takes the `LSB` (least significant bit) of the first pixels of the image and group them into `7-bit` numbers.
2) Add each of the resulting bytes buffer the computer name buffer bytes.
3) Do one `ROR` (rotate 1 bit to the right).

So looks like its encrypting the computer name with data from the sprite image.
We can extract the resulting buffer from the image with the script below:

```python
# convert 7 bytes buffer into 7-bit value by using LSB
def lsb(s):
    r = 0
    counter = 0
    for i in range(6, -1, -1):
        r += (s[counter] & 1) << i
        counter += 1
    return r

d = b''
with open('sprite.bmp', 'rb') as f:
    d = f.read()[54:]

split_by_7_bytes = [d[i:i+7] for i in range(0, len(d), 7)]

result = [lsb(x) for x in split_by_7_bytes[:-1]]

print(bytes(result[:15]))
```

In the script, first we read the image and ignore the first `54` bytes as they are `BMP` file header.

Next, we group every `7` bytes together and generate the `7-bit` number. Lastly, we output the first `15` characters, because in windows, computer name can be `15` characters.

The result:
```python
b'aut01tfan1999\x7f\x7f\x7f'
```

And that is very interesting. When I saw this I thought it is the correct computer name.

## Solution

We can try to apply `aut01tfan1999` in place of our computer
name in `areyzotafnf`:
```AutoIt
Func areyzotafnf(ByRef $arg1)
	Local $flisilayln = "aut01tfan1999"
	If $flisilayln <> -1 Then
    ; ... trimmed ...
```

When running the app, the `QR` code is different from the default (No matter the input), and this is a good sign for it being the flag.

![flag_qr](./flag_qr.png)

Then using any way to read the `QR` code we get:

```txt
L00ks_L1k3_Y0u_D1dnt_Run_Aut0_Tim3_0n_Th1s_0ne!@flare-on.com
```

[AutoIt]: https://www.autoitscript.com/site/autoit/

