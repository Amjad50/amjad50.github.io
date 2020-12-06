---
title: WGMY2020 - RE - kmum
date: 2020-12-06T9:15:50+03:00
ShowToc: true
TocOpen: true
summary: Third reverse engineering challenge in WGMY2020
description: Writeup of the reversing challenge kmum in WGMY2020
keywords:
- writeup
- wgmy2020
- reverse engineering
- kernel

tags:
- writeup
- wgmy2020
category:
- writeup
series:
- Wargames Malaysia 2020 writeups
series_weight: 2
---

```txt
$ file *
app.exe:  PE32+ executable (console) x86-64, for MS Windows
kmum.sys: PE32+ executable (native) x86-64, for MS Windows
```

# Introduction
This time we are dealing with kernel drivers.

I'll be using [Ghidra] and [x64dbg] for static and dynamic analysis for this challenge.

> Note: It is advised to use kernel debugging, but I had some problems in my windows host
> so this solution is using static analysis and a small dynamic analysis (not kernel).

# Analysis
`kmum.sys` is the driver and `app.exe` mostly will load the driver and call into it.

## `app.exe` analysis
The `main` function is at `FUN_140001940`. And this time it looks like `C++` binary, nice.

The `main` starts by printing some strings and taking the input from the user, then
`FUN_140001070` is called.

### `FUN_140001070` analysis
The function starts by opening the driver *file* `"\\\\.\kmum"`, if it fails
it will first get the `.sys` file by calling `FUN_140001780` and installing
the driver from the service manager in the function `FUN_140001270`.

For `FUN_140001270` it calls it with **0** in the 3rd argument to stop it and with **1**
to start it again.

> I didn't talk much about `FUN_140001780` and `FUN_140001270` because they are just bunch of API calls
> and have some logging, so they are easy to understand from the code.

