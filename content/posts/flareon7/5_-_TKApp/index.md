---
title: TKApp
date: 2020-10-15
ShowToc: true
TocOpen: true
summary: Fifth challenge of FlareOn7
description: Writeup of 5_-_TKApp, the fifth challenge in FlareOn7
keywords:
- writeup
- flareon7
- flareon 2020
- C#
- reverse engineering

tags:
- writeup
- flareon7
- C#
category:
- writeup
series:
- FlareOn7 Writeups
series_weight: 5
---

```txt
Now you can play Flare-On on your watch! As long as you still have an arm left to put a watch on, or emulate the watch's operating system with sophisticated developer tools.
```

```txt
$ file TKApp.tpk
TKApp.tpk: Zip archive data, at least v2.0 to extract
```

## Introduction

Looking online, `tpk` extension is for Samsung watches.

When extracting the content of the `zip` files, we find some images in `res` folder, app icon in `shared` folder, and most importantly we find some `dll` files in `bin` folder.

```txt
$ file *.dll
ExifLib.Standard.dll:                         PE32 executable (DLL) (console) Intel 80386 Mono/.Net assembly, for MS Windows
Tizen.Wearable.CircularUI.Forms.dll:          PE32 executable (DLL) (console) Intel 80386 Mono/.Net assembly, for MS Windows
Tizen.Wearable.CircularUI.Forms.Renderer.dll: PE32 executable (DLL) (console) Intel 80386 Mono/.Net assembly, for MS Windows
TKApp.dll:                                    PE32 executable (console) Intel 80386 Mono/.Net assembly, for MS Windows
Xamarin.Forms.Core.dll:                       PE32 executable (DLL) (console) Intel 80386 Mono/.Net assembly, for MS Windows
Xamarin.Forms.Platform.dll:                   PE32 executable (DLL) (console) Intel 80386 Mono/.Net assembly, for MS Windows
Xamarin.Forms.Platform.Tizen.dll:             PE32 executable (DLL) (console) Intel 80386 Mono/.Net assembly, for MS Windows
Xamarin.Forms.Xaml.dll:                       PE32 executable (DLL) (console) Intel 80386 Mono/.Net assembly, for MS Windows
```

Looks like this is built with [Xamarin] and [Tizen].

From the list of `dll`s we would need to only reverse engineer `TKApp.dll`.

I will be using [Dnspy] since this is a .NET app.

## Information collecting

We start by importing all `dll`s into [Dnspy] to fix connections between them, then we start looking into `TKApp.dll`.

In the resources we see one interesting file `TKApp.UnlockPage.xaml`, which has
`Entry` named `"PasswordEntry"` and a `Label` named `"flag"`, lets keep that in mind.

In the `App` class constructor
```C#
public App()
{
	App.ImgData = null;
	if (!App.IsLoggedIn)
	{
		TKData.Init();
		base.MainPage = new NavigationPage(new UnlockPage());
		return;
	}
	base.MainPage = new NavigationPage(new MainPage());
}
```

We see the usage of `UnlockPage` first.

### `UnlockPage`

In this class there is the login handler method to handle password input:
```C#
private async void OnLoginButtonClicked(object sender, EventArgs e)
{
	if (this.IsPasswordCorrect(this.passwordEntry.Text))
	{
		App.IsLoggedIn = true;
		App.Password = this.passwordEntry.Text;
		base.Navigation.InsertPageBefore(new MainPage(), this);
		await base.Navigation.PopAsync();
	}
	else
	{
		Toast.DisplayText("Unlock failed!", 2000);
		this.passwordEntry.Text = string.Empty;
	}
}

private bool IsPasswordCorrect(string password)
{
	return password == Util.Decode(TKData.Password);
}

public static byte[] Password = new byte[] {62, 38, 63, 63, 54, 39, 59, 50, 39};
```

This is also from `Util.Decode`:
```C#
public static string Decode(byte[] e)
{
	string text = "";
	foreach (byte b in e)
	{
		text += Convert.ToChar((int)(b ^ 83)).ToString();
	}
	return text;
}
```
The password is `"mullethat"`, and that is all there is to it for this class,
nothing on `flag` label.

### `MainPage`

