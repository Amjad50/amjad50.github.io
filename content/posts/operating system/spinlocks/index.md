---
title: Operating System - Spinlocks
date: 2023-12-03T5:00:00+08:00
lastmod: 2023-12-05T9:00:00+08:00
ShowToc: true
TocOpen: true
summary: Blabbing about implementing spinlocks safely with Rust in an operating system
description: Talking about implementing spinlocks safely with Rust in an operating system
keywords:
- operating system
- rust
- locks
tags:
- operating system
- rust
category:
- osdev
series:
- Operating System Development
series_weight: 0
---

Recently, I've been working on a small operating system in [`Rust`] ([OS]), one my goals in this project is building 
as much as I can from scratch (at the time of writing, 0 dependencies), of course you don't have to do that, but
I think this is a good learning opportunity.

Anyway, one of the important things in an operating system is synchronization, since most resources in the kernel
is shared between multiple cores, we need to make sure that only one core can access a resource at a time, and
that's where locks come in.

> Even though I'm saying "operating systems" here, this kind of locking is used in any bare-metal application, like
> embedded systems, or even in user-space applications.

> I'm using [`Rust`] here for implementation, but this is not a Rust specific post, and you can implement it in any
> language you want, the idea is the same.


## What is a lock?

A lock is a synchronization primitive that allows only one core/thread to access a resource at a time, when another
core/thread tries to access the resource, it will be blocked until the first core/thread releases the lock, and thus, we can make sure only one has access to the resource at a time.

## How a process inside an operating system use locks?

Inside a normal operating system, a process is running multiple threads, and the operating system manages these
threads, the operating system also provide you a way so that you can create a locking mechanism between your threads.

For example, in Linux, you can use the [`pthread_mutex_lock/unlock`] functions to lock/unlock a mutex object.
The `mutex` here is a synchronization primitive that allows only one thread to access a resource at a time, and
that's how you can synchronize your threads.

In windows, you can use the [`AcquireSRWLockExclusive`]/[`ReleaseSRWLockExclusive`] functions to lock/unlock an [SRW Lock] object.

So, its an API provided by the operating system to allow efficient synchronization between threads. When the thread
is waiting for a lock, it enters into a waiting state, and thus doesn't consume a lot of CPU time.

## How can we implement locks in an operating system?

Inside a kernel, we don't have a parent operating system to provide us with a locking mechanism, so we have to
do it ourselves somehow.

And here comes the **spinlock**, a **spinlock** is a lock that busy-waits until the lock is available, so if you have 2 cores, and one
core is holding the lock, the other core will be stuck in a loop waiting for the lock to be unlocked, and then it will acquire it.

## Implementing a spinlock

Ok, so we have the first idea in our mind now, let's implement it.

Let's say we have a function `handle_resource` that perform some action on a shared resource, and we want to make sure
that only one core can access the resource at a time, so we will use a spinlock to do that.

The resource will reside in a static variable, since we want to access it from anywhere. We will implement the lock in multiple iterations and explain
what's the issue with each one.


### Version 1

```rust
struct Spinlock {
    locked: bool,
}

impl Spinlock {
    fn new() -> Self {
        Self {
            locked: false,
        }
    }

    fn lock(&mut self) {
        while self.locked {
            // spin
        }
        self.locked = true;
    }

    fn unlock(&mut self) {
        self.locked = false;
    }
}

static mut GLOBAL_LOCK: Spinlock = Spinlock::new();
static mut GLOBAL_RESOURCE: u32 = 0;

// this will be called from multiple cores
fn kernel_main() {
    unsafe {
        // SAFETY: is this safe?
        GLOBAL_LOCK.lock();
        // SAFETY: we know that we are the only core accessing this resource
        //         so its safe to access it
        GLOBAL_RESOURCE += 1;
        GLOBAL_LOCK.unlock();
    }
}
```

Here, we implemented a spinlock by using a `bool` variable, we have a `lock` function that busy-waits until the lock is available, and then
we set the `locked` variable to `true`, and we have an `unlock` function that sets the `locked` variable to `false`.

But it has a big issue, there is a gap between the `while` loop and setting the `locked` variable to `true`, and in this gap, another core can
take the lock but we won't know about it, and thus, we will have 2 cores accessing the resource at the same time.