Going back to `main`, the most important part is:
```C
DeviceIoControl(DAT_1400067d8,0x222000,local_118,(DWORD)lVar6,local_128,1,local_124,
                (LPOVERLAPPED)0x0);
```
Looking at the [documentation for DeviceIoControl](https://docs.microsoft.com/en-us/windows/win32/api/ioapiset/nf-ioapiset-deviceiocontrol):
- `DAT_1400067d8` is a global reference to the driver file.
- `0x222000` is the `ioctl` code.
- `local_118` input buffer.
- `lVar6` length of input buffer.
- `local_128` output buffer.
- `1` max length of output buffer.
- `local_124` length returned for output.

Lastly, the output buffer should have the result of the flag check. Now let's go into the driver and see
how the flag check is made.


## `kmum.sys` analysis
> It's good to look at simple kernel driver examples, to see the similarities and to ease analysis.
> [here](https://www.codeproject.com/Articles/34067/Simple-WDM-LoopBack-Driver) is a good simple driver we will
> be referencing.

Drivers does not have `main` but have [DriverEntry] which should setup the driver.

When looking at `entry` in [Ghidra], two functions are being called `FUN_14000602c`
(which seems not important for analysis), and `FUN_140001000`, which takes the first argument from entry.
[Ghidra] didn't detect the second argument from [DriverEntry] because it is not used.

In `FUN_140001000` let's change the parameter type to `DRIVER_OBJECT`.

> Note: if you don't see `DRIVER_OBJECT` in [Ghidra] you can download data types archives from [here](https://github.com/NationalSecurityAgency/ghidra/tree/master/Ghidra/Features/Base/data/typeinfo/win32).

Here is the function:
```C
ulonglong FUN_140001000(DRIVER_OBJECT *param_1)
{
  uint local_48;
  ulonglong local_40;
  undefined8 local_38;
  undefined local_30 [16];
  undefined local_20 [32];
  
  local_38 = 0;
  DbgPrint("[*] DriverEntry Called.\n");
  RtlInitUnicodeString(local_30,L"\\Device\\kmum");
  RtlInitUnicodeString(local_20,L"\\??\\kmum");
  local_48 = IoCreateDevice(param_1,0,local_30,0x22,0x100,0,&local_38);
  if ((int)local_48 < 0) {
    DbgPrint("[*] There was some errors in creating device.\n");
  }
  else {
    local_40 = 0;
    while (local_40 < 0x1b) {
      *(code **)(param_1->MajorFunction + local_40) = FUN_140001190;
      local_40 = local_40 + 1;
    }
    param_1->MajorFunction[2] = (PDRIVER_DISPATCH)0x140001190;
    *(code **)param_1->MajorFunction = FUN_140001190;
    param_1->MajorFunction[0xe] = (PDRIVER_DISPATCH)0x1400011d0;
    *(code **)&param_1->DriverUnload = FUN_140001260;
    local_48 = IoCreateSymbolicLink(local_20,local_30);
    if ((int)local_48 < 0) {
      DbgPrint("Failed to create symbolic link (0x%08X)\n",(ulonglong)local_48);
      IoDeleteDevice(local_38);
    }
  }
  return (ulonglong)local_48;
}
```

First it creates the device using [IoCreateDevice], then it sets the handler functions.
Looks like `FUN_140001190` is being used as handler to all major functions except for
`DriverUnload` to `FUN_140001260`, and `MajorFunction[0xe]` to `FUN_1400011d0`.

The function for `0xe` is `IRP_MJ_DEVICE_CONTROL`, which matches what `app.exe` calls. (`DeviceIoControl`).
```C
#define IRP_MJ_DEVICE_CONTROL   0x0e
```

### `FUN_1400011d0` analysis
The function first calls `FUN_1400012b0`, which looks like [IoGetCurrentIrpStackLocation].

Then it checks the `ioctl` code:
```C
stack_io = (PIO_STACK_LOCATION)FUN_1400012b0(param_2);
if (*(int *)(stack_io->Parameters + 0x14) == 0x222000) {
uVar1 = FUN_140001810((longlong)param_2);
local_18 = (uint)uVar1;
}
```
[Ghidra] didn't manage to correctly figure out offsets because `IO_STACK_LOCATION` contains `unions`, and its hard to analyse.
So `stack_io->Parameters + 0x14` is `stack_io->Parameters.DeviceIoControl.IoControlCode`.

If the code is good it goes to `FUN_140001810` next:

### `FUN_140001810` analysis
Here is finally where the flag is checked.

First it checks input and output buffer sizes:
```C
if ((*(int *)(stack_io->Parameters + 0xc) == 0x26) && (*(int *)(stack_io->Parameters + 4) == 1))
```
Which are `Parameters.DeviceIoControl.OutputBufferLength` and `Parameters.DeviceIoControl.InputBufferLength` respectively.

First stage in checking is XORing and shifting the whole flag and checking for a result:
```C
xor_result = 0;
counter = 0;
while (counter < 0x26) {
    xor_result = xor_result ^ (int)input[counter] << (sbyte)((ulonglong)counter % 0x20);
    counter = counter + 1;
}
if (xor_result == 0xb2b07026)
```

If that passes, there is **3** more stages to go in functions:
`FUN_140001a90`, `FUN_1400015b0` and `FUN_1400019b0`.

#### `FUN_140001a90` analysis (stage 2)
The simplified function code:
```C
local_18 = 0x10;
do {
    switch(local_18) {
        case 0:
            if ((byte)(inp[0x1d] ^ inp[0x23] ^ inp[0x1e] ^ inp[0x1b]) == 0xb) {
                local_18 = 0x11;
            }
            else {
                local_18 = 3;
            }
            break;
        // ... trimmed   
        case 9:
            return 0;
        // ... trimmed
        case 0x10:
            if (inp[7] == inp[0x1a]) {
                local_18 = 0x16;
            }
            else {
                local_18 = 9;
            }
            break;
        // ... trimmed
        case 0x17:
            return 1;
        // ... trimmed
        case 0x20:
            // ... trimmed
            break;
    }
} while(true);
```
We can see that `local_18` is `state` and we should go through all checks and reach `state` **0x17**.

These are all checks:
```python
inp[7] == inp[0x1a]
inp[0x23] ^ inp[0x24] ^ inp[0x1f] ^ inp[0x22] == 1
inp[0x1a] ^ inp[0x24] ^ inp[0x23] ^ inp[0x15] == 0x51
inp[0x1f] ^ inp[0x16] ^ inp[0x17] ^ inp[0x1b] == 0x55
inp[0x1e] ^ inp[0x19] ^ inp[0x16] ^ inp[0x22] == 6
inp[0x15] ^ inp[0x1d] ^ inp[0x18] ^ inp[0x1a] == 7
inp[0x19] ^ inp[0x17] ^ inp[0x24] == 0x6c
inp[0x24] ^ inp[0x23] ^ inp[0x19] == 0x33
inp[0x1d] ^ inp[0x20] ^ inp[0x21] ^ inp[0x15] == 0x50
inp[0x19] ^ inp[0x1a] ^ inp[0x1e] ^ inp[0x22] == 6
inp[0x15] ^ inp[0x18] ^ inp[0x22] == 0x30
inp[0x1d] ^ inp[0x23] ^ inp[0x1e] ^ inp[0x1b] == 0xb
inp[0x22] ^ inp[0x20] ^ inp[0x17] ^ inp[0x1e] == 6
inp[0x21] ^ inp[0x17] ^ inp[0x1a] ^ inp[0x23] == 0x5f
inp[0x20] ^ inp[0x21] ^ inp[0x1e] == 0x62
inp[0x1b] ^ inp[0x1c] ^ inp[0x17] ^ inp[0x1e] == 2
```
#### `FUN_1400015b0` analysis (stage 3)
This is very similar to `FUN_140001a90` in terms of `state` logic, but its much simpler and straight forward,
these are the checks performed:
```
inp[0] = 0xc2 * -0x6b + -0x73
inp[1] = 0xf2 * -0x6b + -0x73
inp[2] = 0x60 * -0x6b + -0x73
inp[3] = 0x3c * -0x6b + -0x73
inp[4] = 0xb6 * -0x6b + -0x73
inp[0x25] = 0x30 * -0x6b + -0x73
```
Which is `"wgmy{}"` part. so this is not very interesting.

#### `FUN_1400019b0` analysis (stage 4)
```C
longlong FUN_1400019b0(char *inp)
{
  char cVar1;
  ulonglong uVar2;
  ulonglong uVar3;
  byte local_28;
  int counter;
  ulonglong local_10;
  
  local_10 = 0xf33df4c3c4feb33f;
  counter = 5;
  while( true ) {
    if (0x14 < counter) {
      return 1;
    }
    uVar2 = FUN_1400020e0(&local_10);
    uVar3 = FUN_1400020e0(&local_10);
    FUN_1400012d0((int)uVar2);
    local_28 = 0;
    while (local_28 < (byte)uVar3) {
      FUN_140001370();
      local_28 = local_28 + 1;
    }
    uVar2 = FUN_140001370();
    cVar1 = inp[counter];
    uVar2 = FUN_140002010((byte)uVar2 & 0xf);
    if (cVar1 != (char)uVar2) break;
    counter = counter + 1;
  }
  return 0;
}
```

`FUN_1400020e0`, `FUN_1400012d0`, `FUN_140001370`, and `FUN_140002010` all are complex **but** independant of the input, and that means
we can run debug this function and checks `uVar2` at the end for every loop.

> Now, this could be debugged using [windbg] in kernel mode, but I got into problems with my windows host, so I struggled in the beginning
> of how to debug this, but then I found the solution.

#### Debugging `FUN_1400019b0`
The good thing about this function and its internal functions is that it does not depend on the input or anything else in fact,
it just uses global variables to store data and do its computation. Which means we can just start execution from here by editing
the `RIP` (64bit Instruction Pointer) register.

When trying to start `kmum.sys` in [x64dbg] it does not work as it is a kernel driver and not a normal executable.

We can fix this issue by editing the `PE` header and fooling [x64dbg] into believing this is a normal `exe`.

##### Converting `sys` into `exe`
Looking in the [PE format], there is a byte to control the [subsystem] that this binary represent.
The driver has subsystem value of **1**, and the cli executable has value of **3**.

In our file here, the offset is at **0x134**, so we change that and we can run the driver now.

When running the driver, first we continue until we reach the entry breakpoint and immediately change
`$rip` to `xxxxxxxxxxxx19B0`.

After that since this function expects a buffer as argument in `rcx`. We can allocate memory from [x64dbg], put a
flag in there (example: `wgmy{aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa}`) and put the address in `rcx`.

Next, we continue until `xxxxxxxxxxxx1A70`:
```txt
140001a70  cmp ecx,eax
```
`eax` should have the correct character, for easier analysis we can patch the jump instruction after it to force
it to jump. It now jumps if they are equal. all we need is convert `jz` into `jmp`.
```txt
140001a72  jz LAB_140001a78
```

Then we just continue execution and record all **16** characters:
```txt
62a7075ff72176ad
```

## Solution
Now that we have all the pieces,
[stage 2](#fun_140001a90-analysis-stage-2), [stage 4](#fun_1400019b0-analysis-stage-4) and the xor thing.
We can solve them using [z3-solver][z3], which is a *theorem prover from Microsoft Research*.

I started by grouping all rules we collected and got this:
```python
from z3 import *

inp = [BitVec(f'x{i}', 32) for i in range(0x26)]

xor_thing = BitVec('xor', 32)

s = Solver()

for (i, inpp) in enumerate(inp):
    xor_thing = xor_thing ^ (inpp << (i % 0x20))

    # because it a byte
    s.add(inpp >= 0)
    s.add(inpp <= 0xFF)

# stage 1
s.add(xor_thing == 0xb2b07026)

# stage 2
s.add(inp[7] == inp[0x1a])
s.add(inp[0x23] ^ inp[0x24] ^ inp[0x1f] ^ inp[0x22] == 1)
s.add(inp[0x1a] ^ inp[0x24] ^ inp[0x23] ^ inp[0x15] == 0x51)
s.add(inp[0x1f] ^ inp[0x16] ^ inp[0x17] ^ inp[0x1b] == 0x55)
s.add(inp[0x1e] ^ inp[0x19] ^ inp[0x16] ^ inp[0x22] == 6)
s.add(inp[0x15] ^ inp[0x1d] ^ inp[0x18] ^ inp[0x1a] == 7)
s.add(inp[0x19] ^ inp[0x17] ^ inp[0x24] == 0x6c)
s.add(inp[0x24] ^ inp[0x23] ^ inp[0x19] == 0x33)
s.add(inp[0x1d] ^ inp[0x20] ^ inp[0x21] ^ inp[0x15] == 0x50)
s.add(inp[0x19] ^ inp[0x1a] ^ inp[0x1e] ^ inp[0x22] == 6)
s.add(inp[0x15] ^ inp[0x18] ^ inp[0x22] == 0x30)
s.add(inp[0x1d] ^ inp[0x23] ^ inp[0x1e] ^ inp[0x1b] == 0xb)
s.add(inp[0x22] ^ inp[0x20] ^ inp[0x17] ^ inp[0x1e] == 6)
s.add(inp[0x21] ^ inp[0x17] ^ inp[0x1a] ^ inp[0x23] == 0x5f)
s.add(inp[0x20] ^ inp[0x21] ^ inp[0x1e] == 0x62)
s.add(inp[0x1b] ^ inp[0x1c] ^ inp[0x17] ^ inp[0x1e] == 2)

# stage 3
s.add(inp[0] == (0xc2 * -0x6b + -0x73) & 0xFF)
s.add(inp[1] == (0xf2 * -0x6b + -0x73) & 0xFF)
s.add(inp[2] == (0x60 * -0x6b + -0x73) & 0xFF)
s.add(inp[3] == (0x3c * -0x6b + -0x73) & 0xFF)
s.add(inp[4] == (0xb6 * -0x6b + -0x73) & 0xFF)
s.add(inp[0x25] == (0x30 * -0x6b + -0x73) & 0xFF)

# stage 4
for (i, c) in enumerate('62a7075ff72176ad'):
    s.add(inp[i + 5] == ord(c))

print(s.check())

m = s.model()
print([m[inpp] for inpp in inp])

# this converts the int array to encoded string using a weird method,
# this is due to not able to convert from BitVec into integer, BitVec is just
# a reference
print(bytes(eval(str([m[inpp] for inpp in inp]))))
```
> Note: the reason we used `BitVec(f'x{i}', 32)` for each character instead of **8**, is that `BitVec` of **8**
> bits in size cannot be shifted and converted into **32** bit.

**BUT**, this gave us:
```txt
wgmy{62a7075ff72176ad+afx(a+c5,y/ac9"}
```

And that means the constrains are not enough, so I thought of making the inside only in `0-9a-f`.

```python
# only hex characters
if i >= 5 and i <= 0x24:
    s.add(Or(And(inpp >= 0x30, inpp <= 0x39), And(inpp <= 0x66, inpp >= 0x61)))
```
This replaces:
```python
# because it a byte
s.add(inpp >= 0)
s.add(inpp <= 0xFF)
```

And we got the flag:
```txt
wgmy{62a7075ff72176ad1afb2a1c56c5ac98}
```

[Ghidra]: https://ghidra.re/
[x64dbg]: https://x64dbg.com/
[windbg]: https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/debugger-download-tools
[DriverEntry]: https://docs.microsoft.com/en-us/windows-hardware/drivers/wdf/driverentry-for-kmdf-drivers
[IoCreateDevice]: https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-iocreatedevice
[IoGetCurrentIrpStackLocation]: https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-iogetcurrentirpstacklocation
[PE format]: https://docs.microsoft.com/en-us/windows/win32/debug/pe-format
[subsystem]: https://docs.microsoft.com/en-us/windows/win32/debug/pe-format#windows-subsystem
[z3]: https://github.com/Z3Prover/z3
