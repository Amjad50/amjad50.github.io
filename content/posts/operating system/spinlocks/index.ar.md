---
title: نظام التشغيل - القفل الدوراني
date: 2023-12-03T5:00:00+08:00
ShowToc: true
TocOpen: true
summary: الحديث عن تنفيذ القفل الدوراني بشكل آمن باستخدام لغة Rust في نظام تشغيل
description: الحديث عن تنفيذ القفل الدوراني بشكل آمن باستخدام لغة Rust في نظام تشغيل
keywords:
- نظام تشغيل
- rust
- قفل
tags:
- نظام تشغيل
- rust
category:
- نظام تشغيل
series:
- تطوير نظم التشغيل
series_weight: 0
---

مؤخرًا، كنت أعمل على نظام تشغيل صغير باستخدام لغة البرمجة [`Rust`] (هنا [OS]). أحد أهدافي في هذا المشروع هو بناء أكبر قدر ممكن من المكونات من الصفر (في وقت الكتابة، لا توجد تبعيات). بالطبع، ليس عليك القيام بذلك، ولكن أعتقد أن هذه فرصة جيدة للتعلم.

على أي حال، إحدى الأشياء المهمة في نظام التشغيل هي التزامن، حيث إن معظم الموارد في النظام تكون مشتركة بين عدة أنوية. لذا نحن بحاجة للتأكد من أنه يمكن لنواة واحدة فقط الوصول إلى مورد في وقت واحد، وهنا تأتي الأقفال لتلعب دورها.

> على الرغم من أنني أقول "أنظمة التشغيل" هنا، إلا أن هذا النوع من القفل يُستخدم في أي تطبيق بدون نظام تشغيل، مثل الأنظمة المضمنة، أو حتى في تطبيقات مساحة المستخدم.

> أستخدم [`Rust`] هنا للتنفيذ، ولكن هذا ليس منشورًا محددًا للغة Rust، يمكنك تنفيذه في أي لغة ترغب فيها، الفكرة هي نفسها.

## ما هو القفل؟

القفل هو أساس تزامن يسمح فقط لنواة أو معالج واحد بالوصول إلى مورد في وقت واحد. عندما تحاول نواة أو معالج آخر الوصول إلى المورد، سيتم حجبه حتى تقوم النواة أو معالج الأول بإطلاق القفل، وبالتالي، يمكننا التأكد من أنه يوجد فقط نواة أو معالج واحد يمكنه الوصول إلى المورد في وقت واحد.


## كيف تستخدم الprocess الأقفال داخل نظام التشغيل؟

في داخل نظام تشغيل عادي، تعمل الprocess بتشغيل عدة خيوط، ويدير النظام التشغيل هذه الخيوط. كما يوفر لك النظام التشغيل وسيلة لإنشاء آلية قفل بين خيوطك.

على سبيل المثال، في نظام Linux، يمكنك استخدام وظائف [`pthread_mutex_lock/unlock`] لقفل/فتح كائن القفل المتزامن. القفل هنا هو أساس تزامن يسمح فقط لخيط واحد بالوصول إلى مورد في وقت واحد، وهكذا يمكنك مزامنة خيوطك.

في نظام Windows، يمكنك استخدام وظائف [`AcquireSRWLockExclusive`]/[`ReleaseSRWLockExclusive`] لقفل/فتح كائن [SRW Lock].

إذاً، إنها واجهة برمجة التطبيقات التي يوفرها نظام التشغيل للسماح بتزامن فعّال بين الخيوط. عندما يكون الخيط في انتظار القفل، يدخل في حالة انتظار، وبالتالي لا يستهلك الكثير من وحدات المعالجة المركزية.

## كيف يمكننا صناعة أقفال خاصة بنا في نظام التشغيل؟

داخل النواة، ليس لدينا نظام تشغيل رئيسي يقدم لنا آلية إقفال، لذا يجب أن نقوم بتنفيذها بأنفسنا بطريقة ما.

وهنا يأتي **القفل الدوراني**، القفل الدوراني هو قفل ينتظر بشكل نشط حتى يتاح الوصول إليه. لذا، إذا كان هناك نواتين، وإحدى النواتين تحمل القفل، ستبقى النواة الأخرى في حلقة تنتظر حتى يتاح فتح القفل، ثم تقوم بالحصول عليه.


