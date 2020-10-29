---
title: fidler
date: 2020-10-14
ShowToc: true
TocOpen: true
summary: First challenge of FlareOn7
description: Writeup of 1_-_fidler, the first challenge in FlareOn7
keywords:
- writeup
- flareon7
- flareon 2020
- python
- reverse engineering

tags:
- writeup
- flareon7
category:
- writeup
series:
- FlareOn7 Writeups
series_weight: 1
---

```txt
Welcome to the Seventh Flare-On Challenge!

This is a simple game. Win it by any means necessary and the victory screen will reveal the flag. Enter the flag here on this site to score and move on to the next level.

This challenge is written in Python and is distributed as a runnable EXE and matching source code for your convenience. You can run the source code directly on any Python platform with PyGame if you would prefer.
```

```txt
$ file fidler.exe fidler.py
fidler.exe: PE32+ executable (console) x86-64, for MS Windows
fidler.py:  Python script, ASCII text executable, with CRLF line terminators
```
> Note: these are not the only files, but are the most important

## Introduction

So this is the first Flare-on 2020 challenge.

From the message its a python script, so we don't even need the `exe` file.

## Information collecting

There are useless information like the password `ghost` to start the game.

But we see an interesting part which leads to the `victory screen`.

```python
# line 147
        target_amount = (2**36) + (2**35)
        if current_coins > (target_amount - 2**20):
            while current_coins >= (target_amount + 2**20):
                current_coins -= 2**20
            victory_screen(int(current_coins / 10**8))
            return

```

And in that part of the code:

```python
def decode_flag(frob):
    last_value = frob
    encoded_flag = [1135, 1038, 1126, 1028, 1117, 1071, 1094, 1077, 1121, 1087, 1110, 1092, 1072, 1095, 1090, 1027,
                    1127, 1040, 1137, 1030, 1127, 1099, 1062, 1101, 1123, 1027, 1136, 1054]
    decoded_flag = []

    for i in range(len(encoded_flag)):
        c = encoded_flag[i]
        val = (c - ((i%2)*1 + (i%3)*2)) ^ last_value
        decoded_flag.append(val)
        last_value = c

    return ''.join([chr(x) for x in decoded_flag])


def victory_screen(token):
	# ... trimmed ...
    flag_content_label.change_text(decode_flag(token))
```

## Solution

We can join these parts to get the flag:

```python
def decode_flag(frob):
    last_value = frob
    encoded_flag = [1135, 1038, 1126, 1028, 1117, 1071, 1094, 1077, 1121, 1087, 1110, 1092, 1072, 1095, 1090, 1027,
                    1127, 1040, 1137, 1030, 1127, 1099, 1062, 1101, 1123, 1027, 1136, 1054]
    decoded_flag = []

    for i in range(len(encoded_flag)):
        c = encoded_flag[i]
        val = (c - ((i%2)*1 + (i%3)*2)) ^ last_value
        decoded_flag.append(val)
        last_value = c

    return ''.join([chr(x) for x in decoded_flag])

# this is larger than `target_amount` by 1
current_coins = (2**36) + (2**35) + 1
print(decode_flag(int(current_coins / 10**8)))
```

```txt
idle_with_kitty@flare-on.com
```
