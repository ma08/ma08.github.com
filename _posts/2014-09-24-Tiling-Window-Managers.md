---
layout: post
---
I am delighted to inform you that my [last post on selecting an optimal proxy
server](http://ma08.github.io/Optimal-Proxy-Chooser/) had such an impact that
the [CIC guys have decided(conspired) to introduce a single load balancer](https://www.facebook.com/IIT.Kgp/posts/10152672045405409)
to make sure that people wouldn't run my script and thus saved mankind from 
potential doom. Nice work CIC!!.

This one is going to be about `tiling window managers` - pertaining to Linux. I
have no knowledge of window managers on `Windows`, so you are on your own
regarding that. [Tiling window managers](http://en.wikipedia.org/wiki/Tiling_window_manager)
are great for organizing your screen space coupled with efficient keyboard
bindings. The key to tiling is to not to waste any screenspace(you can have
 floating windows but that's more of an exception). Most of the time, the
windows are nonoverlapping unlike traditional GUI models.  Anyone who prefers to
keep his hands on the keyboard and hates using the mouse should give a shot at
using a window manager with customizable bindings.

Here is a peek on what's in offer. A screen from my `i3 wm`.
![alt tag](http://i.imgur.com/fx83Xxf.png).

I tried both [awesome](http://awesome.naquadah.org/) and [i3](http://i3wm.org/)
and decided to go with `i3` due to its excellent [docs](http://i3wm.org/docs).
`i3` has also got amazing customizability. Configuration can't be easier and
it has got an active [IRC Channel](http://i3wm.org/contact) where you can
head over for help. `i3` has its own learning curve but the descriptive
documentation makes it smooth. 

##Workspaces
A Workspace is something of a virtual desktop where you can organize windows. I
usually have workspaces specific to chat clients, terminals et al. You can
transfer windows between different workspaces. If you are editing a file and
chatting with a friend simultaneously, then you can put both of the windows in a 
workspace for easier navigation back and forth. So think of a workspace as a
dynamic collection of windows. Workspaces are numbered `1,2,3...`. In theory you
can have infinite workspaces, but by default with the keybindings `i3` ships with
you can access 10 workspaces at most (Mod+\<Workspace number\>).
##Tree Stucture
This is at the core of `i3`. The windows in the workspace have a layout in the form
of a recursive tree structure. The tree structure combined with the horizontal
and verticals orientations enable you to have quite complex arrangements of
windows. I am avoiding the exact details involved (as it is already quite well put
in the documentation), [head over
here](http://i3wm.org/docs/userguide.html#_the_tree_consists_of_containers) to
know more about how it works in detail. You need to grasp atleast the basics of
this to know what you are doing regarding the windows' layout/orientation.

##Configuration
Customizability is what sells `i3`. You have got lots of options to get what
feels right to you. Don't expect to fall in love with `i3` right after you
install it. 
You have the configuration files at `~/.i3/`. `~/.i3/config` is the main
configuration file, any other files can be referenced from this file. You put in
all your keybindings, application/workspace specific actions, startup
applications in the `config` file. I will provide snippets from my personal
`config` file in the following sections. I would suggest you to look at popular
configuration files to startoff with. Here's [my configuration
file](https://github.com/ma08/i3-wm-config/blob/master/config). I had forked
some bloke's configuration but in the end most of my configuration ended up
being different. You need to put in your own touch to reap rewards. 
Make it as personal as you can, that's the whole point.

##Keybindings
Before starting off I would like to say a couple of things about how I prefer to
work. As expected, using the mouse is blasphemy. So mouse is the last option.
Another important thing is the position of your hands. The default position is
`asdf` for the left hand and `jkl;` for the right. I hate to move my right hand
to the arrow keys as it messes up with the flow. That's what makes `vim` so
special.  You are always at the default position. You save the  precious
milliseconds wasted by moving your right hand between the default position and
the arrow keys. So this was my motivation when designing the keybindings for
`i3`. I wanted to use keybindings accessible at the default position. So
vimstyle bindings were the way to go, especially as `vim` was already part of my
muscle memory. You need to set the bindings which you feel most comfortable
with.

The keybindings are of the form
{% highlight bash %}
bindsym <binding> <action>
{% endhighlight %}

###Mod key
This is at the heart of the keybindings. The Mod key is used in
combination with other keys for a specific action. `Super(Windows)` and `Alt`
seem to be the popular choices for the Mod key.

{% highlight bash %}
set $mod Mod4
#Mod4 means Super or Windows

#keybindings
bindsym $mod+d exec dmenu_run
bindsym $mod+Shift+c kill
# split in horizontal orientation
bindsym $mod+w split h
# split in vertical orientation
bindsym $mod+v split v
# enter fullscreen mode for the focused container
bindsym $mod+f fullscreen
# change container layout (stacked, tabbed, toggle split)
bindsym $mod+s layout stacking
bindsym $mod+t layout tabbed
bindsym $mod+e layout toggle split
# toggle tiling / floating
bindsym $mod+Shift+space floating toggle
#and a whole lot more

#Access workspace by its number
bindsym $mod+1 workspace 1
bindsym $mod+2 workspace 2
bindsym $mod+3 workspace 3
#and so on

#go to last visited workspace
bindsym $mod+b workspace back_and_forth
{% endhighlight %}

###Vimish Navigation bindings
`i3` ships with the default `jkl;` keys for navigation. But I changed that to
`hjkl`to make it feel like ``vim``. I had changed all the bindings to make
navigation close to `vim`.  I added keybindings to navigate adjacent workspaces
which `i3` doesn't put in it's default config file

{% highlight bash %}
bindsym $mod+h focus left  #focus window on the left
bindsym $mod+j focus down  #focus window below
bindsym $mod+k focus up    #focus window above
bindsym $mod+l focus right #focus window on the right

bindsym $mod+Control+k workspace prev #move to the workspace on the left
bindsym $mod+Control+j workspace next #move to the workspace on the right
bindsym $mod+Control+h workspace prev
bindsym $mod+Control+l workspace next

# move focused window
bindsym $mod+Shift+h move left #move focused window to left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

{% endhighlight %}

The rest of the navigation bindings are similar. [Head over here](https://github.com/ma08/i3-wm-config/blob/master/config) and snoop over all the other navigation bindings. 

###Resize mode
You might be wondering how you would resize the windows without using mouse.
`i3` has a `resize` mode where you use the defined keybindings to change the
windows' dimensions. 
{% highlight bash %}
mode "resize" {
        # These bindings trigger as soon as you enter the resize mode

        bindsym h resize shrink width 3 px or 3 ppt
        bindsym j resize grow height 3 px or 3 ppt
        bindsym k resize shrink height 3 px or 3 ppt
        bindsym l resize grow width 3 px or 3 ppt

        # back to normal: Enter or Escape
        bindsym Return mode "default"
        bindsym Escape mode "default"
}

bindsym $mod+r mode "resize"
{% endhighlight %}
Once resizing needs are finished, you press the `Return`(Enter) key to exit the resize
mode.

###Startup Applications
You can define specific applications to startup in specific workspaces at the
startup.  
{% highlight bash %}
exec --no-startup-id i3-msg 'workspace 1; exec gnome-system-monitor'
exec --no-startup-id i3-msg 'workspace 2; exec rhythmbox'
exec --no-startup-id i3-msg 'workspace 3; exec gnome-terminal'
exec --no-startup-id i3-msg 'workspace 4; exec firefox'
exec --no-startup-id i3-msg 'workspace 8; exec google-chrome'
exec --no-startup-id i3-msg 'workspace 9; exec nautilus'
exec --no-startup-id i3-msg 'workspace 10; exec linuxdcpp'
{% endhighlight %}

###Media Keys
I use `Rhythmbox`for songs and defined keybindings to switch songs, play
and pause.
{% highlight bash %}
bindsym Shift+Control+j exec rhythmbox-client --next
bindsym Shift+Control+k exec rhythmbox-client --previous
bindsym Shift+Control+space exec rhythmbox-client --play-pause
{% endhighlight %}
Note that `exec` is equivalent to running a terminal command. So you can define
a keybinding to execute anything if you can write a terminal(shell) command for it.
This calls for serious exploitation!!.


##Endnote
This is just the basic part. You can have much more complex configurations which
are context based which I haven't discussed. I also haven't touched on the status bar.
[i3status](http://i3wm.org/i3status/) is the status bar displayed at the bottom.
It is also highly customizable. 

Here's a screencast I have created to show you some of the awesome stuff `i3`
is capable of. Observe when the workspace is changing and which window is focused.


<iframe src="https://player.vimeo.com/video/107232089" width="900" height="375" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe> 
All in all window managers make life much more productive - especially for programmers.
If you are dealing with multiple windows(applications) consistently and you are
a keyboard person, using a popular window manager is the logical choice.
It takes effort to get into this paradigm which is definitely worth it. There's no
looking back once you are hooked. Have a look at both
[awesome](http://awesome.naquadah.org/) and [i3](http://i3wm.org/) and decide for
yourselves.

Let me know your opinion on window managers in the comments. Thanks.
