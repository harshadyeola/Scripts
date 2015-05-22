#!.bin/bash
# Facebook Block------ 
for ip in `whois -h whois.radb.net '!gAS32934' | grep /`
do
iptables -A FORWARD -p all -d $ip -j REJECT
done
#End Facebook Block-----