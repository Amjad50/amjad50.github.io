---
title: WGMY2020 - misc - Defuse The Bomb!
date: 2020-12-06T20:40:50+03:00
ShowToc: true
TocOpen: true
summary: Zip chain hell challenge
description: Writeup of the misc challenge Defuse The Bomb! in WGMY2020
keywords:
- writeup
- wgmy2020

tags:
- writeup
- wgmy2020
category:
- writeup
series:
- Wargames Malaysia 2020 writeups
series_weight: 5
author: Fahad Ali
---

```txt
$ file bomb.zip
bomb.zip: Zip archive data, at least v2.0 to extract
```

# Introduction
This challenge has just a single zip file `bomb.zip`, and looking into it, it has nested zips inside and it might be deep.

# Solution
## First try
At first, we used an automated script to extract all files, we got `flag.txt` but it only contained many `w` characters,
without any sign of the flag.

## Second try
After taking a closer look in the zip files, here an example using `7z` command:
```txt
$ 7z l bomb.zip

7-Zip [64] 16.02 : Copyright (c) 1999-2016 Igor Pavlov : 2016-05-21
p7zip Version 16.02 (locale=en_US.UTF-8,Utf16=on,HugeFiles=on,64 bits,8 CPUs AMD Ryzen 5 PRO 3500U w/ Radeon Vega Mobile Gfx (810F81),ASM,AES-NI)

Scanning the drive for archives:
1 file, 206803 bytes (202 KiB)

Listing archive: bomb.zip

--
Path = bomb.zip
Type = zip
Physical Size = 206803

   Date      Time    Attr         Size   Compressed  Name
------------------- ----- ------------ ------------  ------------------------
2020-12-03 08:31:56 .....       157842         8428  0.zip
2020-12-03 08:31:56 .....       157842         8428  1.zip
2020-12-03 08:31:56 .....       157842         8428  10.zip
2020-12-03 08:31:56 .....       157842         8428  11.zip
2020-12-03 08:31:56 .....       157842         8428  12.zip
2020-12-03 08:31:56 .....       157842         8428  13.zip
2020-12-03 08:31:56 .....       157842         8428  14.zip
2020-12-03 08:31:56 .....       157842         8428  15.zip
2020-12-03 08:31:56 .....       157842         8428  16.zip
2020-12-03 08:31:56 .....       157842         8428  17.zip
2020-12-03 08:31:56 .....       157842         8428  18.zip
2020-12-03 08:31:56 .....       157842         8428  19.zip
2020-12-03 08:31:56 .....       157842         8428  2.zip
2020-12-03 08:31:56 .....       157842         8428  3.zip
2020-12-03 08:31:56 .....       157842         8428  4.zip
2020-12-03 08:31:56 .....       157842         8428  5.zip
2020-12-03 08:31:56 .....       157842         8428  6.zip
2020-12-03 08:31:56 .....       179640        43869  7.zip
2020-12-03 08:31:56 .....       157842         8428  8.zip
2020-12-03 08:31:56 .....       157842         8428  9.zip
------------------- ----- ------------ ------------  ------------------------
2020-12-03 08:31:56            3178638       204001  20 files$
```
We can see that `7.zip` contains a different file size:
```txt
2020-12-03 08:31:56 .....       179640        43869  7.zip
```

So we continue this chain:

`bomb.zip` -> `7.zip` -> `1.zip` -> `4.zip` -> `9.zip` -> `18.zip` -> `8.zip` -> `flag.txt`.

Then we can use `grep` to get the flag:
```txt
$ grep wgmy flag.txt
wgmy{04a2766e72f0e267ed58792cc1579791}
```