Showing the issue in a diagram:

```rust {linenos=false}
Core 1: lock()
    Core 1: self.locked == false    // not locked, proceed to setting it to true
Core 2: lock()
    Core 2: self.locked == false    // not locked, proceed to setting it to true

    Core 1: self.locked = true
    Core 2: self.locked = true
// both cores have the lock now
```

Let's try to fix this issue.

### Version 2

```rust  {hl_lines=[4, 10, "15-17", 21, 25, 30, 37]}
use core::sync::atomic::{AtomicBool, Ordering};

struct Spinlock {
    locked: AtomicBool,
}

impl Spinlock {
    fn new() -> Self {
        Self {
            locked: AtomicBool::new(false),
        }
    }

    fn lock(&self) {
        while self.locked.compare_exchange(false, true, Ordering::Acquire, Ordering::Relaxed).is_err() {
            // spin
        }
    }

    fn unlock(&self) {
        self.locked.store(false, Ordering::Release);
    }
}

static GLOBAL_LOCK: Spinlock = Spinlock::new();
static mut GLOBAL_RESOURCE: u32 = 0;

// this will be called from multiple cores
fn kernel_main() {
    GLOBAL_LOCK.lock();

    unsafe {
        // SAFETY: we know that we are the only core accessing this resource
        //         so its safe to access it
        GLOBAL_RESOURCE += 1;
    }
    GLOBAL_LOCK.unlock();
}
```

So, here we are using an [`AtomicBool`] instead of a normal `bool`, and we are using the [`compare_exchange`] function to set the `locked` variable to `true` somehow? Also if you noticed, the lock now is immutable, and we are using `&self` instead of `&mut self`, and thus allowing us to use it from `static` without any `unsafe` code.

But how does it work?

An [`AtomicBool`] is a boolean value that can be accessed atomically, meaning that each operation done on this type is done atomically, i.e. the whole operation is done as a single unit, and thus, no other core can access the variable in the middle of the operation.

The [`compare_exchange`] function is an atomic operation that compares the value of the variable with the first argument, and if they are equal, it sets the value 
of the variable to the second value atomically, no two cores can set the value at the same time, only one will win the race. The function then returns `Ok` if 
the operation was successful, and `Err` otherwise (please look at the documentation for more information).

Because of how atomic works, rust can make the functions use `&self` instead of `&mut self`, since it can guarantee that no other core can access the variable
at the same time. And thus we can reduce the `unsafe` code.

Another thing to notice is the [`Ordering`] argument, it specifies the synchronization ordering of the operation, and how it affects other memory accesses around
the atomic operation.

For a very very basic explanation, `Ordering::Acquire` will ensure that all memory operations before the atomic operation will be visible to other cores,
and `Ordering::Release` will ensure that all memory operations after the atomic operation will be visible to other cores.
`Ordering::Relaxed` is the weakest ordering, and it doesn't guarantee anything on the other operations, but it just guarantees that the memory touched by the
atomic operation will be visible to other cores (For more information about this check the documentation or [Book: Rust Atomics and Locks])

So great, we fixed the issue, right? Well, yes, but there is another issue.

This issue is only specific to implementing a kernel, and that's `interrupts`.

When you are inside the kernel, you don't just fear other cores, you also fear yourself. You can find yourself behind your back
without even noticing :D

Here is how it might happen.

```rust {linenos=false}
Core 1: lock()
    Core 1: self.locked.compare_exchange(false, true, Ordering::Acquire, Ordering::Relaxed) == Ok
    // lock is now locked, and we are doing some work here, and we haven't finished...
    // ...
    [interrupt]
Core 1: lock()  // same lock again
    Core 1: while self.locked.compare_exchange(false, true, Ordering::Acquire, Ordering::Relaxed) == Err
    // stuck forever....
```

And that's my friends, is called a **deadlock**.

A deadlock is a situation where a thread is waiting for a lock that it already holds, and thus, it will never be able to acquire the lock.

So, how can we fix this issue?

### Version 3

One way to fix this is by disallowing the CPU from receiving interrupts while we are holding the lock, so we won't be interrupted and getting into this situation.

