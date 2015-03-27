---
layout: post
---
The title should have been something like
>Never go full localhost when deploying.

which isn't as clickbaity as the current one (I hope).

The following wall of text outlines a recent FU of mine in the most
incoherent way possible.

Recently, we (team of 4)
have participated in a hackathon by IBM which required you to use [Bluemix](https://console.ng.bluemix.net/),
a cloud platform for deploying/managing apps and services. We used `node` and
`mongoDB`(hey it was just a hackathon) on the
server side. To do that, `Bluemix` gives you environment variables for deploying
the server. A snippet of the code they provided for using node on bluemix
> var host = (process.env.VCAP_APP_HOST || 'localhost');

which means the host address will be obtained from the environment variable IBM
provides or will be `localhost`  when testing locally. Everything went
swimmingly and though we couldn't connect to each other's machines (using local
IP addresses) when
deploying locally, I didn't think much about it as the server IBM provided was
working fine and we adhered to the golden rule of web development in KGP
>When in doubt, blame the proxy.

For people outside KGP: we have all the traffic going through a proxy server
which is irrationally blamed for every single problem which concerns a computer.

The hackathon ended and the result was quite good. Another hackathon came up,
this time by `Microsoft` and we have decided to go with the same idea, albeit with the addition
of some cool new features. We "simply" had to
change the interface from the webapp to Microsoft's store app. Being the backend
guy, I was ecstatic as it meant we would be using the same server code and I
would have to write less than 50 lines of code to implement the new features.

The rest of the post outlines our struggles to get the server runnning. 


As `mongoDB` wasn't available in the subscription `Microsoft` provided, we chose
`Ubuntu on Azure's VM` for deploying the server. Once we setup the VM, we started installing the
required software to start the server. Everything installed blazing fast and it
was time for action. We have used the port `3000` for the server and we couldn't
connect to it. After a bit of googling and discussing with Microsoft's
mentors on site, we got to know that we had to add an [endpoint](azure.microsoft.com/en-in/.../articles/virtual-machines-set-up-endpoints/) to direct the traffic to `3000` port internally. We defined a mapping `3000` to `3000` and it
didn't work.
>When in doubt, blame the proxy.

So we figured that as the proxy in KGP allows traffic to go through only the
ports `80` and `443`, we created an endpoint from `80` to `3000`. No luck.
We have officially exhausted our option of blaming the proxy as we were using
the public port `80` and we couldn't connect even when using `tor`.
So we turned our blame lights on `Microsoft`. We thought
something might be wrong with their endpoint setup so went on "debugging" the
thing for 3-4 hours. We changed the server port to `80` and defined an endpoint
from `80` to `80` (running the server on port `80`) and tried many other variations.
No luck. We have spent around 5 hours on this issue meanwhile the guys developing the frontend were trying to figure out
how to develop the interface for a Windows' Store app and needed our help. In this duration of 5
hours we even went to the extent of creating another VM on Azure and tried to
ping one machine from the other - we were running out of things to do.

Another aspect of this bug was when running locally connecting to `localhost`
worked but not the local IP address of the machine. We decided the local
IP part was due to the proxy (which was partly true). I will touch on that
later.

The guys working on the frontend were getting pissed off with our antics. I mean
how hard it can get to deploy a server. They wanted to discuss the interface of
the app while we were busy changing ports and messing around with VMs. We consulted the
mentors and they had suggested the endpoint thing and another thing called [ACL](http://azure.microsoft.com/en-in/documentation/articles/virtual-machines-set-up-endpoints/#manage-the-acl-on-an-endpoint),
which I don't even have the energy to write about. The mentors didn't have many
ideas as were running a linux VM.
At this point, we were like `fuck it, we will go all local` and considered the
choice of running it locally. But as I mentioned earlier, we couldn't even get
to connect to the machine running locally using local IP address - even after disabling
the proxy. So the only option left was to deploy the server and present the app
on the same machine and it wasn't possible as we had no clue how to run/setup
`mongoDB` and `node` on Windows - so this was never really an option. So we had
to continue debugging this nasty "bug".

We have finally decided that the logical thing to do next was
to change the location of testing it. Hey, when you are getting bad results,
some parameter needs to be changed and we chose to change the location as the
lab we were in had its network configuration somewhat changed so we were a bit
doubtful about it. We went to a different lab and started doing the same thing
with no variation in results. So after fucking around for 6 hours, `we finally thought
something might be wrong with our code instead of blaming the proxy or Microsoft
or the unvierse`. We have independently reached the conclusion that using the
address `localhost` might be the problem.

I didn't think much about this earlier as being the layman I am, I thought any
requests coming to the machine (on different addresses - local, global etc) would be
received by your server when using `localhost` as the host. Boy, I couldn't have been more wrong. `localhost` is
meant for local testing. That's it. You can't access a computer running a server
on `localhost` from an external machine. You can't access the server from
the same machine using the local IP.
> localhost is a hostname that means this computer and may be used to access the computer's own network services via its loopback network interface. Using the loopback interface bypasses local network interface hardware. The local loopback mechanism may be useful for testing software during development, independently of any networking configurations. For example, if a computer has been configured to provide a website, directing a locally running web browser to http://localhost may display its home page.
>On most computer systems, "localhost" resolves to the IP address 127.0.0.1, which is the most commonly used IPv4 loopback address, and to the IPv6 loopback address ::1.

This means that whenever you use `localhost` or `127.0.0.1` to run a server, you
can't access the server from other machines.

We finally found on `stackexchange` that the answer to all our problems was
using `0.0.0.0`
>In the Internet Protocol version 4 the address 0.0.0.0 is a non-routable meta-address used to designate an invalid, unknown or non applicable target. To give a special meaning to an otherwise invalid piece of data is an application of in-band signaling.
>Uses include:

>* The address a host claims as its own when it has not yet been assigned an address. Such as when sending the initial DHCPDISCOVER
  packet when using DHCP.

>* The address a host assigns to itself when address request via DHCP has failed, provided the host's IP stack supports this. This usage has been replaced with the APIPA mechanism in modern operating systems.

>* A way to specify "any IPv4-host at all". It is used in this way when specifying a default route.

>* A way to explicitly specify that the target is unavailable.[1]

>* A way to specify "any IPv4 address at all". It is used in this way when configuring servers (i.e. when binding listening sockets).   This is known to TCP programmers as INADDR_ANY. (bind(2) binds to addresses, not interfaces.)

This means when you run a server using `0.0.0.0` as the host address it
listens (most of the times) on all the addresses on the machine - `localhost`, `local IP`, `global IP`. If
you are deploying a server, it is better to use the `global IP` of the machine
rather than using `0.0.0.0`. But as `Azure` provided us two IP addresses - a local IP - 
in the network of the VMs and a global, public IP. We just chose to use `0.0.0.0`
without dealing with any intricacies as we already had spent a lot of time
getting it solved. We first tested it locally and checked if we could connect to
the server running on a different machine. We couldn't at first. The new found hope
we had quickly started to transform into rage. Though we were unsure of using our
`proxy card`,
>When in doubt, blame the proxy.

 we disabled the proxy and tried to connect using the local IP address.
 It worked. Finally. The guys maintaining the proxy should direct local IP addressess
to right place and save us the hassle.  We deployed it on the VM and it worked. Clean as a whistle.
Changing `localhost` to `0.0.0.0` was the answer and we took more than 6 hours for that.

So I have acquired a quantum of knowledge I should have possessed years ago
at the expense of 6 precious hackathon hours.

Don't judge me. No one is immune  from bouts of stupidity.





