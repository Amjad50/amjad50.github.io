---
title: WGMY2020 - Forensic - Lord Kiske's Server
date: 2020-12-07T9:10:50+03:00
ShowToc: true
TocOpen: true
summary: Many forensic related challenges grouped into one writeup
description: Writeup of the forensics challenges in WGMY2020
keywords:
- writeup
- wgmy2020
- forensics

tags:
- writeup
- wgmy2020
category:
- writeup
series:
- Wargames Malaysia 2020 writeups
series_weight: 7
author: Mohammed Ba Batraf
---

> Note: this writeup contains all **Forensic - Lord Kiske's Server** challenges solutions

# Introduction

The forensic challenges in this CTF are all inside a ubuntu VM called Lord Kiske's Server so the first challenge was to download the VM and perform SHA256 for OVA file that was downloaded.

![Introduction](Introduction%20ad65b0a997364caa81e4864364e7500d/Untitled.png)

To perform SHA256 we used the command

```bash
$ sha256sum lordkiske\ server.ova
```

![sha256 output](Introduction%20ad65b0a997364caa81e4864364e7500d/Untitled%201.png)

which gave us the hash that we wrapped inside the flag format to get the flag

```txt
wgmy{c4ea7f5c3a23990844ea6518c02740c66c4c8a605314f3bd9038f7ebfa7b9911}
```

# [Analysis] Attacker's IP Address

![%5BAnalysis%5D%20Attacker's%20IP%20Address%204e6c4f13e298414facb3c98c2d50dc2a/Untitled.png](%5BAnalysis%5D%20Attacker's%20IP%20Address%204e6c4f13e298414facb3c98c2d50dc2a/Untitled.png)

For the second challenge we were required to find the attacker's IP. I started by investigating the server and check what's inside. I found a Wordpress website inside the folder of the apache server (**/var/www/html**). When I opened the **index.html** file I found this message from the attacker.

![%5BAnalysis%5D%20Attacker's%20IP%20Address%204e6c4f13e298414facb3c98c2d50dc2a/Untitled%201.png](%5BAnalysis%5D%20Attacker's%20IP%20Address%204e6c4f13e298414facb3c98c2d50dc2a/Untitled%201.png)

So I decided to look into the apache access log file that is found in (**/var/log/apache2/access.log**). After looking through the log files I noticed that many IPs were unsuccessfully trying to do malicious activities, but one IP was doing many successful interactions with a suspicious file inside the server called **we.php.**  

![%5BAnalysis%5D%20Attacker's%20IP%20Address%204e6c4f13e298414facb3c98c2d50dc2a/Untitled%202.png](%5BAnalysis%5D%20Attacker's%20IP%20Address%204e6c4f13e298414facb3c98c2d50dc2a/Untitled%202.png)

So I decided to go and check what this file is. I checked the content of the file using **nano we.php**

![%5BAnalysis%5D%20Attacker's%20IP%20Address%204e6c4f13e298414facb3c98c2d50dc2a/Untitled%203.png](%5BAnalysis%5D%20Attacker's%20IP%20Address%204e6c4f13e298414facb3c98c2d50dc2a/Untitled%203.png)

From this file we can assume that it's the shell. I took the ip address of the attacker and used the command 

```bash
echo -n "178.128.31.78" | md5sum
```

![%5BAnalysis%5D%20Attacker's%20IP%20Address%204e6c4f13e298414facb3c98c2d50dc2a/Untitled%204.png](%5BAnalysis%5D%20Attacker's%20IP%20Address%204e6c4f13e298414facb3c98c2d50dc2a/Untitled%204.png)

I wrapped this hash inside the flag format and got the flag

```txt
wgmy{0941b6865b5c056c3bbb0825e1beb8e9}
```

# [Analysis] Hash of Webshell

![%5BAnalysis%5D%20Hash%20of%20Webshell%20c25c458806ff41e28804afa729a69658/Untitled.png](%5BAnalysis%5D%20Hash%20of%20Webshell%20c25c458806ff41e28804afa729a69658/Untitled.png)