There is some stuff here, but two functions seems interesting:
```C#
private void PedDataUpdate(object sender, PedometerDataUpdatedEventArgs e)
{
    if (e.StepCount > 50U && string.IsNullOrEmpty(App.Step))
    {
        App.Step = Application.Current.ApplicationInfo.Metadata["its"];
    }
    if (!string.IsNullOrEmpty(App.Password) && !string.IsNullOrEmpty(App.Note) && !string.IsNullOrEmpty(App.Step) && !string.IsNullOrEmpty(App.Desc))
    {
        HashAlgorithm hashAlgorithm = SHA256.Create();
        byte[] bytes = Encoding.ASCII.GetBytes(App.Password + App.Note + App.Step + App.Desc);
        byte[] first = hashAlgorithm.ComputeHash(bytes);
        byte[] second = new byte[]{50, 148, 76, 233, 110, 199, 228, 72, 114, 227, 78, 138, 93, 189, 189, 147, 159, 70, 66, 223, 123, 137, 44, 73, 101, 235, 129, 16, 181, 139, 104, 56};
        if (first.SequenceEqual(second))
        {
            this.btn.Source = "img/tiger2.png";
            this.btn.Clicked += this.Clicked;
            return;
        }
        this.btn.Source = "img/tiger1.png";
        this.btn.Clicked -= this.Clicked;
    }
}

private bool GetImage(object sender, EventArgs e)
{
    if (string.IsNullOrEmpty(App.Password) || string.IsNullOrEmpty(App.Note) || string.IsNullOrEmpty(App.Step) || string.IsNullOrEmpty(App.Desc))
    {
        this.btn.Source = "img/tiger1.png";
        this.btn.Clicked -= this.Clicked;
        return false;
    }
    string text = new string(new char[]
    {
        App.Desc[2],
        App.Password[6],
        App.Password[4],
        App.Note[4],
        App.Note[0],
        App.Note[17],
        App.Note[18],
        App.Note[16],
        App.Note[11],
        App.Note[13],
        App.Note[12],
        App.Note[15],
        App.Step[4],
        App.Password[6],
        App.Desc[1],
        App.Password[2],
        App.Password[2],
        App.Password[4],
        App.Note[18],
        App.Step[2],
        App.Password[4],
        App.Note[5],
        App.Note[4],
        App.Desc[0],
        App.Desc[3],
        App.Note[15],
        App.Note[8],
        App.Desc[4],
        App.Desc[3],
        App.Note[4],
        App.Step[2],
        App.Note[13],
        App.Note[18],
        App.Note[18],
        App.Note[8],
        App.Note[4],
        App.Password[0],
        App.Password[7],
        App.Note[0],
        App.Password[4],
        App.Note[11],
        App.Password[6],
        App.Password[4],
        App.Desc[4],
        App.Desc[3]
    });
    byte[] key = SHA256.Create().ComputeHash(Encoding.ASCII.GetBytes(text));
    byte[] bytes = Encoding.ASCII.GetBytes("NoSaltOfTheEarth");
    try
    {
        App.ImgData = Convert.FromBase64String(Util.GetString(Runtime.Runtime_dll, key, bytes));
        return true;
    }
    catch (Exception ex)
    {
        Toast.DisplayText("Failed: " + ex.Message, 1000);
    }
    return false;
}
```

#### Getting `App` data

These two functions depend on `App.Password`, `App.Note`, `App.Step` and `App.Desc`. We know `App.Password` and its `"mullethat"`.

From `PedDataUpdate` we know that `App.Step` can be obtained from
`Application.Current.ApplicationInfo.Metadata["its"]`. Looking `tizen-manifest.xml` we see
```xml
<!-- ... -->
<metadata key="its" value="magic" />
<!-- ... -->
```

Next, `App.Desc` is being set in `GalleryPage.IndexPage_CurrentPageChanged`
```C#
private void IndexPage_CurrentPageChanged(object sender, EventArgs e)
{
    if (base.Children.IndexOf(base.CurrentPage) == 4)
    {
        using (ExifReader exifReader = new ExifReader(Path.Combine(Application.Current.DirectoryInfo.Resource, "gallery", "05.jpg")))
        {
            string desc;
            if (exifReader.GetTagValue<string>(ExifTags.ImageDescription, out desc))
            {
                App.Desc = desc;
            }
            return;
        }
    }
    App.Desc = "";
}
```

we can get this with:
```txt
$ exiftool res/gallery/05.jpg | grep Description
Image Description               : water
```

So its `"water"`.

