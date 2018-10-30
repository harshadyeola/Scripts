#!/bin/bash
iptables -A FORWARD -p all -d vimeo.com -j REJECT
iptables -A FORWARD -p all -d adobe.com -j REJECT
iptables -A FORWARD -p all -d www.adobe.com -j REJECT
iptables -A FORWARD -p all -d microsoft.com -j REJECT
iptables -A FORWARD -p all -d www.microsoft.com -j REJECT
iptables -A FORWARD -p all -d toggle.www.ms.akadns.net -j REJECT
iptables -A FORWARD -p all -d g.www.ms.akadns.net -j REJECT
iptables -A FORWARD -p all -d lb1.www.ms.akadns.net -j REJECT
iptables -A FORWARD -p all -d youtube.com -j REJECT
iptables -A FORWARD -p all -d www.youtube.com -j REJECT
iptables -A FORWARD -p all -d youtube-ui.l.google.com -j REJECT
iptables -A FORWARD -p all -d dropbox.com -j REJECT
iptables -A FORWARD -p all -d quora.com -j REJECT

# Enable Google Drive which is blocked by youtube
#iptables -A FORWARD -p all -d docs.google.com -j ACCEPT