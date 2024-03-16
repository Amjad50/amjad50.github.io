--- 
title: Projects
layout: single
TocOpen: true
description: All projects I worked on or been part of in all my experiences.
showReadingTime: false
editPost:
    disabled: true
---

I have been involved with many projects, mainly in 2 categories:
- Software projects: See them at [Open source projects](#open-source-projects) and [Work projects](#software-development).
- Malware analysis and reverse engineering: See them at [Malware analysis and reverse engineering](#malware-analysis-and-reverse-engineering).

# Open source projects

### [Plastic]

**NES emulator** in Rust, with high performance and accuracy, can play any NES game.
Got it to work on android through `ffi` with **flutter** which was interesting journey.

### [Mizu]

**GB emulator** focusing on accuracy, performed better than some popular emulators on tests, 
This has less UI support than [Plastic] done by me, but the API is very easy to use and can
be embedded anywhere since the core emulation is a developed in a library style.

### [Trapezoid]

**PSX emulator**, still in progress and doesn't play everything yet, but still plays a lot of games
and has all the features including *GPU*, *MDEC* and *sound*, only missing some bug fixes here and there. 
This got me into GPU programming since I was using `Vulkan` as a backend renderer, I was using [vulkano],
and also got some PRs merged into it to fix some issues.

### [Emerald]

This is an Operating system from scratch written in Rust, the goal is to learn about OS internals and try
interesting new designs for them. Currently, it has several drivers for disk, keyboard, mouse, graphics, ...

Now we can create simple GUI applications, and we have a simple shell that can run commands and programs.

### [Dynwave]

Audio player library for real-time streaming audio with auto resampling.

This is an audio player library that can play audio stream cross platform very fast, and also would auto resample
if the sample rate of the input is not supported natively by the system.

This is used in my emluators such as [Mizu] and [Trapesoid] to play audio.

### [Blinkcast]

A library that provide Fast, Lock-free, Bounded, Lossy Rust broadcast channel/ring buffer with `no_std` support.

This is used in my Operating system [Emerald] to communicate between the kernel and the user space in
some components such as the keyboard and mouse driver.

It allows fast communication between the kernel and all user space processes that are interested in the events.

### [ul-next]

Rust bindings for [Ultralight]: Lightweight, high-performance HTML renderer.

This project relies heavily of course on `ffi` and good handling of external resources and using `unsafe`.

The project also featured a custom driver that will render the page using the GPU, its implemented in [glium].

## Contributions to Open source projects

I have done many contributions to open source projects, some of the notable ones are:
| Project | Description |
| ---- | ----------- |
| [glium] | Safe OpenGL wrapper for the Rust language |
| [vulkano] | Safe and rich Rust wrapper around the Vulkan API |
| [rust-lang/rust] | The Rust programming language compiler |
| [tock] | A secure embedded operating system for microcontrollers |
| [CAPEv2] | Malware Configuration And Payload Extraction framework |

# Work projects

Here are some of the projects I worked on in my work experiences, I can't share much details about them
but I can give a brief overview of what I did in them.

## Malware analysis and reverse engineering

I have worked on analyzing several malware families and documenting their behavior and capabilities, some of
these families include:

- *[QBot]*: Banking trojan.
- *[AgentTesla]*: Infostealer
- *[BlackCat]*: Ransomware in Rust

I was also involved in developing some tools to help in the analysis process internally.

As well as conducting Reverse Engineering and Malware Analysis training for the new joiners.

## Software development

Apart from open source projects, I have worked on several software projects in my work experiences,
in the companies I have worked for, some of these:

### Audio sync

Worked on a system that syncs audio between the server and multiple clients, the clients will play the 
exact same audio at a very low latency between them, thus creating a surround sound effect.

Also created a frontend to manage this system and show a nice UI of the audio playing.

Technologies used:
- Rust
- Websockets
- ffmpeg
- React
- GraphQL

### GPU rendered web views

This is what I did in [ul-next], I created a custom driver for [Ultralight] that will render the web page
using the GPU, and then I created a Rust binding for it.

This was used in a project that required to render web pages in a very efficient way, and also to be able to
interact with the web page from the Rust code.

Technologies used:
- Rust
- OpenGL and Vulkan
- unsafe Rust
- FFI

### Shaders and GPU programming

Implemented multiple programs that display visual effects using the GPU.
These are sort of small games that focus on the creativity of the visual effects and the performance of the
rendering.

These are implemented in shaders.

Technologies used:
- Rust
- OpenGL and Vulkan
- Shaders

### Backend for AI based real-time video processing

Worked on a backend system that can process video streams from several sources in real time, feed these
streams into a custom AI model, and then send the results to the clients.

The system was designed to be easily horizontally scalable and to be able to handle a large number of
concurrent streams without any issues.

Technologies used:
- Python
- RabbitMQ
- Redis
- Websockets
- Video and Image processing

### Custom lua linter

We needed a custom lua linter for our system, so I forked: https://github.com/mpeterv/luacheck 
and added many more checks and features for our specific use case.

Technologies used:
- Lua
- Text processing
- Regular expressions
- Parsing
- Linting


[Plastic]: https://github.com/Amjad50/plastic
[Mizu]: https://github.com/Amjad50/mizu
[Trapezoid]: https://github.com/Amjad50/Trapezoid
[vulkano]: https://github.com/vulkano-rs/vulkano
[Emerald]: https://github.com/Amjad50/Emerald
[Dynwave]: https://github.com/Amjad50/dynwave
[Blinkcast]: https://github.com/Amjad50/blinkcast
[ul-next]: https://github.com/Amjad50/ul-next
[glium]: https://github.com/glium/glium
[rust-lang/rust]: https://github.com/rust-lang/rust
[tock]: https://github.com/tock/tock
[CAPEv2]: https://github.com/kevoreilly/CAPEv2
[QBot]: https://malpedia.caad.fkie.fraunhofer.de/details/win.qakbot
[AgentTesla]: https://malpedia.caad.fkie.fraunhofer.de/details/win.agent_tesla
[BlackCat]: https://malpedia.caad.fkie.fraunhofer.de/details/win.blackcat
[Ultralight]: https://ultralig.ht/