## عمل قفل دوراني

حسنًا، لدينا الفكرة الأولى في عقولنا الآن، دعونا نقوم بتنفيذها.

لنفترض أن لدينا دالة بإسم `handle_resource` تقوم بتنفيذ بعض الإجراءات على مورد مشترك، ونريد التأكد من أنه يمكن لنواة واحدة فقط الوصول إلى المورد في وقت واحد، لذا سنستخدم دالة القفل الدوراني لذلك.

سيكون المورد في متغير ثابت `static`، نظرًا لأننا نريد الوصول إليه من أي مكان. سنقوم بتنفيذ القفل في عدة تحديثات ونشرح المشكلة مع كل واحدة.

### الإصدار الأول

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

هنا، قمنا بتنفيذ قفل دوراني باستخدام متغير `bool`. لدينا دالة `lock` التي تنتظر بشكل نشط حتى يتاح الوصول إلى القفل، ثم نقوم بتعيين متغير `locked` إلى `true`. ولدينا أيضًا دالة `unlock` التي تقوم بتعيين متغير `locked` إلى `false`.

لكن هناك مشكلة كبيرة، هناك فجوة بين حلقة `while` وتعيين متغير `locked` إلى `true`، وفي هذه الفجوة، يمكن لنواة أخرى أن تأخذ القفل ولكننا لن نعلم عنها، وبالتالي، سيكون لدينا نواتين تصل إلى المورد في نفس الوقت.

عرض المشكلة في رسم توضيحي:

```rust {linenos=false}
Core1: lock()
   - Core1: self.locked == false    // `غير مقفل، قم بتعيينه إلى `صحيح
Core2: lock()
   - Core2: self.locked == false    // `غير مقفل، قم بتعيينه إلى `صحيح

   - Core1: self.locked = true
   - Core2: self.locked = true
// الآن لديهم النواتين القفل

```

لنحاول حل هذه المشكلة.

### الإصدار الثاني

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

إذا، هنا نستخدم [`AtomicBool`] بدلاً من `bool` العادي، ونستخدم [`compare_exchange`] لتعيين المتغير `locked` إلى `true` بطريقة ما؟ أيضًا إذا لاحظت، فإن القفل الآن ليس `mut`، ونحن نستخدم `self&` بدلاً من `mut self&`، وبالتالي يُسمح لنا باستخدامه من `static` بدون أي `unsafe`.

ولكن كيف يعمل ذلك؟

[`AtomicBool`] هو قيمة منطقية يمكن الوصول إليها بشكل ذري، وهذا يعني أن كل عملية تتم على هذا النوع تتم ذريًا، أي أن العملية كلها تتم كوحدة واحدة، وبالتالي، لا يمكن لنواة أخرى الوصول إلى المتغير في منتصف العملية.

دالة [`compare_exchange`] هي عملية ذرية تقارن قيمة المتغير بالقيمة الأولى، وإذا كانت متساوية، يتم تعيين قيمة المتغير إلى القيمة الثانية ذريًا، لا يمكن لنواتان أن تعينان القيمة في نفس الوقت، ستفوز نواة واحدة فقط في السباق. ثم تعيد الدالة `Ok` إذا كانت العملية ناجحة، و `Err` في غير ذلك (يرجى الرجوع إلى الdocs للمزيد من المعلومات).

بسبب كيفية عمل العمليات الذرية، يمكن لراست جعل الدوال تستخدم `&self` بدلاً من `&mut self`، لأنها يمكنها ضمان أن لا نواة أخرى يمكنها الوصول إلى المتغير في نفس الوقت. وبالتالي يمكننا تقليل الكود غير الآمن.

شيء آخر يجب ملاحظته هو  [`Ordering`]، يُحدد للمعالج كيف يمكنه ترتيب العمليات في الذاكرة المتعلقة بالعملية التزامنية، وكيف يؤثر على عمليات الذاكرة الأخرى حول العملية الذرية.

