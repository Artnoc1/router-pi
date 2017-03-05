#!/bin/bash

cat <<EOF > /etc/rc.local
#!/bin/bash
ifconfig eth0 0.0.0.0
ifconfig eth1 0.0.0.0
brctl addbr bridge0
brctl addif bridge0 eth0
brctl addif bridge0 eth1
ifconfig bridge0 up
tcpdump -s0 -i eth0 -C 50 -w capture-$(date +%a-%d%m%y-%H%M-%S).pcap
EOF

reboot
