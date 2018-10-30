#!/bin/bash

# Forward port 2222 => 22
iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 2222 -j DNAT --to 192.168.0.243:22
iptables -t nat -A PREROUTING -p tcp --dport 2222 -j DNAT --to 192.168.0.243:22
iptables -t nat -A POSTROUTING -p tcp -d 192.168.0.243 --dport 22 -j MASQUERADE

# Forward port 80
iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 80 -j DNAT --to 192.168.0.243:80
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to 192.168.0.243:80
iptables -t nat -A POSTROUTING -p tcp -d 192.168.0.243 --dport 80 -j MASQUERADE