لشرح بسيط جدًا، `Ordering::Acquire` سيضمن أن جميع عمليات الذاكرة قبل العملية الذرية ستظهر للنواة الأخرى، و `Ordering::Release` سيضمن أن جميع عمليات الذاكرة بعد العملية الذرية ستظهر للنواة الأخرى.

 `Ordering::Relaxed` هو الترتيب الأضعف، ولا يضمن أي شيء على العمليات الأخرى، ولكنه فقط يضمن أن الذاكرة الملامسة بواسطة العملية الذرية ستظهر للنواة الأخرى (للمزيد من المعلومات حول هذا انظر إلى الdocs أو [Book: Rust Atomics and Locks]).

إذاً، عظيم، حلنا المشكلة، صحيح؟ حسنًا، نعم، ولكن هناك مشكلة أخرى.

هذه المشكلة مختصة فقط بتنفيذ نواة، وهي "المقاطعات".

عندما تكون داخل النواة، لا تخاف من النواة الأخرى فقط، ولكنك أيضًا تخاف من نفسك. يمكن أن تجد نفسك وراء ظهرك دون أن تلاحظ D:

هنا كيف يمكن أن يحدث ذلك.

```rust {linenos=false}
Core 1: lock()
    Core 1: self.locked.compare_exchange(false, true, Ordering::Acquire, Ordering::Relaxed) == Ok
    // ...القفل مغلق الآن، ونحن نقوم بعمل ما هنا، ولم ننتهِ بعد
    // ...
    [interrupt] // المقاطعة
Core 1: lock()  // نفس القفل مرة أخرى.
    Core 1: while self.locked.compare_exchange(false, true, Ordering::Acquire, Ordering::Relaxed) == Err
    // ....معلق للأبد
```

وهذا، أيها الأصدقاء، يُعرف باسم **الانغلاق**.

الانغلاق هو حالة يكون فيها خيط أو النواة في انتظار قفل يمتلكه بالفعل، وبالتالي، لن يكون قادرًا أبدًا على الحصول على القفل.

إذا، كيف يمكننا حل هذه المشكلة؟

### الإصدار الثالث

طريقة واحدة لحل هذه المشكلة هي من خلال منع وحدة المعالجة المركزية من استقبال المقاطعات أثناء الاحتفاظ بالقفل، بحيث لا يتم تشويشنا والوقوع في هذا الوضع.

هنا، أقوم فقط بتنفيذها لوحدة المعالجة المركزية `x86-64`، لذا هذا الجزء يعتمد على نوع الوحدة المعالجة المركزية، ولكن الفكرة هي نفسها للوحدات المعالجة المركزية الأخرى باستخدام تعليمات مختلفة.

> لن أكرر الكود القديم الذي لا يتغير

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
حسنًا، هذا الكثير من الكود. دعونا نقم بشرحها.

لذا، كان لدينا خطة لتعطيل المقاطعات. ولكن كيف يمكننا القيام بذلك بشكل آمن.

إذا قمنا بتنفيذ `()cpu::disable_interrupts` بطريقة ساذجة، على سبيل المثال داخل القفل، ثم `()cpu::enable_interrupts` داخل الإلغاء، سنواجه مشكلة، حيث ستفشل إذا كانت هناك أقفال متداخلة.

لنرى.

```rust  {linenos=false}
Core 1: Lock1::lock()
    Core 1: cpu::disable_interrupts()
    Core 1: self.locked.compare_exchange(false, true, Ordering::Acquire, Ordering::Relaxed) == Ok
    // القفل مغلق الآن، ولن نتلقى المقاطعات
    // ...
    Core 1: Lock2::lock()
        Core 1: cpu::disable_interrupts()   // منعت بالفعل، ولكن مهما كان الأمر
        Core 1: self.locked.compare_exchange(false, true, Ordering::Acquire, Ordering::Relaxed) == Ok
        // القفل مغلق الآن، ولن نتلقى المقاطعات
        // ...
        Core 1: Lock2::unlock()
            Core 1: self.locked.store(false, Ordering::Release)
            Core 1: cpu::enable_interrupts()
        // المقاطعات مُمكّنة الآن
    // ...
    [interrupt]// المقاطعة
    Core 1: Lock1::lock()  // نفس القفل مرة أخرى، وواجهنا نفس المشكلة، حيث قمنا بتمكين المقاطعات في مكان لا ينبغي
```

إذاً، علينا حل هذه المشكلة، يمكن حلها بسهولة عن طريق تذكر كم مرة قمنا بتعطيل المقاطعات،
ثم العودة للخلف، وتمكين المقاطعات بعد التأكد من عدم توقع أحد تعطيل المقاطعات.

