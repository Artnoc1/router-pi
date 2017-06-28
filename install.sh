#!/bin/bash

apt-get install apache2 dhcpd dnsmasq hostapd iptables-converter macchanger nmap php7.0 tor -y

sed -i 's#^DAEMON_CONF=.*#DAEMON_CONF=/etc/hostapd/hostapd.conf#' /etc/init.d/hostapd

# tor
cat <<EOF > /etc/tor/torrc
Log notice file /var/log/tor/notices.log
VirtualAddrNetwork 10.192.0.0/10
AutomapHostsSuffixes .onion,.exit
AutomapHostsOnResolve 1
TransPort 9040
TransListenAddress 10.8.0.1
DNSPort 53
DNSListenAddress 10.8.0.1
EOF

touch /var/log/tor/notices.log
chown debian-tor /var/log/tor/notices.log
chmod 644 /var/log/tor/notices.log

update-rc.d apache2 enable
update-rc.d dnsmasq enable
update-rc.d hostapd enable
#update-rc.d tor enable

echo Cisco > /etc/hostname
sed -i 's/kali/Cisco/' /etc/hosts
reboot
