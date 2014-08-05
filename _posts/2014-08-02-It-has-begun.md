---
layout: post
tagline: "Supporting tagline"
tags : [intro, beginner, jekyll, tutorial]
---
So this is my first post on my `blob`. I feel sorry for you if you are reading this as either you have delved into the depths of the interwebs or you are an acquaintance of mine who was oblidged to click on the link due to my aggressive publicising the shit out of this utter crap of a blob.

`Disclaimer: The code sample gems I provide might not be the best practices in the programming jargon.`<br />
`Feel free to comment if you can suggest an improvement.` And sorry for using `disqus`.

You will be forgiven if you think that this site dated 10 years back, when there was no [Ruby on Rails](http://rubyonrails.org), [Angular](https://angularjs.org/) and all the other fancy stuff. Still `static pages are immortal`. Especially if you are are in no position to host/buy a server and stick to [GitHub Pages](https://pages.github.com/) and [hosting provided ](http://cse.iitkgp.ac.in/~skakarla) by [your University](http://iitkgp.ac.in).

With minimal experience in webdesign, I had to pick up a `CMS` which requires little styling . 
I would have loved to give a shot with [Angular](https://angularjs.org/) and [Node](http://nodejs.org/) 
as I have worked on [MEAN Stack](http://mean.io/)(check it out if you ever feel like developing a webapp) as an intern but I don't have the resources to set up a
`node server`. So for now, static pages ftw!

After hours of frantic googling, I have decided to go on with [JekyllBootstrap](http://jekyllbootstrap.com/) for my attempt of a blog, which I will proceed to call `blob`.
It was build to be compliant with [GitHub Pages](https://pages.github.com/) and it was up and running before I knew what I was upto.

{% highlight bash %}
$ git clone https://github.com/plusjade/jekyll-bootstrap.git USERNAME.github.com
$ cd USERNAME.github.com
$ git remote set-url origin git@github.com:USERNAME/USERNAME.github.com.git
$ git push origin master
{% endhighlight %}

If only it was that simple. Getting it onto a `github` page was fine but to use it for my University webpage, man it was a pain in the ass. My webpage is [http://cse.iitkgp.ac.in/~skakarla](http://cse.iitkgp.ac.in/~skakarla) , meaning a subdirectory `~skakarla` on the host `http://cse.iitkgp.ac.in`. No matter what I tried, I couldn't get `jekyll` to configure to host on a subdirectory as it was using `rootish links using "/blah"`. I went through numerous `github` issues, `stackoverflow` questions and nothing worked. So I took the ugly and easy way out and got it work with a combination of `find` and `sed`.

{% highlight bash %}
#this adds the line <base href="http://cse.iitkgp.ac.in/~skakarla"> to the top of every line ending with .html.
#Rest of the gibberish is delimiting the symbols
$ find <foldername> -type f  -name '*html' -printf '%p ' | xargs sed -i '1s/^/<base href=\"http:\/\/cse\.iitkgp\.ac\.in\/~skakarla\/\">\n /'
#This replaces every instance of "/ with ". Because jekyll used root to specify links
#And as I was hosting on a subfolder, everything was screwed
$ find <foldername> -type f  -name '*html' -printf '%p ' | xargs sed -i 's/\"\//\"/g'
{% endhighlight %}

This might not be the right way of things to do but it sure worked. Feel free to point out any [sloth that was dropped on the head as a baby retardation levels in my code](https://lkml.org/lkml/2014/7/24/584).

In the end I didn't use `JekyllBootstrap` at all but it's an awesome setup to startoff with. I used [plain jekyll](http://jekyllrb.com/) and forked off [some bloke's theme](https://github.com/vinitkumar/gcode) I found [on reddit](http://www.reddit.com/r/Jekyll/comments/29j38y/gcode_a_clean_and_simple_theme_for_jekyll_based/) which was just budding. If you feel like using it, don't. I had to change lots of stuff to get it to work. I would advise to pick any of the popular themes.

<br />You might want to [learn a bit about markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) before you delve into `jekyll`. If you use [stackoverflow](http://stackoverflow.com) regularly, you must be acquainted with the basics of `markdown` by now. I hope you are not the kind who just use it without contributing. Instead of browsing 9gag all day, [go over there](http://stackoverflow.com) and help a pour soul or two.

What I found difficult was changing the frontend stuff. I am no good at frontend webdevelopment and it took a lot to get the things right, so I was constantly using themes on the net instead of creating a custom fork off a base theme.

##The `Script`
So I got the gig running for the `github` pages and my University webpage but I had to run those commands before pushing to the University webpage. And I had to maintain two copies of the generated site. I had to `push` it to the repo to update the `github` page(if you ever run out of retarded `commit` messages, [help yourself](https://github.com/ma08/ma08.github.com/commits/master)) and use `ftp` to put it on the University page. I got fed up and have written a tiny `shell script` to do all these things with a single command and not even a password prompt for the authentication with the host.

This script resides in the jekyll `source folder`. The `source folder`, `githubrep folder`, `uni webpagefolder` and `mount dir` are all on the same level in the filesystem.
{% highlight bash linenos %}
jekyll build -d ../<githubrepo folder>#Put the generated site
jekyll build -d ../<uni webpagefolder>#Put the generated site 
find <uni webpagefolder> -type f  -name '*html' -printf '%p ' | xargs sed -i '1s/^/<base href=\"http:\/\/cse\.iitkgp\.ac\.in\/~skakarla\/\">\n /'
find <uni webpagefolder> -type f  -name '*html' -printf '%p ' | xargs sed -i 's/\"\//\"/g'
find <uni webpagefolder> -type f  -name '*html' -printf '%p ' | xargs sed -i "s/'\//'/g"
cd ../<githubrepo folder>
git add -A #staging the files
git commit -m "$1" #Took the commit message as an argument to the script
git push origin master #pushing it to github 
cd ..
rm -rf <mount dir>/* #Deleting the old stuff from the mount folder
#Now comes the fancy stuff. I mount my webpage host folder using sshfs on the <mount dir> which is a local folder.
#This folder should always be empty before mounting
#The echo is to give the password to the password_stdin. I know it's bad to store the password as plain text in a file. So spare me the vile.
echo <your smartass password here> | sshfs skakarla@cse.iitkgp.ac.in:/public_html <mount dir> -o workaround=rename -o password_stdin
#Here onwards changes in <mount dir> get reflected on the actual hosting folder in the server.
rm -rf <mount dir>/* #Deleting the old stuff from server
cp -rf <uni webpage folder>/* <mount dir>/ #Copying the new stuff into the server
sleep 5 #This is put in to allow the copy to complete I am correct.
#Without the sleep the script was trying to unmount without waiting for the copying to finish
fusermount -u <mount dir> #Unmount
{% endhighlight %}

I was fed up of giving the `github` credentials.
{% highlight bash %}
$ git config credential.helper store
#This will store your git repo's username and password
#and never asks for the credentials again
{% endhighlight %}
It is not safe but it was what I wanted.

So with a simple command I get my `blob` to update on the `github` pages and University webpage. [It's magic](http://www.reactiongifs.com/r/mgc.gif).
{% highlight bash %}
$ ./build.sh 'added new post - how not to write a blob post'
#The string is the commit message for the github repo if you weren't paying attention.
{% endhighlight %}
##Plugin Compatibility on Github Pages
One thing to keep in mind is that `github` pages allow you to `push` both the `jekyll` source where the posts are in `markdown` (it will use the source to produce the final site using it's `jekyll` engine, but it is pretty outdated) and the final site itself (all the `html` and stuff). I advise you to use final site - the `_site` folder as the plugins (like `pygments` for code highlighting) don't work when you push the source.
I used the [master branch](https://github.com/ma08/ma08.github.com) for pushing the generated sited and created [another branch](https://github.com/ma08/ma08.github.com/tree/source) for the source.

Again I would like to reiterate that this might not be the right way to do stuff. But the reason I put it was it freaking  `works`. Maybe the code quality will improve over time ( which I am oblidged to say)

So hosting the same site effectively on two url's is retarded as you can always use redirection. But I was willing to solve the use case using a different approach (atleast that's what I told myself).

##Disqus comments across both the sites
On a finishing note, as I am hosting the same site on two places, the `disqus` comments might lead to confusion if at all someone cared to comment. So to make things easy for that blessed soul I made sure the comments are reflected in both the sites.
`disqus_identifier` is the trick.
{% highlight html linenos %}
<div id="disqus_thread"></div>
<script type="text/javascript">
  /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
  var disqus_shortname = '{{ site.disqus_shortname }}'; // required: replace example with your forum shortname
  var disqus_identifier = '{{page.path}}'; //This is the magic part.
  //Make sure this is same for both the pages (posts) so you can comment across both the pages
  //I used the post path.
  /* * * DON'T EDIT BELOW THIS LINE * * */
  (function() {
    var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
    dsq.src = 'http://' + disqus_shortname + '.disqus.com/embed.js';
    (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
  })();
</script>
<noscript>Please enable JavaScript to view the <a href="http:/disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
<a href="http:/disqus.com" class="dsq-brlink">comments powered by <span class="logo-disqus">Disqus</span></a>
{% endhighlight %}

Thanks.

