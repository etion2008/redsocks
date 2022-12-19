#!/bin/sh /etc/rc.common
# Copyright (C) 2006-2011 OpenWrt.org
#
# auto startup script for redsocks2 on OpenWrt
# this file is located in directory /etc/init.d
# rename this file to redsocks

START=99

SERVICE_USE_PID=1
SERVICE_WRITE_PID=1
SERVICE_DAEMONIZE=1

start() {
	echo starting redsocks2...
	/usr/sbin/redsocks2 -c /etc/config/redsocks2

	echo loading redsocks2 firewall rules...
	load_firewall

	echo done.
}

stop() {
	echo stopping redsocks2...
	killall -9 redsocks2

	echo flushing redsocks2 firewall rules...
	flush_firewall

	echo done.
}

load_firewall() {
	# create a new chain named REDSOCKS
	iptables -t nat -N REDSOCKS

	# Ignore LANs IP address
	iptables -t nat -A REDSOCKS -d 0.0.0.0/8 -j RETURN
	iptables -t nat -A REDSOCKS -d 10.0.0.0/8 -j RETURN
	iptables -t nat -A REDSOCKS -d 100.64.0.0/10 -j RETURN
	iptables -t nat -A REDSOCKS -d 127.0.0.0/8 -j RETURN
	iptables -t nat -A REDSOCKS -d 169.254.0.0/16 -j RETURN
	iptables -t nat -A REDSOCKS -d 172.16.0.0/12 -j RETURN
	iptables -t nat -A REDSOCKS -d 192.0.0.0/24 -j RETURN
	iptables -t nat -A REDSOCKS -d 192.0.2.0/24 -j RETURN
	iptables -t nat -A REDSOCKS -d 192.88.99.0/24 -j RETURN
	iptables -t nat -A REDSOCKS -d 192.168.0.0/16 -j RETURN
	iptables -t nat -A REDSOCKS -d 198.18.0.0/15 -j RETURN
	iptables -t nat -A REDSOCKS -d 198.51.100.0/24 -j RETURN
	iptables -t nat -A REDSOCKS -d 203.0.113.0/24 -j RETURN
	iptables -t nat -A REDSOCKS -d 224.0.0.0/4 -j RETURN
	iptables -t nat -A REDSOCKS -d 233.252.0.0/24 -j RETURN
	iptables -t nat -A REDSOCKS -d 240.0.0.0/4 -j RETURN

	# Anything else should be redirected to redsocks's local port
	iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports 1081

	# Apply the rules
	iptables -t nat -I zone_lan_prerouting -j REDSOCKS
}

flush_firewall() {
	iptables -t nat -F REDSOCKS
	sleep 1
	iptables -t nat -D zone_lan_prerouting -j REDSOCKS
	iptables -t nat -X REDSOCKS
}