Lastly, `App.Note`. Its being set in `TodoPage.SetupList`.
```C#
public class Todo {
    // ...
    public Todo(string Name, string Note, bool Done)
    {
        this.Name = Name;
        this.Note = Note;
        this.Done = Done;
    }
}

private void SetupList()
{
    List<TodoPage.Todo> list = new List<TodoPage.Todo>();
    if (!this.isHome)
    {
        list.Add(new TodoPage.Todo("go home", "and enable GPS", false));
    }
    else
    {
        TodoPage.Todo[] collection = new TodoPage.Todo[]
        {
            new TodoPage.Todo("hang out in tiger cage", "and survive", true),
            new TodoPage.Todo("unload Walmart truck", "keep steaks for dinner", false),
            new TodoPage.Todo("yell at staff", "maybe fire someone", false),
            new TodoPage.Todo("say no to drugs", "unless it's a drinking day", false),
            new TodoPage.Todo("listen to some tunes", "https://youtu.be/kTmZnQOfAF8", true)
        };
        list.AddRange(collection);
    }
    List<TodoPage.Todo> list2 = new List<TodoPage.Todo>();
    foreach (TodoPage.Todo todo in list)
    {
        if (!todo.Done)
        {
            list2.Add(todo);
        }
    }
    this.mylist.ItemsSource = list2;
    App.Note = list2[0].Note;
}
```

So this can be `"and enable GPS"` or `"keep steaks for dinner"`,
since they are the first that are not done. I assumed that we should be at home,
so I worked with `"keep steaks for dinner"`. But you can try both, its not much.

In the end:
```C#
App.Password = "mullethat";
App.Step = "magic";
App.Desc = "water";
App.Note = "keep steaks for dinner";
```

In `PedDataUpdate`, it checks that the values are correct by comparing
the `SHA256` of `App.Password + App.Note + App.Step + App.Desc`
to some predefined value. Tried it and it matches.

#### `GetImage` function

The most important part of that function is:
```C#
// ...
// `text` is a selected number of characters from App.Password, App.Note, App.Step and App.Desc
byte[] key = SHA256.Create().ComputeHash(Encoding.ASCII.GetBytes(text));
byte[] bytes = Encoding.ASCII.GetBytes("NoSaltOfTheEarth");
try
{
    // `Runtime.Runtime_dll` is the content of a resource named `Runtime.dll`
    // its 83392 bytes
    App.ImgData = Convert.FromBase64String(Util.GetString(Runtime.Runtime_dll, key, bytes));
    return true;
}
// ...
```
And `Util.GetString`:
```C#
public static string GetString(byte[] cipherText, byte[] Key, byte[] IV)
{
	string result = null;
	using (RijndaelManaged rijndaelManaged = new RijndaelManaged())
	{
		rijndaelManaged.Key = Key;
		rijndaelManaged.IV = IV;
		ICryptoTransform cryptoTransform = rijndaelManaged.CreateDecryptor(rijndaelManaged.Key, rijndaelManaged.IV);
		using (MemoryStream memoryStream = new MemoryStream(cipherText))
		{
			using (CryptoStream cryptoStream = new CryptoStream(memoryStream, cryptoTransform, 0))
			{
				using (StreamReader streamReader = new StreamReader(cryptoStream))
				{
					result = streamReader.ReadToEnd();
				}
			}
		}
	}
	return result;
}
```

This looks like [AES] decryption. Now we have all the pieces, lets solve it.

## Solution

First, we can export the resource `Runtime.dll` into a file.

Then we run this:
```C#
using System;
using System.IO;
using System.Text;
using System.Security.Cryptography;

class MainClass {
    public static string GetString(byte[] cipherText, byte[] Key, byte[] IV)
    {
        string result = null;
        using (RijndaelManaged rijndaelManaged = new RijndaelManaged())
        {
            rijndaelManaged.Key = Key;
            rijndaelManaged.IV = IV;
            ICryptoTransform cryptoTransform = rijndaelManaged.CreateDecryptor(rijndaelManaged.Key, rijndaelManaged.IV);
            using (MemoryStream memoryStream = new MemoryStream(cipherText))
            {
                using (CryptoStream cryptoStream = new CryptoStream(memoryStream, cryptoTransform, 0))
                {
                    using (StreamReader streamReader = new StreamReader(cryptoStream))
                    {
                        result = streamReader.ReadToEnd();
                    }
                }
            }
        }
        return result;
    }

    public static void Main (string[] args) {
        byte[] key = SHA256.Create().ComputeHash(Encoding.ASCII.GetBytes("the kind of challenges we are gonna make here"));
        byte[] bytes = Encoding.ASCII.GetBytes("NoSaltOfTheEarth");

    	byte[] cihperText = File.ReadAllBytes("Runtime.dll");

        byte[] result = Convert.FromBase64String(GetString(cihperText, key, bytes));
        File.WriteAllBytes("out.jpg", result);
    }
}
```

Running this, we get an image:
![flag](flag.jpg)

Flag:
```txt
n3ver_go1ng_to_recov3r@flare-on.com
```

[Xamarin]: https://dotnet.microsoft.com/apps/xamarin
[Tizen]: https://www.tizen.org/
[Dnspy]: https://github.com/0xd4d/dnSpy
[AES]: https://en.wikipedia.org/wiki/Advanced_Encryption_Standard