---
title: WGMY2020 - Mobile - SpeedyQuizy
date: 2020-12-06T11:30:50+03:00
ShowToc: true
TocOpen: true
summary: Android mobile app reverse engineering challenge
description: Writeup of the mobile challenge SpeedyQuizy in WGMY2020
keywords:
- writeup
- wgmy2020
- android
- reverse engineering

tags:
- writeup
- wgmy2020
category:
- writeup
series:
- Wargames Malaysia 2020 writeups
series_weight: 3
---

```txt
$ file *
SpeedyQuizy.apk: Zip archive data, at least v0.0 to extract
```

# Introduction
This is an android mobile application file `apk`. We can use [jadx] to easily analyze the code.

# Analysis
The main package is `com.example.speedyquizy`. The `MainActivity` is empty and just starts the `StartQuiz` activity, so we will
focus on it.

All `StartQuiz` is doing is setting up a connection to `www2.wargames.my:8080`, receives from the server
and forward it to the UI, and receives input from the user and sends it back to the server. So actually we will stop android reversing
because this is all there is to it and focus on `www2.wargames.my:8080` inner workings.

## The quiz server
When connecting to `www2.wargames.my:8080` we get:

```txt
[2020-12-06 04:44:41pm] You are to answer 3 question in 4 seconds.
Any incorrect attempt will require you to start again.
If not sure, just answer in small letter.

Type 'ok' to proceed, or 'quit' to end
```
We can also see in the app that it sends `ok` automatically if it detects this message, doing so:
```txt
[2020-12-06 04:45:45pm] Question No 1
> Divide 35772 with 18137. Round to the nearest whole number.
```

Let's answer anything:
```txt
999

[2020-12-06 04:45:49pm] You answered 999 for question no 1
INCORRECT!

Please try again. Closing connection.
```

So we need to build a script that solves questions for us fast.

Running it multiple times, we can get collection of questions:
```txt
> Biggest port number possible
> Reverse of doof is ...
> Given 98249 - 71052 = x and y=2+x. Find y.
> Multiply 51243 and 7036.
> Can you add 81837 to 75642?
> DNS zone transfer occurs on port 53. (Of course you know that). But, it is TCP or UDP?
...
```

There are two types of questions, math and not math. For math questions they involve random numbers, so
if you got `Multiply....` question the numbers will be different, but for non math questions they are always the same,
like `DNS zone transfer...`.

# Solution
We can build a small python script to solve it for us

```python
import socket
import re

HOST = 'www2.wargames.my'
PORT = 8080

# map to store all solutions got from the user until now
solutions = {}

# tries to find questions that contain randomness and solves them
# Note: the code is not the best, but works
def try_solve(data):
    s = re.findall(b'Multiply (\d*) and (\d*)', data)
    if s:
        s = s[0]
        return int(s[0]) * int(s[1])
    s = re.findall(b'Given (\d*) - (\d*)', data)
    if s:
        s = s[0]
        return int(s[0]) - int(s[1]) + 2

    s = re.findall(b'Can you add (\d*) to (\d*)', data)
    if s:
        s = s[0]
        return int(s[0]) + int(s[1])

    s = re.findall(b'Divide (\d*) with (\d*)', data)
    if s:
        s = s[0]
        return round(int(s[0]) / int(s[1]))

    return None

def process(s):
    while True:
        # recive from the server
        data = s.recv(1024)
        # split into lines, as sometimes half of it is received
        for line in data.split(b'\n'):
            # print for debugging
            print(line)
            # if its empty, ignore this line and go to the next line
            if not line:
                continue

            # if we are starting, send `ok`
            if b'to proceed' in line:
                s.sendall(b'ok')

            # if the connection is closing, return and connect again
            elif b'Closing' in line:
                return

            # if the connection is closing, return and connect again
            elif b'faster' in line:
                return
                
            # This is a question line
            elif line[0] == b'>'[0]:
                # Try to solve it using the smart way
                d = try_solve(line)
                # If there is a solution send it
                if d:
                    s.sendall(str(d).encode())
                    continue

                # If we have a previously recorded solution from the user, use it
                if line in solutions:
                    print("found in solutions")
                    s.sendall(solutions[line])
                else:
                    # ask the user for a solution
                    r = input().encode()
                    # record it and send it
                    solutions[line] = r
                    try:
                        s.sendall(r)
                    except:
                        # the server shutdown on us
                        break

while True:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((HOST, PORT))
        process(s)
```

Using this script, some questions I have to solve manually, but they will be saved if they came in the future,
after some tries we get the flag:
```txt
wgmy{418b3ea849ff3b93def86cfbc90440c1}
```

[jadx]: https://github.com/skylot/jadx
