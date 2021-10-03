# Simple-Linux-Honeypot

This will open ports 8000 to 25000. It assumed that this device is behind a NAT, rather than a PAT configuration. This should be configured by forwarding remote ports: 8000-9024 to the local ports: 16000-10048. The reasons for this are:
<br>
1. 1-1024 are root controlled ports and may already have services running on them
<br>
2. If the device does not have root access, it may be difficult to use these ports
<br>
3. root access should be avoided for security.

The file listenerHoneypot.conf is used to configure the honeypot.

<br><br>
This is free and open software. do what you wish with it, however it is only designed for use in local networks as scanning remote IP addresses may get you in trouble.
<br><br>
The following pachages should be installed:
<br>
nc - netcat
netstat - net-tools
nmap - including the scripts: vulscan.nse and nmap-vulners
cat
strings
tail
comm
grep
