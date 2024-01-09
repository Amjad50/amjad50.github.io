---
title: WGMY2023 - Forensics - can't snoop
date: 2024-01-07T7:00:50+03:00
ShowToc: true
TocOpen: true
summary: Network forensics challenge
description: Writeup of the forensics challenge "can't snoop" in WGMY2023
keywords:
- writeup
- wgmy2023
- forensics

tags:
- writeup
- wgmy2023
category:
- writeup
series:
- Wargames Malaysia 2023 writeups
series_weight: 0
---

### Challenge files

If you want to attempt the challenge, here are two files you can use:
- [notclean.pcapng]: This is the original file used in the CTF and contain a lot of noise
- [clean.pcapng]: This is just the interesting parts of the original file, so you can focus on the interesting parts, But the key and random values are different than this writeup.

This writeup is based on the [notclean.pcapng] file.


### Communication
We notice some sort of communication between server and client when trying to look for interesting communication.
Since there is a lot of noise, so we need to filter out the noise.

The interesting parts start with TCP stream 12, its as such:

> I have mixed some hex between `<>` so its easier to see the ascii characters


client: `HLO <00 00 00 00>`<br>
server: `HLO <00 00 03 eb>`

Then,<br>
client: `EX1 <00 00 03 eb   00 00 00 0c> K3=RC4(K,K2)`<br>
server: `EX2 <00 00 03 eb   00 00 00 20   85 2a 94 8d 19 69 b0 3f 4b 72 ea d7 88 20 bf 64 75 58 f9 46 cc 94 9e f7 97 63 0d b9 85 4f 08 6f>`

We see something interesting, there is this prefix that is added to all packets after `HLO` which is here `00 00 03 eb`.
Since it comes from the server after `HLO`, it would seem its a `client_id` or something similar. 

Then we see for the last 2 packets, 4bytes integer denoting length of some data and then `n` number of bytes which is the data.
In the first packet its `K3=RC4(K,K2)` which probably refer to something related to `RC4` encryption, lets see if we can use it later

Then we have from the server `0x20 (32)` bytes, could it be the key?

`85 2a 94 8d 19 69 b0 3f 4b 72 ea d7 88 20 bf 64 75 58 f9 46 cc 94 9e f7 97 63 0d b9 85 4f 08 6f`

Next,<br>
client: `EX3 00 00 03 eb   00 00 00 1e   f6 14 52 c2 39 5c 2f 6a a3 17 fc 7a 6b 27 19 6e 90 83 a1 67 27 cb 81 05 14 99 53 08 50 86`<br>
server: `EX3 00 00 03 eb   00 00 00 02   27 d3`

And here, we get another `0x1E (30)` bytes.

#### Getting the key

> Maybe this here is a bit guessy, I got some words from participants on this part. So could have been improved to be less guessy.

We can use the 2 large byte arrays along with the informer on `RC4` and the names `EX1`..`EX3` to refere to `key exchange`.

We have the interesting equation in the top `K3=RC4(K,K2)` If we map the `EX` to `K` prefixes, then we can understand that this is probably how it works.

```python
K3 = bytes.fromhex('f6 14 52 c2 39 5c 2f 6a a3 17 fc 7a 6b 27 19 6e 90 83 a1 67 27 cb 81 05 14 99 53 08 50 86')
K2 = bytes.fromhex('85 2a 94 8d 19 69 b0 3f 4b 72 ea d7 88 20 bf 64 75 58 f9 46 cc 94 9e f7 97 63 0d b9 85 4f 08 6f')
K = RC4(K3, K2) # RC4(data, key)
```
Then, the `K` is used for future encryption/decryption of data.

Here is a link to get the final `K`: [GettingKey]

Here, if we use the final key we get `69 ff 76 8b 77 b9 b1 c6 fb 0c 09 00 56 e4 90 c0 cb 97 7d 25 78 b0 16 d6 04 04 15 1d 78 76` and encrypted the 2 bytes data `27 d3` we get the string `OK`, which seems promising.

### Understanding the protocol
Then continuing on the same way, we understand the general format of the packets now:
```
packet {
    char[3]         cmd;
    u32             session_id;
    u32             param_len;
    char[param_len] param;  // dynamic based on `param_len`              
}
```
Here `param` will be encrypted always with the `K` value we got from previous.


### Getting the flag
If you continue using the same key with next commands you notice `LST` is used to list files in the directory requested, and `GET` is used to get the file requested.

After some commands, we see `GET` used with `flag.txt`, and the result is (after decryption)
`wgmy{df07e73edae297a5edc637c41a119de5}`

We can use this cyberchef recipe to get the flag:
[Solution]

[notclean.pcapng]: challenge_files/notclean.pcapng
[clean.pcapng]: challenge_files/clean.pcapng

[GettingKey]: https://cyberchef.org/#recipe=From_Hex('Auto')RC4(%7B'option':'Hex','string':'85%202a%2094%208d%2019%2069%20b0%203f%204b%2072%20ea%20d7%2088%2020%20bf%2064%2075%2058%20f9%2046%20cc%2094%209e%20f7%2097%2063%200d%20b9%2085%204f%2008%206f'%7D,'Latin1','Latin1')To_Hex('Space',0)&input=ZjYgMTQgNTIgYzIgMzkgNWMgMmYgNmEgYTMgMTcgZmMgN2EgNmIgMjcgMTkgNmUgOTAgODMgYTEgNjcgMjcgY2IgODEgMDUgMTQgOTkgNTMgMDggNTAgODY
[Solution]: https://cyberchef.org/#recipe=From_Hex('Auto')RC4(%7B'option':'Hex','string':'69%20ff%2076%208b%2077%20b9%20b1%20c6%20fb%200c%2009%2000%2056%20e4%2090%20c0%20cb%2097%207d%2025%2078%20b0%2016%20d6%2004%2004%2015%201d%2078%2076'%7D,'Latin1','Latin1')&input=MWYgZmYgMmYgNTAgMDYgOWMgMDggYzcgOGEgY2MgMDQgYzcgYzMgOGQgMjYgZjYgM2IgYjIgZjkgZjAgYzYgMTIgMDUgZTUgNzQgZGIgYmMgNzkgNjcgNzcgZTEgNTAgMzggYjIgNjYgZjAgM2UgZmQgNzg




