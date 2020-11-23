# wireguard-iptables

### Usage

```
sh setup.sh          # Apply the rules with defaults
sh setup.sh -i=tun0  # Apply the rules with -inner=tun0
```

### Flags

- `-i or --inner`: Inner interface, usually `wg0`. (Default: `wg0`)
- `-o or --outer`: Outer interface, usually `eth0`. (Default: `eth0`)


### Containes the following rules (with default flags)

```
#Flush iptables
iptables -F
iptables -X

#Allow Loopback Connections
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#Allow Established and Related Incoming Connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

#Allow Established Outgoing Connections
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT

#Drop Invalid Packets
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

#Allow Incoming SSH from Specific interface
iptables -A INPUT -p tcp -i wg0 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -o wg0 -m conntrack --ctstate ESTABLISHED -j ACCEPT

#Allow traffic from wg0
iptables -A INPUT -i wg0 -j ACCEPT
iptables -A OUTPUT -o wg0 -j  ACCEPT

#Drop all packet
iptables -A INPUT -i eth0 -j DROP
iptables -A INPUT -i eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -d 0.0.0.0/24 -j DROP
```
