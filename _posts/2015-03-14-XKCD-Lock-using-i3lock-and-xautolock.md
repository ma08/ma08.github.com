---
layout: post
---
One thing I have just observed is, whenever there are a bunch of assignments (or
various academic chores) to tend to, a sensor in my brain goes off saying,
> Man, I really should write an obscure blog post which has no use to anyone
whatsoever! 

So whenever you see a new post pop up here, you would know that I
really should be doing something else. Yet here I am involved in a fuzzy self
fulfilling prophesy.

Coming to the point(or the lack of one), this one's going to be about creating a
customized lock screen - like [the one in Ubuntu](http://i1-news.softpedia-static.com/images/news2/Ubuntu-12-04-LTS-Has-a-New-Lock-Screen-2.jpg)
, but a simpler one. Whenever I go away from my desk
for short periods, I leave my laptop as it is. It doesn't have a screensaver or
a lock screen with a timeout, so it stays unchanged (no lock or screensaver) when
I come back. Only when I go away for hours together (as rare as it is), I close
the lid to put it to sleep. As you can infer, not a big fan of shutdown. My
uptime right now is `17:01:12 up 7 days,  2:06,  9 users,  load average: 0.23, 0.42, 0.45`

Having stubmbled upon [i3lock](http://i3wm.org/i3lock/) when browsing `i3` related stuff,
I decided that I should make my visits away from my desk worthwhile by firing up a lock screen with
rewarding images. You can give a colour or a background image to `i3lock` for the
background. `i3lock` fires up only when you specifically call it. `xautolock` can be used to fire up
`i3lock` on a timeout (of inactivity) or a gesture. You need to type your
password to unlock the `i3lock` screen.

One of the few things that the whole word has a consensus on is that [xkcd](http://i3wm.org/i3lock/)
is awesome. You simply can't get enough of it. Using xkcd comics as the images
for the lock is the obvious choice. I searched in the DC++ hub in the campus to see 
if someone had a xkcd collection. Surprisingly, no one did. Putting my
crawling skills to test, I wrote a `node.js` script to download all the xkcd comics
till date. xkcd had a `JSON` format [which was perfect for crawling using node](http://xkcd.com/4/info.0.json).
The files are saved in the `xkcd_comics` directory.

{% highlight javascript %}
var fs = require('fs'),
    request = require('request'),
    path = require('path'),
    http = require('http');
var i;
for (i = 1 ; i <= 1495 ; i++) {
  var url="http://xkcd.com/"+i+"/info.0.json";
  request({url:url,json:true},function(err,res,body){
    if(!err){
      var filename=__dirname+'/xkcd_comics/'+path.basename(body.img);
      console.log(filename);
      request.get({url: body.img, encoding: 'binary'}, function (err, response, body) {
        fs.writeFile(filename, body, 'binary', function(err) {
          if(err)
            console.log(err);
          else
            console.log("The file was saved!");
        }); 
      });
    }
  })
}
{% endhighlight %}

It worked flawlessly except for `http://xkcd.com/404/`. Cheeky bastards. 
Most of the downloaded images were in `jpg` and `png` formats. There were a few
gifs which I didn't consider for `i3lock`. They must have made a switch
from jpg to png midway through the jig. 

`i3lock` had a limitation that it only worked with `png` images. So I had to convert all
the jpg images to png images. After first copying all the png images to the
folder `xkcd_comics_png`.

{% highlight python %}
#!/usr/bin/env python
#I have started making the switch from bash to python for my scripts.
import os
from random import randint
from subprocess import Popen, PIPE,call
p = Popen("ls ~/pro/xkcd/xkcd_comics/*.jpg", stdout=PIPE, shell=True)
result=p.communicate()[0].split('\n')
for x in result:
    dir_name=os.path.dirname(x)
    #print(dir_name)
    base=os.path.basename(x)
    name=os.path.splitext(base)[0]
    
    call(["convert",x,"xkcd_comics_png"+"/"+name+".png"])
{% endhighlight %}

Now having got all the images in the png format, I checked how the image is
being positioned by the `i3lock`. If given an image of resolution less than the screen size,
it showed it in the top left corner with the remaining space kept blank. To my
dismay, it had no positioning parameters. The creators wanted the user to alter the
image to his needs and feed it to `i3lock` to ensure that `i3lock` wouldn't get 
bloated with image handling overhead.

I tried to obtain higher resolution pics of the comics. [This incident](http://blog.xkcd.com/2007/03/15/in-which-i-lose-the-originals-of-the-last-three-months-of-comics-and-the-laptop-i-create-them-with/) extinguished my hopes of obtaining them. Classic no backups case.
Now I had to convert all the images to my screen resolution. I had the option of blowing up the comics to `1366x768`
or to put the comics at the center of a `1366x768` sized image. I chose the blowing
up, obviously, because it was easier.


Generating the blown up images in `xkdcd_comics_full_png`
{% highlight python %}
#!/usr/bin/env python
import os
from random import randint
from subprocess import Popen, PIPE,call
p = Popen("ls ~/pro/xkcd/xkcd_comics_png/*", stdout=PIPE, shell=True)
result=p.communicate()[0].split('\n')[0:-1]
#print(result)
for x in result:
    dir_name=os.path.dirname(x)
    #print(dir_name)
    base=os.path.basename(x)
    name=os.path.splitext(base)[0]
    call(["convert","-resize","1366x768!",x,"xkcd_comics_full_png/"+base])
{% endhighlight %}

Armed with the blown up images, I proceeded to write a script named `xkcd_i3lock.py`
to fire up `i3lock` with a random xkcd image. 
{% highlight python %}
#!/usr/bin/env python
from random import randint
from subprocess import Popen, PIPE,call
p = Popen("ls ~/pro/xkcd/xkcd_comics_full_png/*.png", stdout=PIPE, shell=True)
result=p.communicate()[0].split('\n')[0:-1]
n=len(result)
comic=result[randint(0,n)]
#saving the choice for reference
f = open('/home/sourya/pro/xkcd/choices.txt', 'a')
f.write(comic+"\n")
f.close()
call(["i3lock","-i",comic,"-t"])
{% endhighlight %}
I could have used the choices to subsequently remove the used
images from consideration in the future. But in around 1400 images, the 
chance of repetitive choices is small. Maybe I will add that when I start
seeing the same images after some time.
To manually fire up the screen from the keyboard, define a binding in i3
{% highlight bash %}
bindsym $mod+q exec ~/.i3/xkcd_i3lock.py
{% endhighlight %}
Now calling `xautolock` to call the script on a timeout or a gesture.
{% highlight  bash%}
#Put this in the startup 
xautolock -time 10 -detectsleep -locker "~/.i3/xkcd_i3lock.py" -notify 10 -notifier "notify-send 'Locking'" -corners -+00 -cornerdelay 10 -cornerredelay 10 &
#If you are using i3 put this in the config
#exec --no-startup-id xautolock -time 10 -detectsleep -locker "~/.i3/xkcd_i3lock.py" -notify 10 -notifier "notify-send 'Locking'" -corners -+00 -cornerdelay 10 -cornerredelay 10 &
{% endhighlight %}

An excerpt from the man pages of `xautolock`.
> -time           Specifies the primary timeout interval. The default is 10 minutes, the minimum is 1 minute, and the maximum is 1 hour.

>-locker         Specifies the locker to be used. The default is xlock. Notice that if locker contains multiple words, it must be  specified
               between  quotes.   In  order  to  use your PATH to locate the program, xautolock feeds the locker command to /bin/sh, so it
               should be understandable for whatever shell your /bin/sh is. Because this typically is a Bourne  shell,  ~  expansion  most
               likely will not work.

>-corners        Define special actions to be taken when the mouse enters one of the corners of the display.  The  default  is  0000,  which
                       means that no special action is taken.

>-cornerdelay    Specifies the number of seconds to wait before reacting to the mouse entering a '+' corner. The default is 5 seconds.

>-cornerredelay  Specifies  the  number of seconds to wait before reacting again if the current locker exits while the mouse is sitting in a
               '+' corner. The default is for altsecs to equal secs.

>-notifier       Specifies the notifier to be used. The default is none. This option is only useful in conjunction with -notify. Notice that
                       if notifier contains multiple words, it must be specified between quotes.  In order to use your PATH to locate the program,
                       xautolock feeds the notifier command to /bin/sh, so it should be understandable for whatever shell your /bin/sh is. Because
                       this typically is a Bourne shell, ~ expansion most likely will not work.

>-bell           Specifies  the  loudness of the notification signal in the absence of the -notifier option. The default is 40 percent. This
                 option is only useful in conjunction with -notify.

Using `-+00` int the `corners` option means putting the mouse in the
topright corner fires up the lock and putting the mouse in the top left
corner prevents the lock being fired up even after inactivity (useful when
watching movies).


Here is the ugly yet beautiful result.
![alt tag](/xkcd_1.jpg)
![alt tag](/xkcd_2.jpg)

