المثال أعلاه سيكون كالتالي مع تنفيذ [`push_interrupt_disable`](#hl-4-7) و [`pop_interrupt_disable`](#hl-4-15):

> لا نحتاج إلى استخدام **atomic** عند زيادة `number_pushed`، لأن خط الإضافة سيُنفذ مرة واحدة فقط
عند تعطيل المقاطعات، ويجب أن يكون هذا الهيكل يستخدم فقط من قبل نواة مالكة واحدة، أي أن النوى الأخرى لن تنفذ
هذا الشيفرة على الإطلاق (لم يتم تنفيذ هذا هنا، أتركها كتمرين للقارئ).

```rust {linenos=false}
Core 1: Lock1::lock()
    Core 1: push_interrupt_disable()    // interrupt=false, number_pushed=1
    Core 1: self.locked.compare_exchange(false, true, Ordering::Acquire, Ordering::Relaxed) == Ok
    // القفل مغلق الآن، ولن نتلقى المقاطعات
    // ...
    Core 1: Lock2::lock()
        Core 1: push_interrupt_disable()   // interrupt=false, number_pushed=2
        Core 1: self.locked.compare_exchange(false, true, Ordering::Acquire, Ordering::Relaxed) == Ok
        // القفل مغلق الآن، ولن نتلقى المقاطعات
        // ...
        Core 1: Lock2::unlock()
            Core 1: self.locked.store(false, Ordering::Release)
            Core 1: pop_interrupt_disable() // interrupt=false, number_pushed=1
        // المقاطعات ما زالت معطلة
    // ...
Core 1: Lock1::unlock()
    Core 1: self.locked.store(false, Ordering::Release)
    Core 1: pop_interrupt_disable() // interrupt=true, number_pushed=0
// المقاطعات مُمكّنة الآن وكل شيء آمن
```

ونعم، هذا هو كل شيء، لدينا الآن قفل دوراني يعمل.
أعتقد أن هذا آمن من جميع المشاكل التي وجدتها، ولكن إذا وجدت أي مشكلة، فالرجاء إعلامي :)

##  جعلها تتناسب مع Rust

لدينا قفل الآن، ولكن استخدامه يبدو غير جميل، انظر إلى هذا:
```rust
GLOBAL_LOCK.lock();

unsafe {
    // SAFETY: we know that we are the only core accessing this resource so its safe to access it
    GLOBAL_RESOURCE += 1;
}
GLOBAL_LOCK.unlock();
```

يمكننا تحسين الوضع عن طريق إنشاء نوع يحتوي على البيانات والقفل، ويدير جميع الأمور `unsafe` بالنيابة عنا حتى لا نضطر إلى القيام بذلك.

يمكننا الحصول على إلهام من نوع [`Mutex`] في المكتبة القياسية.

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
هنا، نستخدم [`UnsafeCell`] لتخزين البيانات. نقوم بذلك لأننا نرغب في تغيير البيانات حتى إذا كان لدينا وصول مشترك إليها. لذا، يجب أن نخبر المترجم أننا ندرك المخاطر، ولهذا نستخدم `unsafe`.

عندما نقوم بقفل ال`Mutex`، نحصل على `SpinMutexGuard` الذي يحتوي على مؤشر إلى البيانات. عندما ينتهي، يقوم بفتح القفل. نظرًا لأنه يحتوي على مؤشر إلى القفل داخليًا، نحن واثقون من عدم إمكانية استخدام نواة أخرى للقفل في نفس الوقت. لذا، يمكننا استخدامه بأمان ثم فتحه.

`SpinMutexGuard` ينفذ [`Deref`] و [`DerefMut`] لتسهيل الوصول إلى البيانات الداخلية. كما ينفذ أيضًا [`Drop`] بحيث يتم فتح القفل عندما لا يكون هناك حاجة إليه بعد (مثل عندما يخرج من نطاق الرؤية). يوفر ذلك لنا من الحاجة إلى استدعاء `unlock` يدويًا (RAII).


#### تحسين صغير إضافي

شيء آخر تركته للنهاية، حيث لا يؤثر على الوظائف، ولكنه تحسين جميل.