From the previous question we have discovered that the file **we.php** is the shell. We used the command 

```bash
sha1sum we.php
```

![%5BAnalysis%5D%20Hash%20of%20Webshell%20c25c458806ff41e28804afa729a69658/Untitled%201.png](%5BAnalysis%5D%20Hash%20of%20Webshell%20c25c458806ff41e28804afa729a69658/Untitled%201.png)

After wrapping it between the flag format we found the flag

```txt
wgmy{7b4a2cef84aee4d3fd4762ec52fa41c8e9c05fe8}
```

# [Analysis] Path of Webshell

![%5BAnalysis%5D%20Path%20of%20Webshell%207de4af1281a34ac089615b0bb0b649b4/Untitled.png](%5BAnalysis%5D%20Path%20of%20Webshell%207de4af1281a34ac089615b0bb0b649b4/Untitled.png)

From the previous questions we found out that the shell is **we.php** which is located at (**/var/www/html/wp-content-uploads/we.php**) We used the command to get the MD5 hash

```bash
echo -n /var/www/html/wp-content/uploads/we.php | md5sum
```

![%5BAnalysis%5D%20Path%20of%20Webshell%207de4af1281a34ac089615b0bb0b649b4/Untitled%201.png](%5BAnalysis%5D%20Path%20of%20Webshell%207de4af1281a34ac089615b0bb0b649b4/Untitled%201.png)

So the flag is 

```txt
wgmy{cc93f2436a9fdc6f19c1fa8bd865f8f3}
```

# [Analysis] Hash of Ransomware

![%5BAnalysis%5D%20Hash%20of%20Ransomware%208b00f484a6844e3398a02d57105c9a3b/Untitled.png](%5BAnalysis%5D%20Hash%20of%20Ransomware%208b00f484a6844e3398a02d57105c9a3b/Untitled.png)

After finding the websell, I continued investigating the **uploads** directory and I found a file called b404.php. 

![%5BAnalysis%5D%20Hash%20of%20Ransomware%208b00f484a6844e3398a02d57105c9a3b/Untitled%201.png](%5BAnalysis%5D%20Hash%20of%20Ransomware%208b00f484a6844e3398a02d57105c9a3b/Untitled%201.png)

I changed the from `eval()` to `file_put_contents()` so that the function `base64_decode` outputs to a file called **new.php**.

![%5BAnalysis%5D%20Hash%20of%20Ransomware%208b00f484a6844e3398a02d57105c9a3b/Untitled%202.png](%5BAnalysis%5D%20Hash%20of%20Ransomware%208b00f484a6844e3398a02d57105c9a3b/Untitled%202.png)

We can see here that this file is the ransomware that encrypts the files. Therefore, I hashed the file **b404.php** using the command

```bash
sha1sum b404.php
```

![%5BAnalysis%5D%20Hash%20of%20Ransomware%208b00f484a6844e3398a02d57105c9a3b/Untitled%203.png](%5BAnalysis%5D%20Hash%20of%20Ransomware%208b00f484a6844e3398a02d57105c9a3b/Untitled%203.png)

After wrapping the hash inside the flag format I got the flag which is

```txt
wgmy{00a3db9f4a4534a82deee9e7a0ca6a67d0deada3}
```

# [Analysis] Location of Ransomware

![%5BAnalysis%5D%20Location%20of%20Ransomware%20f93d8e5c7e6c42569164d544354ccffc/Untitled.png](%5BAnalysis%5D%20Location%20of%20Ransomware%20f93d8e5c7e6c42569164d544354ccffc/Untitled.png)

From the previous challenge we knew that the ransomware is the file **b404.php** that is at the directory (**/var/www/html/wp-content/uploads**). So using the command

```bash
echo -n "/var/www/html/wp-content/uploads | md5sum
```

We could get the MD5 has

![%5BAnalysis%5D%20Location%20of%20Ransomware%20f93d8e5c7e6c42569164d544354ccffc/Untitled%201.png](%5BAnalysis%5D%20Location%20of%20Ransomware%20f93d8e5c7e6c42569164d544354ccffc/Untitled%201.png)