Here, I'm just implementing it for an `x86-64` CPU, so this part is CPU specific, but the idea is the same for other CPUs with other instructions.

> I'll not repeat old code that doesn't change
```rust {hl_lines=["7-13", "15-22", 26, 35, 42]}
struct Cpu {
    old_interrupt_state: bool,
    number_pushed: u32,
}

impl Cpu {
    fn push_interrupt_disable(&mut self) {
        if self.number_pushed == 0 {
            self.old_interrupt_state = cpu_specific::current_interrupt();
            cpu_specific::disable_interrupts();
        }
        self.number_pushed += 1;
    }

    fn pop_interrupt_disable(&mut self) {
        self.number_pushed -= 1;
        if self.number_pushed == 0 {
            if self.old_interrupt_state {
                x86_64::instructions::interrupts::enable();
            }
        }
    }
}


fn current_cpu() -> &'static mut Cpu {
    // ...
    // get a static variable or something
    // we can use an array hosting all the CPUs structs for example, 
    // and ensuring an index is only usable by one core
}

impl Spinlock {
    fn lock(&self) {
        current_cpu().push_interrupt_disable();
        while self.locked.compare_exchange(false, true, Ordering::Acquire, Ordering::Relaxed).is_err() {
            // spin
        }
    }

    fn unlock(&self) {
        self.locked.store(false, Ordering::Release);
        current_cpu().pop_interrupt_disable();
    }
}
```
Alright, thats a lot of code. Let's explain it.

So, we had our plan of disabling interrrupts. But how can we do this safely.

If we just perform naively `cpu::disable_interrupts()` for example inside the `lock`, and then `cpu::enable_interrupts()` inside the `unlock`, we will have a problem, since it will fail if we have nested locks.

Let's see

```rust  {linenos=false}
Core 1: Lock1::lock()
    Core 1: cpu::disable_interrupts()
    Core 1: self.locked.compare_exchange(false, true, Ordering::Acquire, Ordering::Relaxed) == Ok
    // lock is now locked, and we won't get interrupts
    // ...
    Core 1: Lock2::lock()
        Core 1: cpu::disable_interrupts()   // already disabled, but whatever
        Core 1: self.locked.compare_exchange(false, true, Ordering::Acquire, Ordering::Relaxed) == Ok
        // lock is now locked, and we won't get interrupts
        // ...
        Core 1: Lock2::unlock()
            Core 1: self.locked.store(false, Ordering::Release)
            Core 1: cpu::enable_interrupts()
        // interrupts are now enabled
    // ...
    [interrupt]
    Core 1: Lock1::lock()  // same lock again, and we got to the same issue, since we enabled interrupts where we shouldn't
```

So, we have to fix this issue, this can easily be fixed by remembering how many times we are disabling interrupts,
and go backwards, enabling interrupts after we know that no one is expecting the interrupts to be disabled.

