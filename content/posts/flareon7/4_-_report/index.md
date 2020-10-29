---
title: report
date: 2020-10-14
ShowToc: true
TocOpen: true
summary: Fourth challenge of FlareOn7
description: Writeup of 4_-_report, the fourth challenge in FlareOn7
keywords:
- writeup
- flareon7
- flareon 2020
- document malware
- reverse engineering

tags:
- writeup
- flareon7
- document malware
category:
- writeup
series:
- FlareOn7 Writeups
series_weight: 4
---

```txt
Nobody likes analysing infected documents, but it pays the bills. Reverse this macro thrill-ride to discover how to get it to show you the key.
```

```txt
$ file report.xls
report.xls: Composite Document File V2 Document, Little Endian, Os: Windows, Version 10.0, Code page: 1252, 0x17: 1048576CDFV2 Microsoft Excel
```

## Introduction

As this is a document file, its mostly going to be Macro stuff.

And this is confirmed by trying to extract any macros, I used `olevba3` which is part of [oletools].

And like expected it had a really big one (most of it is data). Can be
found in [macro.out](./macro.out).

## Information collecting

Alright, lets go.

### The big data sections

There are two data blocks in `F`. The first one is small and it seperated by `"."` character:
```hex
9655B040B64667238524D15D6201.B95D4E01C55CC562C7557405A532D768C55FA12DD074DC697A06E172992CAF3F8A5C7306B7476B38.C555AC40A7469C234424.853FA85C470699477D3851249A4B9C4E.A855AF40B84695239D24895D2101D05CCA62BE5578055232D568C05F902DDC74D2697406D7724C2CA83FCF5C2606B547A73898246B4BC14E941F9121D464D263B947EB77D36E7F1B8254.853FA85C470699477D3851249A4B9C4E.9A55B240B84692239624.CC55A940B44690238B24CA5D7501CF5C9C62B15561056032C468D15F9C2DE374DD696206B572752C8C3FB25C3806.A8558540924668236724B15D2101AA5CC362C2556A055232AE68B15F7C2DC17489695D06DB729A2C723F8E5C65069747AA389324AE4BB34E921F9421.CB55A240B5469B23.AC559340A94695238D24CD5D75018A5CB062BA557905A932D768D15F982D.D074B6696F06D5729E2CAE3FCF5C7506AD47AC388024C14B7C4E8F1F8F21CB64
```
The other one is so gigantic to be included here, check [F.T.Text.txt](./F.T.Text.txt) it is `1142916` bytes.

### `rigmarole` function and fix encoded strings

From the `Workbook_Open` and `Auto_Open` functions, the main is in `Sheet1.folderol`.

We can see the first big data block (which is named `F.L`) is being used.
```vb
    onzo = Split(F.L, ".")
```

But in `folderol`, the pattern `rigmarole(onzo($index))` is used a lot.
`rigmarole` looks like decoding function, so lets replace all the calls with the
results real quick before going into `folderol`.

```python
L = [
# .. has F.L split by "."
]

def rigmarole(es):
    return ''.join([chr(int(es[i:i+2], 16) - int(es[i+2:i+4], 16)) for i in range(0, len(es), 4)])

[rigmarole(x) for x in d]
```
```python
['AppData',
 '\\Microsoft\\stomp.mp3',
 'play ',
 'FLARE-ON',
 'Sorry, this machine is not supported.',
 'FLARE-ON',
 'Error',
 'winmgmts:\\\\.\\root\\CIMV2',
 'SELECT Name FROM Win32_Process',
 'vbox',
 'WScript.Network',
 '\\Microsoft\\v.png']
```

Using these strings we can fill them in the appropriate places, check [macro_1_fixed](./macro_1_fixed.vb).

### `folderol` function

In this function, there is a check for internet connection and then tries to checks if the machine is a VM. If it is it will run
```vb
MsgBox "Sorry, this machine is not supported.", vbCritical, "Error"
```

Then after that
```vb
    xertz = Array(&H11, &H22, &H33, &H44, &H55, &H66, &H77, &H88, &H99, &HAA, &HBB, &HCC, &HDD, &HEE)

    wabbit = canoodle(F.T.Text, 0, 168667, xertz)
    mf = Environ("AppData") & "\\Microsoft\\stomp.mp3"
    Open mf For Binary Lock Read Write As #fn
      Put #fn, , wabbit
    Close #fn
    
    mucolerd = mciSendString("play " & mf, 0&, 0, 0)
```

it will call `canoodle` to decrypt `F.T.Text` (the second big data block) with the key in `xertz`. Then writes the content into `"%APPDATA%\\Microsoft\\stomp.mp3"`. And calls `play` on the file.

Let's analyze `canoodle` and find the content of the file that was written.

### `canoodle` function

This function is the function that is used to decrypts the big data block `F.T.Text`.

The function definition can be rewritten to:
```python
def canoodle(encrypted_data: str, start: int, end: int, key: list[int])
```

It will loop through `encrypted_data` string but `4` characters at a time,
but only XOR the first 2 character with the key integer value.

Something like:
```python
counter = 0
for i in range(0, len(encrypted_data), 4):
    char = encrypted_data[i:i+2]
    key_int = key[counter % len(key)]
    encoded_int = int(char, 16)

    return encoded_int ^ key_int
```

As you might have guessed, using this method not all the data in `F.T.Text` is being used, and as expected the result of the following line (the content of the `mp3` file):
```vb
    wabbit = canoodle(F.T.Text, 0, 168667, xertz)
```

Is not the flag and only sound of stomps :D

### The real `folderlo` function

In the results of `olevba3` script there was a large chunk of what looked like
a somewhat compiled version of `VBA` which is called `P-Code`.
```txt
VBA MACRO VBA_P-code.txt 
in file: VBA P-code - OLE stream: 'VBA P-code'
```

At first I just ignored it because it looked similar to the original
code before it, so I thought it is a compiled version of it.
But that was wrong, it is actually important.

## Solution

Most of the `real` `folderlo` function is the same, These are the additional parts:
```vb
groke = CreateObject("WScript.Network")
firkin = groke.UserDomain

If firkin != "FLARE-ON" Then
    MsgBox "Sorry, this machine is not supported.", vbCritical, "Error"
    End
End If

n = Len(firkin)
For i = 1 To n
    buff(n - i) = Mid(firkin, i, 1)

canoodle(F.T.Text, 2, 0x45C21, buff)
// ...
```
`0x45C21` = `285729` (this is much bigger that the first one).

Now with this, becuase `canoodle`'s second argument is `2` it makes sense that it
takes step of `4` on each loop.

And the key now is the reversed version of the string `"FLARE-ON"`.

Decoding `F.T.Text` string with the arguments above, we get this:

![flag](./flag.png)

Flag:
```txt
thi5_cou1d_h4v3_b33n_b4d@flare-on.comp
```

[oletools]: https://github.com/decalage2/oletools