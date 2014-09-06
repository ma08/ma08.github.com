---
layout: post
---
I am back to outdo myself at presenting another pointless `bash script` which has the potential to be a disgrace to the programming community. Maybe this will serve as documentation on how one can get carried away while writing code. 

People who access the interwebs behind a `proxy-server` will know the pain when things get slow and you have no clue which `proxy-server` will work out and helplessly refer to the stars' alignment to choose a server. When KGP had one of its [We bring you internet from the 90s](http://hotmeme.net/media/i/d/6/r0W-how-cable-companies-think.jpg) moments, I had decided that there has got to be a way to choose a proxy based on the bandwidth all the proxies were offering. Either there isn't any popular service to do that or my googling skills need serious refinement. So I set out to implement a poor man's method of choosing an optimal `proxy-server` from a multitude of choices and set that as the `System-Wide Proxy`. The script is only for `Linux`.

I have tested this on `Ubuntu 14.04` (I know it's not the linuxest of OSes out there, but it rocks my boat). Identifying the optimal `proxy-server` should work on any Linux distro. Setting the system proxy is specific to `Ubuntu`. 


I used `curl` to download a test file (I chose a random file of 3MB. Replace the url based on your preferences - be sure to test that the download is working throught curl before using it) and got the request time. Choosing the minimum request time among the options, I selected the optimal server. I haven't got the faintest of ideas whether this is theoretically the `optimal` server, but I guess it works for a naive implementation.

Let's call this `proxychooser.sh`
{% highlight bash %}
minind=0 #index for the optimal server
min="100000.000" #minimum of the request times

#Storing the proxy servers' addresses in an array.
#Bonus points if the you extract the addresses from a config file.
proxies=(
"http://144.16.192.213:8080"
"http://144.16.192.216:8080"
"http://144.16.192.217:8080"
"http://144.16.192.218:8080"
"http://144.16.192.245:8080"
"http://144.16.192.247:8080"
"http://10.3.100.211:8080"
"http://10.3.100.212:8080")

#Looping over the array
for (( c=0; c<${#proxies[@]}; c++ ))
do
	var=$(curl --no-sessionid -x "${proxies[c]}"  -o ./proxyfile.pdf -s -w %{time_total}\\n http://www.cred.be/download/download.php?file=sites/default/files/CredCrunch15.pdf)
	#var is the request time (string)
    # -x is used to give the proxy to be used
    # proxyfile is the downloaded dummy
    # replace the url with one of your choice
	echo ${proxies[c]} $var
	#note that all values are in strings. So using bc for comparisions
	# output is "1" for true and "0" for false
	var2=$(echo "$min > $var" | bc)

	# request time is 0.000 when it is not successful
	if [ "$var" != "0.000" ]&&[ "$var2" == "1" ];
	then
		#saving the current minimum
		min=$var
		minind=$c
	fi
done

if [ "$min" == "0.000" ];
then
	echo "Possible network problems, no connection"
	return 0
fi

echo "Best proxy is ----" ${proxies[minind]}


#------Insert Ubuntu specific code below--------


{% endhighlight %}
This gets the optimal proxy server.

I have toiled over an hour googling to find a generic method to set the `System-Wide Http Proxy` on `Linux` which doesn't involve a restart. Using the enivronment variable `http_proxy` with `export` doesn't work at all as it is restricted to that shell/session. Editing files like `/etc/environment` didn't solve anything even when the `network-manager` is restarted. So I had to go with the `Ubuntu` specific approach, apologies to all the pure Linuxers out there if you feel let down. 

A cool dude helped me  on [stackexchange](http://unix.stackexchange.com/questions/152260/set-ubuntu-system-proxy-settings-without-restart-from-commandline) regarding setting the `System-Wide Proxy` on `Ubuntu`. Add the following to the end of the above script `proxychooser.sh`. I have got to admit that I don't fully understand how the following works, will have to dig into `Ubuntu`'s documentation sometime.

If you feel this is overkill, you can always manually set your proxy through GUI after getting the optimal server.

{% highlight bash %}
source ./bus.sh
proxies3=(
"144.16.192.213"
"144.16.192.216"
"144.16.192.217"
"144.16.192.218"
"144.16.192.245"
"144.16.192.247"
"10.3.100.211"
"10.3.100.212")

HTTP_PROXY_HOST=${proxies3[minind]}
HTTP_PROXY_PORT=8080
HTTPS_PROXY_HOST=${proxies3[minind]}
HTTPS_PROXY_PORT=8080

gsettings set org.gnome.system.proxy.http host "$HTTP_PROXY_HOST"
gsettings set org.gnome.system.proxy.http port "$HTTP_PROXY_PORT"
gsettings set org.gnome.system.proxy.https host "$HTTPS_PROXY_HOST"
gsettings set org.gnome.system.proxy.https port "$HTTPS_PROXY_PORT"

sudo sed -i.bak '/http[s]::proxy/Id' /etc/apt/apt.conf
sudo tee -a /etc/apt/apt.conf <<EOF
Acquire::http::proxy "http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/";
Acquire::https::proxy "http://$HTTPS_PROXY_HOST:$HTTPS_PROXY_PORT/";
EOF

sudo sed -i.bak '/http[s]_proxy/Id' /etc/environment
sudo tee -a /etc/environment <<EOF
http_proxy="http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/"
https_proxy="http://$HTTPS_PROXY_HOST:$HTTPS_PROXY_PORT/"
EOF
{% endhighlight %}

Save a file `bus.sh` alongside `proxychooser.sh`. I got this from [stackexchange](http://askubuntu.com/questions/457016/how-to-change-gsettings-via-remote-shell)

{% highlight bash %}
#!/bin/bash

# Remember to run this script using the command "source ./filename.sh"

# Search these processes for the session variable 
# (they are run as the current user and have the DBUS session variable set)
compatiblePrograms=( nautilus kdeinit kded4 pulseaudio trackerd )

# Attempt to get a program pid
for index in ${compatiblePrograms[@]}; do
    PID=$(pidof -s ${index})
    if [[ "${PID}" != "" ]]; then
        break
    fi
done
if [[ "${PID}" == "" ]]; then
    echo "Could not detect active login session"
    return 1
fi

QUERY_ENVIRON="$(tr '\0' '\n' < /proc/${PID}/environ | grep "DBUS_SESSION_BUS_ADDRESS" | cut -d "=" -f 2-)"
if [[ "${QUERY_ENVIRON}" != "" ]]; then
    export DBUS_SESSION_BUS_ADDRESS="${QUERY_ENVIRON}"
    echo "Connected to session:"
    echo "DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS}"
else
    echo "Could not find dbus session ID in user environment."
    return 1
fi

return 0
{% endhighlight %}

Make sure both the scripts are executable by `sudo chmod +x scriptname.sh` and run the `proxychooser.sh` whenever you feel a need to change the proxy.

Here are the `gists` for the working scripts. [proxychooser.sh](https://gist.github.com/ma08/94020d6f960378122779) and [bus.sh](https://gist.github.com/ma08/2d5126421ca3b288ff43)

I am counting on this post's popularity in KGP being minimal. A `Game-Theoretic` analysis(or common sense) would deduce that the `chosen optimal server might no longer be optimal` if the majority of the users opt for that server. Don't disappoint me junta. Be sure to expect some detailed posts on [Game Theory](http://en.wikipedia.org/wiki/Game_theory) in the future. Thanks.

Please point out any gaping mistakes or suggest anything that might improve the approach.

