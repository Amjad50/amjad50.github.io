---
title: WGMY2024 - Reverse - Virtual Box
date: 2025-01-01T7:00:50+03:00
ShowToc: true
TocOpen: true
summary: VM Reverse Engineering Challenge
description: Writeup of the reverse engineering challenge "VirtualBox" in WGMY2024
keywords:
- writeup
- wgmy2024
- reverse engineering

tags:
- writeup
- wgmy2024
category:
- writeup
series:
- Wargames Malaysia 2024 writeups
series_weight: 0
---

We got executable `check.exe`, and its a very simple one. it just takes the `flag` as argument and checks it, outputting `Correct!` or `Incorrect!`.


## Initial Analysis

Performing analysis on the binary, we can find the `main` function at `140001C80`.

The first function `140002110` is interesting, it seems that its related to `onexit`/`desctructors`, we can know this by looking into it and seeing a call to `onexit` in `140001410`.

Anyway, after that, we check that we have `argc == 2` otherwise print the `Usage:` string.

In the main execution block.

It will init a new `state` struct of some kind at `140001540`, and allocate large buffers at `140001DC0`, currently, we don't know what these buffers are used for.

Then at `140001E10` we copy some payload into these `buffer` memory depending on the offset we specify the function
will choose either the first buffer or the second buffer.

Then we use the same `140001E10` function to copy the flag `1000` bytes after the initial payload. And we note the location and size of the flag into some of the `state` fields.

Then we are executing `140001590` in a loop until it returns `true`.

### Analyzing `140001590`

In this function, we notice first that we use `140001E80` to read a 4 byte integer value from the `buffer` using one of the unknown fields of the `state`, then this field is incremented by `4`.

The value read is then used by other functions.

But at this point, one thing we can think of is that this unknown value is some sort of pointer/counter that reads
from some memory and then execute the value we got from the memory. (Looking at `140001610` strengthen this belief, but we will look at it later).

At this point we can rename the unknown field to `pc` for example for `program counter`.


now going back to `main`, we notice that the value for `pc` is being initialized to `0x234` Which seems where
the `main` entry in the payload is.

### Analyzing `140001BB0`

Then, we have this function, which takes the new 4 byte integer and outputs some sort of `struct`, it does some bit shifting, etc... which seem like instruction decoding.

Decoding the instructions seems a bit complicated and is not a simple mapping.

But we can create a struct with unknown fields for now and then rename fields as we see fit later on.

We won't go too deep into this function for now, let's try to analyze the execution function at `140001610` first then fix these fields as they come.

### Analyzing `140001610` (execution)

When analyzing this function with the goal of trying to decode the values of the `struct`, we can notice that `field_0` is used as `int32[]` array, we don't know its size yet.

But this could be the registers of this VM/CPU. We notice that almost all instructions references this array, reading and writing from/to it.

Looking more closely at the values used to access this `registers` array, going back to `140001BB0`
we notice that these values are ANDed with `31` i.e. the range for these values is from `0` to `31`, giving us
`32` general registers.

### Understanding the instructions

With all of these information so far.
- instructions are fixed 32bit in size.
- it has 32 registers
- the opcode location is fixed in the decoding routine (top bits)

We can try to look for something matches these characteristics (you can ask AI to help you with this).

You will notice its similar to RISC-V, or MIPS architecture.

Because decoding is quite complex and not simple numbers it makes me believe its something not made for this challenge but is an emulation of an already existing CPU/Machine.


Trying some online disassemblers, it seems that the instructions fit `MIPS 32`, and they seem to make sense.

This is good, now we can make our analysis easier.

We can use `Ghidra` to analyze a binary dump as `MIPS 32 LE` program.

#### Analyzing the MIPS program

This is much easier now, running ghidra with the payload, and setting `0x234` as the entry point we see this function.


```C
undefined4 main(char *param_1, int param_2) {
  undefined4 uVar1;
  
  if (param_2 != 0x26) {
    syscall(0);
    return 3;
  }
  if ((((*param_1 == 'w') && (param_1[1] == 'g')) && (param_1[2] == 'm')) &&
     (((param_1[3] == 'y' && (param_1[4] == '{')) && (param_1[0x25] == '}')))) {
    uVar1 = FUN_00000000(param_1,0x7b,1);
    syscall(0);
    return uVar1;
  }
  syscall(0);
  return 4;
}
```

We can see that the parts `wgmy{}` are checked with `param_1` and length in `param_2`

If we return back to `main` in `check.exe`, the values of the address where the `flag` was copied is being
copied into `state->registers[4]` and the flag length into `state->registers[5]`.
When comparing that to `MIPS` reference we see it goes to registers `a0` and `a1` respectively, which matches the MIPS calling conventions for passing arguments into functions. This tells us more that this is indeed MIPS program being emulated.

After checking for `wgmy{}` and that the flag size is `38` characters we see a call to `FUN_00000000` and the result
being passed to `syscall`, looks like this `syscall` instruction is what terminates the emulation.

#### `FUN_00000000` inside MIPS payload

This function performs several operations to the values of the flag and compare them to some constants.

We can even notice the use of `fnv1a` hash (by usage of values `0x811c9dc5` and `0x1000193`).

