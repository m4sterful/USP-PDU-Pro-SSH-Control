# USP-PDU-Pro-SSH-Control
Findings regarding controlling a Unifi USP-PDU-PRO via SSH

tldr; You can control the USP-PDU-Pro from SSH and probably disconnect it entirely from reporting back to the Unifi controller. This is a work in progress.

Script: get_pwr_usage.sh
Details: gets the current overall power usage on the USP-PDU-Pro

Usage: 
```
get_pwr_usage.sh
35.108W / 1875W
```
Script: set_outlet.sh
Details: turns an outlet on or off. 

Usage: 
```
set_outlet.sh 5 disabled
Outlet 5 state updated to disabled.
```

## Details

Having excitedly purchased a USP-PDU-Pro, I found it a little difficult to figure out where I would put it.

On the one hand, the features are in many ways comparable to the kind of PDU we would find in a data centre, including accurate per-outlet and total power measurement and no less than 16 web controllable outlets (!!). The closest thing I can find to this unit are some by APC and Tripp Lite. I can't find any 15A switched rack PDU of any outlet count available for less than $1000, let alone 16. 

Except I wouldn't dare run Unifi in a critical rack or data centre - it's strictly small to medium office equipment in this author's opinion, with a cloud interface that exposes lots of possible holes I don't like to think of. Yet despite the great price for data centre standards, at $373 Canadian It's way too expensive to use in most homes, whose alternative choice is a $10-$60 power bar. 

Still, after playing with it for a while I kept thinking - if only this unit was in the now mostly forgotten edgerouter line I could certainly see using this in a proper rack! 

But then again, the unit is just a linux box, isn't it? Let's SSH in and see. Actually, we soon see it's just a customized version of openWRT! From... 2018?!

  ```
USP-PDU-Pro-US.6.5.59# cat /etc/openwrt_release
DISTRIB_ID='LEDE'
DISTRIB_RELEASE='17.01.6'
DISTRIB_REVISION='r3979-2252731af4'
DISTRIB_CODENAME='reboot'
DISTRIB_TARGET='ramips/mt76x8'
DISTRIB_ARCH='mipsel_24kc'
DISTRIB_DESCRIPTION='LEDE Reboot 17.01.6 r3979-2252731af4'
DISTRIB_TAINTS='no-all mklibs busybox'
```

Cool, maybe I can use this in a rack after all. I need this device to do a few key things:

1. Control the outlets, by number, on command. (COMPLETE)
2. Tell me the electrical use of the unit on demand. Actually, this is displayed on the screen, but it would be nice to get that remotely as well. (COMPLETE)
3. Tell me the electrical use of a particular outlet. Again, you can see it on the screen (NOPE)
4. Run no un-needed services and do not attempt to adopt or alert anything when it starts - basically port 22 should be the only way I talk to this unit. This is a power bar, we need exactly zero other services to get ourselves in trouble with. (BIG NOPE)

Status - 
1. The outlets are controlled by the service /bin/powerd. To control an outlet via SSH we just need to edit /var/run/powerd.conf and set the outlet to the correct state, enabled or disabled, then run kill -SIGHUP `pidof powerd`.
   
Of course this is easier as a script. I have created one to do that called set_outlet.sh. Simply ssh in and drop the script in your /bin folder, then run the script to change the outlet status. Note that ports 1-4 refer to the USB-C ports! Port 5 is the first outlet.

Example: 
```
USP-PDU-Pro-US.6.5.59# set_outlet.sh 5 disabled
Outlet 5 state updated to disabled.
```
2. If we run lcm-ctrl -t dump command we can get the primary details sent to the screen, which includes the "outlet_used" value. This gives us the current power usage for the device, along with the total available. Use the script get_pwr_usage.sh for that.

Example: 
```
USP-PDU-Pro-US.6.5.59# ./get_pwr_usage.sh
35.108W / 1875W
```
3. Haven't figured that one out as of 12/12/23.

4. Haven't figured that one out as of 12/12/23. I can do this by disabling mcad (which gets and applies config updates from the system and likely reports back to the unifi controller), mca-monitor (assume related to mcad), logread (log reporting), and utermd (remote debug), but this is on a tmpfs. The modifications should be packaged into a firmware file and uploaded to make all this perminant, otherwise it will erase on reboot. TBD. 