That is how we got the flag which is 

```txt
wgmy{86051201744543abeda8b8efd0933e98}
```

# [Analysis] CnC Hostname

![%5BAnalysis%5D%20CnC%20Hostname%20177020293843407e954421ffde63e12d/Untitled.png](%5BAnalysis%5D%20CnC%20Hostname%20177020293843407e954421ffde63e12d/Untitled.png)

When we look into the code of the ransomware after decoding it from base64 we can see that all the malicious activities happen through a communication with the CnC Hostname which is [musangkeng.wargames.my](http://musangkeng.wargames.my).

![%5BAnalysis%5D%20CnC%20Hostname%20177020293843407e954421ffde63e12d/Untitled%201.png](%5BAnalysis%5D%20CnC%20Hostname%20177020293843407e954421ffde63e12d/Untitled%201.png)

So we hashed this hostname using the command

```bash
echo -n "musangkeng.wargames.my" | md5sum
```

To get the following MD5 hash

![%5BAnalysis%5D%20CnC%20Hostname%20177020293843407e954421ffde63e12d/Untitled%202.png](%5BAnalysis%5D%20CnC%20Hostname%20177020293843407e954421ffde63e12d/Untitled%202.png)

I got the flag by wrapping the hash between the flag format

```txt
wgmy{d7357e55e21847601d4eacb01fe13313}
```

# [Analysis] Exploit Used

![%5BAnalysis%5D%20Exploit%20Used%20a1dfd97559014f55b8fd4083cbe9c163/Untitled.png](%5BAnalysis%5D%20Exploit%20Used%20a1dfd97559014f55b8fd4083cbe9c163/Untitled.png)

From the previous challenges we could see that the webshell and ransomware are inside the uploads directory so I assumed that the vulnerability was something related to uploading files so I went back to check the server logs especially before the attacker sent the first request to we.php which is the webshell. After a thorough investigations into the file, I found that there was an interaction between the attacker and upload handler of the plugin (**ait-csv-import-export**) immediately before the first request to we.php. I suspected that this was the vulnerability and I searched on google about any vulnerability related to this plugin. 

![%5BAnalysis%5D%20Exploit%20Used%20a1dfd97559014f55b8fd4083cbe9c163/Untitled%201.png](%5BAnalysis%5D%20Exploit%20Used%20a1dfd97559014f55b8fd4083cbe9c163/Untitled%201.png)

This led me to a vulnerability that was published in **WPScan** on **13/11/2020** [https://wpscan.com/vulnerability/10471](https://wpscan.com/vulnerability/10471) . The id was **10471**. I've put the id in the proper format and hashed it using the command

```bash
echo -n "wpvdbid10471" | md5sum
```

That gave me the hash in the following image

![%5BAnalysis%5D%20Exploit%20Used%20a1dfd97559014f55b8fd4083cbe9c163/Untitled%202.png](%5BAnalysis%5D%20Exploit%20Used%20a1dfd97559014f55b8fd4083cbe9c163/Untitled%202.png)

Therefore, the flag is 

```txt
wgmy{6e9478a4c77c8abfe5d6364010e4961e}
```

# [Analysis] Restoration of the Lord Kiske's server

![%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled.png](%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled.png)

This challenge asks us to decrypt the file so I went to take a closer look on the ransomware and the steps it takes to decrypt the data.

The file provided is `flag.txt.durian` and it has the content:

```txt
$ cat flag.txt.durian
YjJicGtyZGdFUW4xYVFPQ2pqOEZHTWFmemQ3NlIxTFNkTWpGQXhKd0ZaUjlFTGtvblpHWGdSZXE0Q0U1NHN1eg==
```

## Finding the key

![%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%201.png](%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%201.png)

We can see in this code snippet that the code gets the **$key** by sending a **$data** which
is an array containing **$HTTP_HOST** and **current epoch time** (when the request was sent)
to a generator in the CnC server. 

![%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%202.png](%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%202.png)

From this code snippet we can see that the **$HTTP_HOST** is taken from the parameter "**host**" in the get request so I went to check the apache logs to check this parameter and time of the first request sent to the ransomware.

![%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%203.png](%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%203.png)

We can see here that the **$HTTP_HOST** is [lordkiske.wargames.my](http://lordkiske.wargames.my). Also, the time of the request was **03/DEC/2020:19:11:58** so the time of encrypting the file in the question could be anytime between **03/DEC/2020:19:11:58** to **05/DEC/2020** (the day of the event). I started by converting it to epoch time 

![%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%204.png](%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%204.png)

But then the organizers sent a hint that the request happened on 4th of December, which would decrease the search
space. 

![%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%205.png](%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%205.png)

Therefore, I calculated the epoch time again of the first second in 4th of December until the last second in the 4th of December

![%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%206.png](%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%206.png)

![%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%207.png](%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%207.png)

## Finding the IV

Also, from the request we could see the **HTTP_USER_AGENT** 

![%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%208.png](%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%208.png)

So I copied the part of the code that calculates the **$iv**

![%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%209.png](%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%209.png)

and when we run this script we can find that 

```php
$iv = "313dcdceb5f4b075d0980863c498ce4c66084888"
```

## Checking the decryption of the file

We could see from the ransomware code that the function that is responsible for encrypting  the files is `makan()` which takes the **$key** and **$iv** then call another function with those parameters called `enc()`

![%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%2010.png](%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%2010.png)

![%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%2011.png](%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%2011.png)

So I created another script that reverse these processes.

```php
<?php
function enc($string, $secret_key, $secret_iv)
{
    $encrypt_method = "AES-256-CBC";
    $key = hash('sha256', $secret_key);
    $iv = substr(hash('sha256', $secret_iv) , 0, 16);

    $after_decode = base64_decode($string);
    return openssl_decrypt($after_decode, $encrypt_method, $key, 0, $iv);
}
function httpreq($url, $postVars)
{

    $postStr = http_build_query($postVars);

    $options = ['http' => ['method' => 'POST', 'header' => 'Content-type: application/x-www-form-urlencoded', 'content' => $postStr]];

    $streamContext = stream_context_create($options);
    $res = file_get_contents($url, false, $streamContext);
    return $res;
}
function main()
{

    $length = 0;
    $time = 1607040000;
    while ($time <= 1607126422)
    {
        echo ".";
        $data = ['host' => 'lordkiske.wargames.my', 'time' => $time, ];
        $data['hash'] = md5(serialize($data));

        $key = httpreq("http://musangkeng.wargames.my/gen.php", $data);

        $iv = "313dcdceb5f4b075d0980863c498ce4c66084888";

        $answer = enc("YjJicGtyZGdFUW4xYVFPQ2pqOEZHTWFmemQ3NlIxTFNkTWpGQXhKd0ZaUjlFTGtvblpHWGdSZXE0Q0U1NHN1eg==", $key, $iv);

        $length = strlen($answer);

        if ($length != 0)
        {
            echo $time;
            echo "\n";
            echo $answer;
        }

        $time++;
    }
    
    echo "search ended";
}

main();
?>
```

Since we can't know the **\$key** exactly because we don't know the exact time when **flag.txt** was encrypted so I made a while loop that loops through all the seconds from the first second in 4th of December until the last second. In each iteration, I tried to decrypt the content of **flag.txt** using a reversed form of the function `enc()` and if the string's length is not **0** I printed the **\$time** and **$answer** which is the string after decryption. I waited for the code to run and I was checking if I got any meaningful string from the decryption method. Until, I finally got the flag after so long.

![%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%2012.png](%5BAnalysis%5D%20Restoration%20of%20the%20Lord%20Kiske's%20server%208bafa1a8e94542b4a76a0e4707ff8430/Untitled%2012.png)

**Flag:**
```txt
wgmy{9ed95e1721c3aab37bd7c67496f868a2}
```