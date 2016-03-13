---
layout: post
---
I am back to subject you with some more obscure stuff. As obscure as it can get.
This is more of documentation than communicating my thoughts with the rest of
the world. With the self deprecation out of the way, let's get to the point.

If you don't feel like reading the wall of text that follows, watch the video at the
end for a TLDR.

For a while I have been using mplayer2 as my default
player due to it's minimal interface. I got this brilliant idea of having a floating video window at the
top right corner such that I can work on something while viewing stuff to
minimize (or maximize I ain't sure) my efficiency. I use [i3](https://i3wm.org/) as my window manager [which I talked about earlier here](http://ma08.github.io/Tiling-Window-Managers/).
Skip the i3 specific parts if you have no idea about it.
I've defined a binding to float a window, set it to a specific size and place it in the top right corner.
Also making it a sticky window to make it stay there when moving across workspaces
{% highlight bash %}
bindsym $mod+Shift+m floating enable; resize set 320 px 180 px; sticky enable; move window to position 1045 px 0 px
{% endhighlight %}


This is how it works.
![Image alt]({{ site.baseurl }}/img/mplayer-floater.png "image title")

After getting used to this, I wanted something like this for youtube videos. 
Some way to extract out the player of youtube and manipulate it in such a way
that I can "work" away with a floating youtube player. I observed that whenever
youtube was in full screen it is placed in an X-window named "plugin-container"
or something. I tried using it to achieve the effect I was after but didn't have
much success with it. I gave up on this quest for a while.

Later while I found  [this](https://www.reddit.com/r/unixporn/comments/49yjjg/oc_maybe_the_closest_thing_to_actual_unix_porn/d0vvp42),
I went off on a tangent (trying to play videos in the form of ascii art) where I stumbled upon a solution to the youtube floater thingy I
wanted. I learned that you could play youtube videos with mplayer using [youtube-dl](https://rg3.github.io/youtube-dl/).
{% highlight bash %}
youtube-dl -q -o- $url | mplayer -cache 8192  -
{% endhighlight %}

Once it starts playing I can make it a floater using my binding I talked about
earlier. This essentially solved my quest for the youtube floater. To use this, it requires having the url
of the youtube video which requires searching for something and getting the
video url. I wanted something more snippy. I combined the youtube floater with a
youtube "I am feeling lucky" thing. It essentially searches for something using
the search term and plays the first result of the search in mplayer. 

It uses [Youtube Data API](https://developers.google.com/youtube/v3/) by Google. Get an API Key to run it yourself.
{% highlight python %}
#!/usr/bin/python

#install https://developers.google.com/api-client-library/python/ , youtube-dl and mplayer

from apiclient.discovery import build
from apiclient.errors import HttpError
from oauth2client.tools import argparser
import os
# Set DEVELOPER_KEY to the API key value from the APIs & auth > Registered apps
# tab of
#   https://cloud.google.com/console
# Please ensure that you have enabled the YouTube Data API for your project.
DEVELOPER_KEY = "API KEY"
YOUTUBE_API_SERVICE_NAME = "youtube"
YOUTUBE_API_VERSION = "v3"
def youtube_search(options):
  youtube = build(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION,
    developerKey=DEVELOPER_KEY)
  # Call the search.list method to retrieve results matching the specified
  # query term.
  search_response = youtube.search().list(
    q=options.q,
    type="video",
    safeSearch="none",
    #location=options.location,
    #locationRadius=options.location_radius,
    part="id,snippet",
    maxResults=options.max_results
  ).execute()
  urls=[]
  for search_result in search_response.get("items", []):
    urls.append("https://youtube.com/v/"+search_result["id"]["videoId"])
  os.system("youtube-dl -q -o- %s | mplayer -cache 4096  - &"%(urls[0]))
if __name__ == "__main__":
  argparser.add_argument("--q", help="Search term", default="Google")
  #argparser.add_argument("--location", help="Location", default="37.42307,-122.08427")
  #argparser.add_argument("--location-radius", help="Location radius", default="5km")
  argparser.add_argument("--max-results", help="Max results", default=25)
  args = argparser.parse_args()
  try:
    youtube_search(args)
  except HttpError, e:
    print "An HTTP error %d occurred:\n%s" % (e.resp.status, e.content)
{% endhighlight %}

I wrote a bash script "youtube-play.sh" to call the python script.
{% highlight bash %}
/path/to/youtube-play.py --q "$1" > /dev/null 2> /dev/null
#I know this is redundant. I could've just used the python script as the only executable.
{% endhighlight %}
adding the folder of this script to the PATH variable in bashrc,
{% highlight bash %}
export PATH=$PATH:~/pro/executable_scripts
{% endhighlight %}
To run it
{% highlight bash %}
$ youtube-play.sh "foo bar"
{% endhighlight %}

I can run the whole jig from my [rofi](https://davedavenport.github.io/rofi/) launcher.

TLDR: Playing youtube videos in a video player and some other stuff.
<iframe src="https://player.vimeo.com/video/158763290" width="500" height="281" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>

Lots of stuff could've have been done differently. I could have stored the
videos on disk such that multiple requests for the same video don't end up
taking unnecessary bandwidth. I could have created an interface using [ncurses](https://www.gnu.org/software/ncurses/) to
navigate the results and select the required video (without using mouse - that's the point
of everything I do) instead of using the first result. 

Maybe some other time if I find the motivation and the time aka never. 

Fin.

P.S. If you are from KGP, don't use youtube if you can find the video on DC.