وهو استخدام [`core::hint::spin_loop`] بدلاً من حلقة فارغة، وهذا سيوحي للمترجم/وحدة المعالجة المركزية أننا في حالة تكرار، وبالتالي، يمكنها تحسينها بشكل أفضل.

```rust {hl_lines=[3]}
fn lock(&self) {
    while self.locked.compare_exchange(false, true, Ordering::Acquire, Ordering::Relaxed).is_err() {
        core::hint::spin_loop();
    }
}
```

وهذا هو، لدينا الآن `Spinlock` رائع، ويمكننا استخدامه بسهولة.

## المشاكل

هذا `Mutex` الذي لدينا الآن جيد، ولكن هناك عدة قضايا.
### Spin
بالطبع، هذا هو قفل دوران، وسيضيع الوقت إذا تم الاحتفاظ بالقفل لفترة طويلة. هناك أنواع أخرى من الأقفال تحاول أن تكون أكثر عدالة، أو تعطي مهمة أخرى للنواة للقيام بها أثناء انتظار القفل. لا أعرف بالضبط، ولكن عندما أقوم بتنفيذ ذلك، سأقوم بإنشاء منشور جديد حوله D:

### Another type of deadlock
تخيل أنك تستخدم قفل داخل نوع `Console` على سبيل المثال. هذا هو نوع قمت بتنفيذه لطباعة الرسائل على الشاشة/واجهة التسلسل، ستحتاج إلى استخدام قفل هنا بحيث يمكن لنواة واحدة فقط الطباعة في وقت واحد.

الآن تخيل أن هذا `Console` يثير استثناء بطريقة ما، ولديك معالج استثناء يقوم بطباعة رسالة الاستثناء. هذا ليس انقطاع تنفيذ لوحدة المعالجة المركزية، ولكنه ميزة في **Rust** تقوم بنقل التنفيذ إلى `panic_handler` محدد.

سيؤدي ذلك إلى إنشاء تأخر تشابكي، حيث سيحاول `panic_handler` قفل `Console` لطباعة الرسالة، ولكن `Console` قد تم قفله بالفعل بواسطة النواة التي أثارت الاستثناء، وبالتالي، سنواجه تأخر تشابكي.

بالنسبة لهذا، يمكنك الاستفادة من نوع خاص من `Mutex` يسمح لك بقفله مرة أخرى بواسطة نفس النواة فقط. وهذا النوع من القفل يُستخدم فعلاً في المكتبة القياسية داخليًا، ويُسمى [`ReentrantMutex`]. تقوم المكتبة القياسية بتنفيذه مع خيط المالك، ويمكننا ببساطة استبداله بالنواة المالكة .

ولكن بالطبع، يمكن استخدام هذا النوع فقط في الأماكن القليلة التي تنشأ فيها هذه المشكلة، وليس بشكل عام. وعندما تحصل على القفل مرة أخرى، يجب عليك التأكد من أنك لا تسبب أي مشكلات مع البيانات داخليًا. لن يكون هناك مستخدم آخر في نفس الوقت، ولكن الحالة القابلة للتعديل يجب أن تكون دائمًا صالحة.

تُستخدم هذه في المكتبة القياسية كغلاف لـ `stdout` و `stderr`. (مثال: [`ReentrantMutex<RefCell<LineWriter<StdoutRaw>>>`])

## الختام والمراجع

تعتبر **Spinlocks** جزءًا هامًا من أي نظام تشغيل، على الأقل في المرحلة الأولى قبل وجود آليات قفل أفضل، ولذلك من المهم فهم كيفية عملها وكيفية تنفيذها بشكل آمن.

آمل أن يكون هذا المنشور قد كان مفيدًا، وإذا كان لديك أي أسئلة، يرجى إعلامي.

كانت هذه التنفيذات مستوحاة بشكل كبير من تنفيذ القفل في [`xv6`]، ونوع [`Mutex`] في المكتبة القياسية.

والسلام عليكم ورحمة الله وبركاته

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
[`ReentrantMutex`]: https://doc.rust-lang.org/stable/src/std/sync/remutex.rs.html
[`ReentrantMutex<RefCell<LineWriter<StdoutRaw>>>`]: https://doc.rust-lang.org/stable/src/std/io/stdio.rs.html#539
[`xv6`]: https://github.com/mit-pdos/xv6-public/blob/master/spinlock.c
