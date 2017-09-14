#!/bin/bash

# check root
if [ "$(id -u)" != "0" ]; then
	echo "[*] This script must be run as root"
	exit 1
fi

# Configuraciones iniciales
upstream=wlan0
phy=eth0

# levantando interfaz
ifconfig $phy 192.168.246.1/24 up

# configurando iptables
iptables -t nat -F
iptables -F
iptables -t nat -A POSTROUTING -o $upstream -j MASQUERADE
iptables -A FORWARD -i $phy -o $upstream -j ACCEPT
echo '1' > /proc/sys/net/ipv4/ip_forward

# Configurando dnsmasq
cat <<EOF > dnsmasq.conf
interface=$phy
dhcp-range=192.168.246.137,192.168.246.138,12h
dhcp-option=3,192.168.246.1
dhcp-option=6,192.168.246.1
server=8.8.8.8
log-queries
log-dhcp
EOF

dnsmasq -C dnsmasq.conf -d
