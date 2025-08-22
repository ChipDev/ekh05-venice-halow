#!/usr/bin/env bash

# Bridged AP (LAN-Integrated)
# Bridges wlan0 into br0 with eth0 so LAN DHCP serves HaLow clients.
# Clients get LAN IPs and are directly reachable from LAN hosts
# EKH05 serial will output the IP from the DHCP lease
# Devices on LAN can view the EKH05 web interface by visiting http://{EKH05 IP}

# Once done, restarting the SBC is the easiest way to clear all the bridging configuration.
# Then you can safely run ./setup_hotspot or other scripts.

set -euo pipefail

AP_IF="wlan0"
LAN_IF="eth0"
BR="br0"
HOSTAPD_BIN="hostapd_s1g"
HOSTAPD_CFG="/root/hostapd_s1g.bridged.conf"

# Kill any wpa_supplicant processes 
# (we aren't connecting to a network, but instead creating an AP)
systemctl stop wpa_supplicant 2>/dev/null || true
pkill -x wpa_supplicant 2>/dev/null || true

# 1) Create/ensure the bridge exists and eth0 is in it
if ! ip link show "$BR" >/dev/null 2>&1; then
  ip link add name "$BR" type bridge
fi

# Move eth0 under br0
ip addr flush dev "$LAN_IF" || true
ip link set "$LAN_IF" up
ip link set "$BR" up
ip link set "$LAN_IF" master "$BR"

# 2) Start the AP in background (To view detailed messages, remove the -B flag)
"$HOSTAPD_BIN" "$HOSTAPD_CFG" -B

# 3) Done. Your OS (NetworkManager or systemd-networkd) is already doing DHCP on br0.
#    If br0 lacks an address, your system’s network config needs to be told “get DHCP on br0”.
echo "[+] Bridge up; AP started. To view current IPs on br0 execute:"
echo "ip addr show dev br0"

echo "To clear current network bridging configuration, simply reboot the SBC."

