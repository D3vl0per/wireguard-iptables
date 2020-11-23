#!/bin/sh

INNER="wg0"
OUTER="eth0"

# Loop through arguments and process them
for arg in "$@"
do
    case $arg in
        -i=*|--inner=*)
        INNER="${arg#*=}"
        shift
        ;;
        -o=*|--outer=*)
        OUTER="${arg#*=}"
        shift
        ;; 
    esac
done

echo "# inner: $INNER"
echo "# outer: $OUTER"

# Flush iptables
iptables -F
iptables -X

# Allow Loopback Connections
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow Established and Related Incoming Connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow Established Outgoing Connections
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Drop Invalid Packets
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# Allow Incoming SSH from Specific interface
iptables -A INPUT -p tcp -i $INNER -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -o $INNER -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow traffic from wg0
iptables -A INPUT -i $INNER -j ACCEPT
iptables -A OUTPUT -o $INNER -j  ACCEPT

# Drop all packet
iptables -A INPUT -i $OUTER -j DROP
iptables -A INPUT -i $OUTER -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o $OUTER -d 0.0.0.0/24 -j DROP
