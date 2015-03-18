---
layout: post
---
This one's going to be a short one (I can sense the relief)
regarding mounting Google Drive on a linux
machine and using it to read/write.

I hated writing in Google Docs without the 
comfy environment of Vim. The `TEXTAREA` mode that Vimperator provides was
sufficient for editing short texts. But without the full power of Vim,
editing a huge Google Doc was painful and I grew restless. I tried [pterosaur](https://github.com/ardagnir/pterosaur)
which embeds full-blown Vim in textareas. It gives you all those shortcuts
which you have built over time in your `vimrc`. It would have been the answer
to my travails if not for the terrible lag. 
I have given up on having a powerful Vim instance in the browser (for now) and 
proceeded to check if there was a way to access Google Docs with Vim.  I don't remember whether I have found [google-drive-ocamlfuse](https://github.com/astrada/google-drive-ocamlfuse) on stackoverflow or on r/vim (might be both). It's basically a [FUSE file system](http://en.wikipedia.org/wiki/Filesystem_in_Userspace)
for Google Drive written in OCaml(first time I have heard of that).

>Filesystem in Userspace (FUSE) is an operating system mechanism for Unix-like computer
operating systems that lets non-privileged users create their own file systems without
editing kernel code. This is achieved by running file system code in user space while the
FUSE module provides only a "bridge" to the actual kernel interfaces.

>Virtual file system
FUSE is particularly useful for writing virtual file systems. Unlike traditional file systems
that essentially save data to and retrieve data from disk, virtual filesystems do not actually
store data themselves. They act as a view or translation of an existing file system or storage device.
In principle, any resource available to a FUSE implementation can be exported as a file system

It's a great tool for working with Google Drive on linux machines. Using it with
Vim is just one of the use cases. Here is how the installation goes for Ubuntu.
Others might need to build it from source ([check the repo](https://github.com/astrada/google-drive-ocamlfuse#configuration-and-installation)).
{% highlight bash %}
$ sudo add-apt-repository ppa:alessandro-strada/ppa
$ sudo apt-get update
$ sudo apt-get install google-drive-ocamlfuse
{% endhighlight %}

And it works out of the box. No need to get yourself lost in editing
configuration files or browsing man-pages to make yourself look cool
even though you really have no clue what you are supposed to look for.

Having said that, you might want to have a look at `~/.gdfuse/default/config` if you want
to tinker with some of the options.

After the installation is done, you need to give it the authentication.
{% highlight bash %}
$ google-drive-ocamlfuse
{% endhighlight %}
It opens the authentication page and the usual stuff that goes with Google
Authentication follows.

Now comes the moment we (this might be the first time the word we had a singular vibe)
have been waiting for. Mount it like you mean it.
{% highlight bash %}
$ mkdir mountdir
$ google-drive-ocamlfuse mount mountdir
{% endhighlight %}

Now fire up a file in Vim to edit/create and use the good ole :w to save it.
It might take some time (default is 60 seconds) to the changes to be 
reflected in the Drive.

To unmount,
{% highlight bash %}
$ fusermount -u mountdir
{% endhighlight %}

I know that you can't edit Word Processor files like `.doc` and `.docx` in Vim.
Bummer. I am willing to concede that for now and keep using `.txt` and `.md` when I need
to write something long and need it to be shared/collaborated.
No, that situation is not nonexistant.






