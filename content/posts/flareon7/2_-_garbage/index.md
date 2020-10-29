---
title: garbage
date: 2020-10-14T01:00:00+03:00
ShowToc: true
TocOpen: true
summary: Second challenge of FlareOn7
description: Writeup of 2_-_garbage, the second challenge in FlareOn7
keywords:
- writeup
- flareon7
- flareon 2020
- upx
- reverse engineering

tags:
- writeup
- flareon7
category:
- writeup
series:
- FlareOn7 Writeups
series_weight: 2
---

```txt
One of our team members developed a Flare-On challenge but accidentally deleted it. We recovered it using extreme digital forensic techniques but it seems to be corrupted. We would fix it but we are too busy solving today's most important information security threats affecting our global economy. You should be able to get it working again, reverse engineer it, and acquire the flag.
```

```txt
$ file garbage.exe
garbage.exe: PE32 executable (console) Intel 80386, for MS Windows, UPX compressed
```

## Introduction

Looks like this is a [UPX] packed binary, but trying to unpack it using

```txt
upx -d garbage.exe
```
results in
```txt                       
                       Ultimate Packer for eXecutables
                          Copyright (C) 1996 - 2020
UPX git-d7ba31+ Markus Oberhumer, Laszlo Molnar & John Reiser   Jan 23rd 2020

        File size         Ratio      Format      Name
   --------------------   ------   -----------   -----------
upx: garbage.exe: OverlayException: invalid overlay size; file is possibly corrupt

Unpacked 1 file: 0 ok, 1 error.
```

That is a strange error there, we have to dig deeper.

## Information collecting

Trying things out, I got something interesting from `Ghidra` when trying to import the `exe` file.

```txt
Error importing file: garbage-cc.exe
java.lang.IndexOutOfBoundsException: Specified length extends beyond file bytes length
```

> Note: `IDA` imports it fine btw.

Maybe this file is corrupted by shrinking the size of the file, and that does not match the size specified in the PE header?

I tried to test this theory so I appended a number of `NULL`(`\x00`) bytes at the end of the file. Doing so actually fixed it and I managed to unpack it,
but there is no imports in the file, or at least they are not resolved.

Even without imports, I tried looking into the strings to find anything and found:

```python
"nPTnaGLkIqdcQwvieFQKGcTGOTbfMjDN...", # trimmed
"KglPFOsQDxBPXmclOpmsdLDEPMRWbMDz...", # trimmed
"covid19-sucks",
```

The first and second one are used in `sub_40106B`, which seems an interesting function,
Also looking in the `entry` we find that this function seems to be `main`. So lets look
into it.

The third string is not being used anywhere.

## Solution

In the function `FUN_0040106b`, we find that it decrypts the above strings using `XOR` in
`FUN_00401000` together with integer array. The results are used in functions that are not resolved due to not having import table.

Something like:
```C                      
  FUN_00401000(&local_13c,(int)&local_1c,0x14,(int)local_c4);
  iVar2 = (*(code *)(undefined *)0x12418)(local_13c,0x40000000,2,0,2,0x80,0);
```

The function in `0x12418` seems like `CreateFile`. (Yes looks like, the decrypted first parameter is a file name, see below).

The flag pair is:
```python
encrypted_string = b'nPTnaGLkIqdcQwvieFQKGcTGOTbfMjDNmvibfBDdFBhoPaBbtfQuuGWYomtqTFqvBSKdUMmciqKSGZaosWCSoZlcIlyQpOwkcAgw'

key = [0x2C332323, 0x49643F0E, 0x40A1E0A, 0x1A021623, 0x24086644, 0x2C741132, 0x0F422D2A, 0x0D64503E, 0x171B045D, 0x5033616, 0x8092034, 0x0E242163, 0x58341415, 0x3A79291A, 0x58560000, 0x54]
```

We can decrypt them with:

```python
import struct
def decrypt(string, key):
    # convert the little-endian ints into bytes and concat them together
    ready_key = b''.join([struct.pack('i', x) for x in key])

    return bytes([x[0] ^ x[1] for x in zip(string, ready_key)])

print(decrypt(encrypted_string, key))
```
And we got the flag
```vb
MsgBox("Congrats! Your key is: C0rruptGarbag3@flare-on.com")\x00Fqv
```

> Note: the other one decrypted is "`sink_the_tanker.vbs`", which is the filename.

[UPX]: https://upx.github.io/