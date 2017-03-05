#!/bin/bash

# configs
phy=wlan0

cat <<EOF > /etc/hostapd/hostapd.conf
interface=$phy
driver=nl80211
ssid=Free Wifi
bssid=DD:3E:A8:A4:A2:8F
EOF

# iptables rules
cat <<EOF > iptablescaptive
iptables -t nat -A PREROUTING -i $phy -p udp --dport 53 -j DNAT --to 10.0.0.1
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 10.0.0.1
iptables -P FORWARD DROP
EOF

iptables-converter -s iptablesrules > /etc/iptables.rules
rm iptablesrules

# dnsmasq configs
cat <<EOF > /etc/dnsmasq.conf
log-facility=/var/log/dnsmasq.log
interface=$phy
listen-address=10.0.0.1
bind-interfaces
bogus-priv
dhcp-range=10.0.0.100,10.0.0.250,12h
dhcp-option=3,10.0.0.1
dhcp-option=6,10.0.0.1
#no-resolv
log-queries
EOF

# boot configs
cat <<EOF > /etc/rc.local
#!/bin/bash
ifconfig $phy 10.0.0.1/24 up
iptables-restore < /etc/iptables.rules
echo '1' > /proc/sys/net/ipv4/ip_forward
EOF

# Create new interfaces file
cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

# Remove if you don't want static IP
allow-hotplug $phy
iface $phy inet static  
    address 10.0.0.1
    netmask 255.255.255.0
    network 10.0.0.0
    broadcast 10.0.0.255
#   wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
EOF

echo "Turning of power saving for $phy"
iwconfig $phy power off

# Tell DHCPD to ignore wireless int. Handle with hostapd
DENY="denyinterfaces $phy"
if grep -Fxq "$DENY" /etc/dhcpcd.conf
then
    echo "Denyinterfaces already found in dhcpd.conf"
else
    echo $DENY >> /etc/dhcpcd.conf
    service dhcpcd restart
    ifdown $phy; ifup $phy
fi

reboot
