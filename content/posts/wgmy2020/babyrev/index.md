---
title: WGMY2020 - RE - babyrev
date: 2020-12-06T7:00:50+03:00
ShowToc: true
TocOpen: true
summary: Simple reversing challenge
description: Writeup of the reversing challenge bebyrev in WGMY2020
keywords:
- writeup
- wgmy2020
- reverse engineering

tags:
- writeup
- wgmy2020
category:
- writeup
series:
- Wargames Malaysia 2020 writeups
series_weight: 0
---

```txt
$ file *
babyrev: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=0d3189284d68e7952dd33d55799f885e320089b9, for GNU/Linux 3.2.0, not stripped
```

# Introduction
The challenge contains a single Linux executable `ELF` file that is not stripped (has debug symbols, which will
make our life easier).

I'll be using [Ghidra] for analysing this binary.

# Analysis
After opening the file in [Ghidra], we can start by searching for the `main`
function in the left panel. We found it and here it is:

```C
undefined8 main(void)
{
  int iVar1;
  size_t sVar2;
  byte local_68 [48];
  byte local_38 [44];
  int local_c;
  
  printf("Enter password: ");
  __isoc99_scanf(&DAT_00102019,local_38);
  sVar2 = strlen((char *)local_38);
  if (sVar2 == 0x20) {
    local_c = 0;
    while (local_c < 0x20) {
      local_68[local_c] = local_38[(int)(uint)(byte)SHUFFLE[local_c]];
      local_68[local_c] = local_68[local_c] ^ XOR[local_c];
      local_c = local_c + 1;
    }
    iVar1 = strncmp((char *)local_68,(char *)local_38,0x20);
    if ((iVar1 == 0) && (iVar1 = strncmp((char *)(local_68 + 0x1b),"15963",3), iVar1 == 0)) {
      printf("Correct password! The flag is wgmy{%s}",local_38);
    }
    else {
      puts("Incorrect password!");
    }
  }
  else {
    puts("The password must be in length of 32!");
  }
  return 0;
}
```

In [Ghidra], there are some types not present in `C` like `undefined`, but we can
ignore them and just analyze what the program is doing. Here is the basic flow:

1) Get input from the user and check that the length of the input is **0x20 (32)** characters.
2) We do some encryption using `SHUFFLE` and `XOR` global arrays.
3) We check that the result is the same as the input.
4) Lastly, check that the characters at `0x1b..0x1e(exclusive)` are equal to `"159"`.

> Even though in the last `strncmp` it is comparing it with `"15963"`, it is using
> **3** as `n`.

So now we need to reverse the encryption.

# Solution
First, let's get the `SHUFFLE` and `XOR` arrays,
```python
shuffle = [7, 4, 21, 18, 29, 19, 27, 8, 31, 22, 15, 6, 10, 25, 24, 17, 1, 3, 2, 23, 13, 20, 5, 0, 12, 28, 11, 26, 14, 30, 9, 16]
xor = [86, 6, 6, 1, 9, 82, 6, 3, 81, 4, 87, 7, 82, 7, 80, 6, 6, 6, 7, 84, 87, 86, 2, 85, 6, 1, 82, 83, 84, 15, 84, 3]
```

In the encryption process, it loops through all character, shuffle it and XOR it
with a value.

We can reverse that by XORing the result, which we have `3` characters of for now,
and re-position the XORed characters in their original location.

I'll be using [Python] for programming the decryption logic:

Let's make an array of `None`s to hold the result/decrypted buffer as they are the same,
and fill it with the known **3** characters
```python
decrypted = [None] * 0x20
decrypted[-5:-2] = b"159"
```

Then for reversing the encryption, we will loop until the buffer is full:
```python
# loop until there is no `None` value in `decrypted`
while None in decrypted:
    # loop through all characters that are not `None`
    for i in range(0x20):
        d = decrypted[i]
        if d is not None:
            # XOR with the correct value
            d ^= xor[i]
            # re-position
            decrypted[shuffle[i]] = d
```

In the end we should get `decypted` filled:
```python
print(bytes(decrypted))
```
```txt
76420d7abbe073a20436d2fb14b15963
```

### Flag
In the code it prints the flag in `"wgmy{%s}"`
```txt
wgmy{76420d7abbe073a20436d2fb14b15963}
```

[Ghidra]: https://ghidra.re/
[Python]: https://www.python.org/
