#!/bin/bash

cat <<EOF > /etc/network/interfaces
# interfaces(5) file used by ifup(8) and ifdown(8)

# Please note that this file is written to be used with dhcpcd
# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'

# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d

auto lo
iface lo inet loopback

iface eth0 inet manual

allow-hotplug wlan0
iface wlan0 inet manual
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf

#allow-hotplug wlan1
#iface wlan1 inet manual
    #wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
EOF

echo "" > /etc/rc.local
echo "" > /etc/hostapd/hostapd.conf
echo "" > /etc/dnsmasq.conf
echo "" > /etc/tor/torrc


echo kali > /etc/hostname
sed -i 's/Cisco/kali/' /etc/hosts

update-rc.d apache2 disable
update-rc.d dnsmasq disable
update-rc.d hostapd disable
update-rc.d tor disable