The above example will be like so with the implementation of [`push_interrupt_disable`](#hl-4-7) and [`pop_interrupt_disable`](#hl-4-15),
> we don't need to use **atomic** when incrementing `number_pushed`, since the addition line will only be executed once
 we disable the interrupts, and this struct should only be used by one owner core, i.e. other cores won't execute this
 code at all (This is not implemented here, I'm leaving it as an exercise for the reader).

```rust {linenos=false}
Core 1: Lock1::lock()
    Core 1: push_interrupt_disable()    // interrupt=false, number_pushed=1
    Core 1: self.locked.compare_exchange(false, true, Ordering::Acquire, Ordering::Relaxed) == Ok
    // lock is now locked, and we won't get interrupts
    // ...
    Core 1: Lock2::lock()
        Core 1: push_interrupt_disable()   // interrupt=false, number_pushed=2
        Core 1: self.locked.compare_exchange(false, true, Ordering::Acquire, Ordering::Relaxed) == Ok
        // lock is now locked, and we won't get interrupts
        // ...
        Core 1: Lock2::unlock()
            Core 1: self.locked.store(false, Ordering::Release)
            Core 1: pop_interrupt_disable() // interrupt=false, number_pushed=1
        // interrupts are still disabled
    // ...
Core 1: Lock1::unlock()
    Core 1: self.locked.store(false, Ordering::Release)
    Core 1: pop_interrupt_disable() // interrupt=true, number_pushed=0
// interrupts are now enabled and all safe
```

And yeah, that's it, we have a working spinlock now.
I think that this is safe from all issues that I found, but if you found any issue, please let me know :)

## Rustifying

We have a lock now, but using it is ugly, look at this:
```rust
GLOBAL_LOCK.lock();

unsafe {
    // SAFETY: we know that we are the only core accessing this resource so its safe to access it
    GLOBAL_RESOURCE += 1;
}
GLOBAL_LOCK.unlock();
```

We can make it better by creating a type that holds the data and lock, and handles all the `unsafe` stuff for us so we don't
have to do that.

We can get inspiration from the [`Mutex`] type in the standard library.

```rust
use core::{cell::UnsafeCell, ops::{Deref, DerefMut}};

// you can put this in `spin::Mutex` or something
struct SpinMutex<T> {
    lock: Spinlock,
    data: UnsafeCell<T>,
}

// impl extra stuff here, like `unsafe Send/Sync`, `Debug`, I won't go into details here

impl<T> SpinMutex<T> {
    fn new(data: T) -> Self {
        Self {
            lock: Spinlock::new(),
            data: UnsafeCell::new(data),
        }
    }

    fn lock(&self) -> SpinMutexGuard<'_, T> {
        self.lock.lock();
        SpinMutexGuard {
            lock: &self.lock,
            // SAFETY: we know that we are the only core accessing this resource so its safe to access it
            data: unsafe { &mut *self.data.get() },
        }
    }

    // extra function here
    fn try_lock(&self) -> Option<SpinMutexGuard<'_, T>> {
        // `try_lock` here just performs `lock` but without looping
        // it will return `true` if the lock was acquired, and `false` otherwise
        if self.lock.try_lock() {
            Some(SpinMutexGuard {
                lock: &self.lock,
                data: unsafe { &mut *self.data.get() },
            })
        } else {
            None
        }
    }

    fn unlock(&self) {
        self.lock.unlock();
    }
}

struct SpinMutexGuard<'a, T> {
    lock: &'a Spinlock,
    data: &'a mut T,
}

impl <'a, T> Deref for SpinMutexGuard<'a, T> {
    type Target = T;

    fn deref(&self) -> &Self::Target {
        self.data
    }
}

impl <'a, T> DerefMut for SpinMutexGuard<'a, T> {
    fn deref_mut(&mut self) -> &mut Self::Target {
        self.data
    }
}

impl<T> Drop for SpinMutexGuard<'_, T> {
    fn drop(&mut self) {
        self.lock.unlock();
    }
}

// usage
static GLOBAL_RESOURCE: SpinMutex<u32> = SpinMutex::new(0);

fn kernel_main() {
    let mut guard = GLOBAL_RESOURCE.lock();
    *guard += 1;
    // guard is dropped here, and the lock is unlocked
}
```


Here, we use [`UnsafeCell`] to keep the data. We do this because we want to change the data inside even if we have a shared reference to it. So, we have to let the compiler know we're aware of the risks, and that's why we use `unsafe`.

When we lock the `Mutex`, we get a `SpinMutexGuard` back that has a reference to the data. When it's done, it unlocks the lock. Since it has a reference to the lock inside, we're sure no other core can use the lock at the same time. So, we can safely use it and then unlock it.

`SpinMutexGuard` implements [`Deref`] and [`DerefMut`] to make it easy to get to the data inside. It also implements [`Drop`] so that the lock gets unlocked when it's not needed anymore (like when it goes out of scope). This saves us from having to manually call `unlock` (RAII).

And that's mainly it, we have a nice spinlock now, and we can use it easily.

## Extra small improvements

Another thing I left for last, since it doesn't affect functionality, but it is a nice improvement.

And that's using [`core::hint::spin_loop`] instead of an empty loop, this will hint the compile/cpu that we are spinning,
and thus, it can optimize it better.

```rust {hl_lines=[3]}
fn lock(&self) {
    while self.locked.compare_exchange(false, true, Ordering::Acquire, Ordering::Relaxed).is_err() {
        core::hint::spin_loop();
    }
}
```

Another thing (Thanks to `zypeh`) is using `core::sync::atomic::AtomicUsize` instead of `core::sync::atomic::AtomicBool`,
or by using [`crossbeam_utils::CachePadded`] to make sure that the lock is not in the same cache line as other variables,
and thus, we can avoid false sharing, and improve performance.

## Issues

This `Mutex` we have now is good, but there are several issues.
### Spin
Of course, this is a spin lock, and will waste time if the lock is held for a long time, there are other types of locks that
try to be more fair, or give another task for the core to do while waiting for the lock, I don't know what exactly,
but when I implement it, I'll create a new post on it :D

### Another type of deadlock
Imagine you are using a lock inside the `Console` type for example, this is a type that you have implemented
to print messages to the serial/display, you will need to use a lock here so that only one core prints at a time.

Now imagine, that this `Console` somehow `panic`s, and you have a `panic` handler that prints the `panic` message.
This is not a CPU interrupt, but a feature in rust that transfer execution into a specific `panic_handler`.

This will generate a deadlock, since the `panic_handler` will try to lock the `Console` to print the message, but
the `Console` is already locked by the core that panicked, and thus, we will have a deadlock.

For this one, you can have a special type of `Mutex` that allows you to lock it multiple times by the same core only.
And this type of lock is actually used in the standard library internally, and it is called [`ReentrantMutex`].
The standard library implements it with `owner` thread, we can just replace it with `core`.

But of course, this is only useable in these few places that arrise this issue, and not in general.
And when you get the lock again, you have to make sure that you are not causing any issues with the data inside, there won't be another user at the same time, but the mutable state should be always valid.

In the standard library this is used as a wrapper for `stdout` and `stderr`. (example: 
[`ReentrantMutex<RefCell<LineWriter<StdoutRaw>>>`])

## Conclusion and acknowledgements

**Spinlocks** are important part of any kernel, at least in the beginning before having better locking mechanisms,
and thus its important to understand how they work and how to implement them safely.

I hope this post was helpful, and if you have any questions or issues, please let me know.

This implementation was greatly inspired by the lock implementation in [`xv6`], and the [`Mutex`] type in the standard library.

Happy hacking :D

[`Rust`]: https://www.rust-lang.org/
[OS]: https://github.com/Amjad50/OS
[`pthread_mutex_lock/unlock`]: https://linux.die.net/man/3/pthread_mutex_lock
[`AcquireSRWLockExclusive`]: https://docs.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-acquiresrwlockexclusive
[`ReleaseSRWLockExclusive`]: https://docs.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-releasesrwlockexclusive
[SRW Lock]: https://docs.microsoft.com/en-us/windows/win32/sync/slim-reader-writer--srw--locks
[`AtomicBool`]: https://doc.rust-lang.org/std/sync/atomic/struct.AtomicBool.html
[`compare_exchange`]: https://doc.rust-lang.org/std/sync/atomic/struct.AtomicBool.html#method.compare_exchange
[`Ordering`]: https://doc.rust-lang.org/std/sync/atomic/enum.Ordering.html
[Book: Rust Atomics and Locks]: https://marabos.nl/atomics/
[`Mutex`]: https://doc.rust-lang.org/std/sync/struct.Mutex.html
[`UnsafeCell`]: https://doc.rust-lang.org/std/cell/struct.UnsafeCell.html
[`Deref`]: https://doc.rust-lang.org/std/ops/trait.Deref.html
[`DerefMut`]: https://doc.rust-lang.org/std/ops/trait.DerefMut.html
[`Drop`]: https://doc.rust-lang.org/std/ops/trait.Drop.html
[`core::hint::spin_loop`]: https://doc.rust-lang.org/core/hint/fn.spin_loop.html
[`crossbeam_utils::CachePadded`]: https://docs.rs/crossbeam-utils/latest/crossbeam_utils/struct.CachePadded.html
[`ReentrantMutex`]: https://doc.rust-lang.org/stable/src/std/sync/remutex.rs.html
[`ReentrantMutex<RefCell<LineWriter<StdoutRaw>>>`]: https://doc.rust-lang.org/stable/src/std/io/stdio.rs.html#539
[`xv6`]: https://github.com/mit-pdos/xv6-public/blob/master/spinlock.c
