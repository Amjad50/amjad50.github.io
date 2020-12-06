---
title: WGMY2020 - RE - Senang
date: 2020-12-06T7:31:50+03:00
ShowToc: true
TocOpen: true
summary: Second reverse engineering challenge in WGMY2020
description: Writeup of the reversing challenge Senang in WGMY2020
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
series_weight: 1
---

```txt
$ file *
senang.exe:   PE32 executable (console) Intel 80386, for MS Windows
```

# Introduction
This time it is a windows executable.

I'll be using [Ghidra] and [x64dbg] for static and dynamic analysis for this challenge. 

# Analysis
After opening the file in [Ghidra], we can start by searching for the `main`
function in the left panel. This time the `main` function is not found.

There are many methods to find the `main` function, I'll find it using strings.
When looking in the strings stored in the binary in [Ghidra], we can see interesting strings
like `"Welcome to WGMY 2020 - senang"`, `"Enter flag : "`, `"Tahniah !!! Sila submit flag ;)"`,
and `"Nope, tak betul. Sila jaga jarak sosial ok.\n"`.

When looking at the function referencing these strings, we found the function `FUN_00401000`, which
looks like the main.

## `main` analysis

```C
void FUN_00401000(void)
{
  int iVar1;
  int local_6c [25];
  uint local_8;
  
  local_8 = DAT_004200ec ^ (uint)&stack0xfffffffc;
  FUN_00403400(local_6c,0,100);
  FUN_004012e0((int)s_Welcome_to_WGMY_2020_-_senang_0042001c);
  FUN_004012e0((int)s_Enter_flag_:_0042003c);
  FUN_00401320((int)&DAT_0042004c);
  iVar1 = FUN_00401090(local_6c);
  if (iVar1 == 0) {
    FUN_004012e0((int)s_Nope,_tak_betul._Sila_jaga_jarak_00420070);
  }
  else {
    FUN_004012e0((int)s_Tahniah_!!!_Sila_submit_flag_;)_00420050);
  }
  FUN_004028b3();
  return;
}
```

There are so many unknown functions, but we can guess what they do, like
`FUN_004012e0` seems to deal with strings always and looks like its printing them, so we
can rename it to `print` for example.

The part below, which is after printing `"Enter flag: "`, maybe it can be getting input, and we can confirm this
by looking at `DAT_0042004c`, which is `"%s"`.
```C
FUN_00401320((int)&DAT_0042004c);
```
[Ghidra] in this case didn't detect the second argument for the buffer of the string, but if we force it:
```C
FUN_00401320((int)&DAT_0042004c,local_6c);
```
`local_6c` is a **26** character buffer, so that checks out. Now we can rename `FUN_00401320` to `scan`.

Finally, the function `FUN_00401090` is being called with the buffer for checking.

## `FUN_00401090` analysis
[Ghidra] makes `param1` of type `int*` but we know its not true,so for easier analysis,
 let's convert it to `char*`.

```C
void FUN_00401090(char *param_1)
{
  int iVar1;
  uint local_80;
  uint local_7c [26];
  undefined4 *local_14;
  
  local_14 = (undefined4 *)0x0;
  if (((*(int *)param_1 == 0x796d6777) && (param_1[4] == '{')) && (param_1[0x25] == '}')) {
    FUN_004013a0(local_7c);
    FUN_00401420(local_7c,PTR_s_Kuehtiow_was_here_?_00420000,DAT_00420018);
    FUN_004015b0(local_7c);
    local_80 = 0;
    while (local_80 < 0x10) {
      FUN_00401360(&local_14,(int)&DAT_004200a0);
      iVar1 = _strncmp((char *)&local_14,param_1 + local_80 * 2 + 5,2);
      if (iVar1 != 0) break;
      local_80 = local_80 + 1;
    }
  }
  FUN_004028b3();
  return;
}
```


The function first checks for the `wgmy{}` part in the flag in:
```C
if (((*(int *)param_1 == 0x796d6777) && (param_1[4] == '{')) && (param_1[0x25] == '}')) {
```
`0x796d6777` is `wgmy`. `{` at index **4** and `}` at index **0x25**, now we know the middle part is **0x20(32)** characters
long, and it is checked next.

Looks like `FUN_004013a0(local_7c);` fills the buffer `local_7c` with some values, I don't know what it represents.
`FUN_00401420` and `FUN_004015b0` seems to do some transformation for the buffer. I'll come back to this in a bit as it is complex.

Finally, comparison:
```C
while (counter < 0x10) {
    FUN_00401360(&local_14,(int)&DAT_004200a0);
    iVar1 = _strncmp((char *)&local_14,param_1 + counter * 2 + 5,2);
    if (iVar1 != 0) break;
    counter =  + 1;
}
```
I renamed `local_80` to `counter` for easier analysis.

judging from `DAT_004200a0` = `"%02x"` the argument to `FUN_00401360`, `FUN_00401360` looks like `sprintf`. because the result string
at `local_14` is being compared to the input string **2** characters at a time. And looks like the correct flag comes from the series
of transformations done above.

We can analyse the above methods that transforms `local_7c` buffer statically, but doing it dynamically is much easier,
as the `local_7c` is independent from the input, so we can just look at the arguments of the `_strncmp` method to find the correct flag.

# Dynamic analysis
I'll be using [x64dbg] in `32-bit` mode for this binary. Let's just run the binary and jump straight to the function
`FUN_00401090`. Looks like the binary has randomization for addresses, so the function will not be at `401090`, but the offset
is enough, we should go to `xxxx1090` (in my case it was `00571090`).

In the middle we will have to input a flag, so let's use this
```txt
wgmy{aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa}
```

The call to `_strncmp` is at `00401176`, so let's make a breakpoint there. When continuing we reach the breakpoint,
When looking at the argument stack we find the first 2 characters of the flag to be `b4`. Now if we continue we will exit the
program as `b4` does not equal `aa`, so in order to prevent the `jump`, we can patch the instruction
(as [x64dbg] enables us to do so) at:
```txt
00401180  JZ LAB_00401186
```
From `JZ` to `JMP` in order to force jump every time as it were equal.

After some loops we get the flag:
```txt
wgmy{b415d7261a3706c43ce852ceeab0e8ac}
```
**BUT**, when submitting it we get a wrong flag. Looks like there is an *anti-debugging* method here.

## Anti-debugging break
Normally the windows function `isDebuggerPresent` is used for detecting a debugger in a process, but this method
is not being called by this binary. I used another method to get the flag.

Looks like the anti-debugging is modifying some of the global variables used when transforming `local_7c` buffer
to get the correct flag. If the modification is happening **BEFORE** taking input we can take advantage of that by
*attaching* the debugger instead of spawning the process from the debugger.

The difference between *attaching* and *spawning* is that attaching will attach the debugger after the process has
started. Before attaching, the process is being run normally without a debugger so anti-debugging methods will not work.

The process:
1) Run the program without debugger. It should stop when calling `scan` to take input.
2) Attach the debugger and set a breakpoint in `_strncmp` to wait for the flag comparison.
3) Continue.
4) Patch the `JZ` instruction for easier analysis.

And wala, we get a different flag this time and it is correct:
```txt
wgmy{f533f9091fc3e8f63191c64cfe1c2157}
``` 

> Note that this method can be prevented by checking for the debugger after input, but maybe the anti-debugging
> is done before `main` even? not sure.


[Ghidra]: https://ghidra.re/
[x64dbg]: https://x64dbg.com/