Let's try to decode them one by one.

This is the whole function (a bit of a mess):
```C
bool FUN_00000000(byte *whole_flag) {
  byte bVar1;
  uint uVar2;
  byte *md5_part;
  byte *pbVar3;
  int iVar4;
  uint uVar5;
  int iVar6;
  int iVar7;

  md5_part = whole_flag + 5;
  pbVar3 = md5_part;
  while( true ) {
    bVar1 = *pbVar3;
    pbVar3 = pbVar3 + 1;
    if ((9 < bVar1 - 0x30) && (5 < bVar1 - 0x61)) break;
    if (pbVar3 == whole_flag + 0x20) {
      iVar4 = *(int *)(whole_flag + 5);
      uVar5 = *(uint *)(whole_flag + 9);
      iVar7 = *(int *)(whole_flag + 0xd);
      iVar6 = *(int *)(whole_flag + 0x11);
      uVar2 = 0x811c9dc5;
      do {
        bVar1 = *md5_part;
        md5_part = md5_part + 1;
        uVar2 = (bVar1 ^ uVar2) * 0x1000193;
      } while (md5_part != whole_flag + 0x15);
      do {
        pbVar3 = md5_part + 1;
        *md5_part = *md5_part ^ md5_part[-0x10];
        md5_part = pbVar3;
      } while (whole_flag + 0x25 != pbVar3);
      if ((((iVar4 * -0x19f1ce29 == 0x2f533dd5) &&
           ((uVar5 / 0x1a6b0 + 0x76741f54) * 0x26fec866 == -0x1c83668)) &&
          (iVar7 * 0xa55f6b3 == 0xcb2979f)) &&
         ((iVar6 + 0x9d9d0b86U < 0x881b && (uVar2 == 0x8a3b532e)))) {
        if ((*(int *)(whole_flag + 0x15) + *(int *)(whole_flag + 0x19) == -0x5ba55ea7) &&
           (*(int *)(whole_flag + 0x15) - *(int *)(whole_flag + 0x19) == -0x51ff57)) {
          if (*(int *)(whole_flag + 0x1d) + *(int *)(whole_flag + 0x21) == 0x57a20d60) {
            return *(int *)(whole_flag + 0x1d) - *(int *)(whole_flag + 0x21) == -0x52fffcb6;
          }
        }
      }
      return false;
    }
  }
  return (bool)5;
}
```

We notice several key points:
1- Computing `fnv1a` hash of the first 16 bytes only.
2- The second 16 bytes is XORed with the first 16 bytes
3- Several math computations done to both parts.

### Solution

We can solve these with Z3

Let's start with the first 16 bytes.

```python
from z3 import *

flag_bytes = [BitVec(f'flag_{i}', 8) for i in range(16)]

s = Solver()

for b in flag_bytes:
    s.add(Or(And(b >= ord('0'), b <= ord('9')),
                And(b >= ord('a'), b <= ord('f')),
                ))
        
# Create u32 variables from the bytes (little-endian)
dwords = [Concat(flag_bytes[i+3], flag_bytes[i+2], flag_bytes[i+1], flag_bytes[i]) for i in range(0, 16, 4)]


s.add(dwords[0] * 0xe60e31d7 == 0x2f533dd5)
s.add((dwords[1] / 0x1a6b0 + 0x76741f54) * 0x26fec866 == 0xfe37c998)
s.add(dwords[2] * 0xa55f6b3 == 0xcb2979f)
s.add(dwords[3] + 0x9d9d0b86 < 0x881b)

hash = BitVecVal(0x811c9dc5, 32)
for i in range(16):
    hash = hash ^ ZeroExt(24, flag_bytes[i])
    hash = (hash * 0x01000193) & 0xFFFFFFFF

s.add(hash == 0x8a3b532e)

if s.check() == sat:
    m = s.model()
    print(''.join([chr(m[b].as_long()) for b in flag_bytes]))
else:
    print('unsat')
```

Running it gets us `3011a45de10124cb`.

Then, if we use that to solve for the second part which is much easier (can be done by hand as well)

```python
from z3 import *

flag_partial = b'3011a45de10124cb'

flag_bytes = [BitVec(f'flag_{i}', 8) for i in range(16)]

s = Solver()

xored_bytes = [
    a ^ b for a, b in zip(flag_partial, flag_bytes)
]
dwords = [Concat(xored_bytes[i+3], xored_bytes[i+2], xored_bytes[i+1], xored_bytes[i]) for i in range(0, 16, 4)]

s.add(dwords[0] + dwords[1] == 0xa45aa159)
s.add(dwords[0] - dwords[1] == 0xffae00a9)
s.add(dwords[2] + dwords[3] == 0x57a20d60)
s.add(dwords[2] - dwords[3] == 0xad00034a)

if s.check() == sat:
    m = s.model()
    print(''.join([chr(m[b].as_long()) for b in flag_bytes]))
else:
    print('unsat')
```

We get `2a5c9dc609a39127`


Full flag is `wgmy{3011a45de10124cb2a5c9dc609a39127}`

> Note: I know that finding out that this is running MIPS makes it much easier than decoding each instruction manually, but that's part of the challenge. Trying to look for previous similar looking malware/samples that use the same technique.

