#!/usr/bin/env bash

# Hotspot AP (Self-Contained)
# Runs hostapd + local DHCP on wlan0.
# Clients get 192.168.1.x from the SBC
# EKH05 will connect and print the IP over serial. Connection is done! Try pinging the IP.
# The easiest way to view the EKH05 web interface is to instead bridge it to your LAN

# Once done, the easiest way to clear all configuration is by restarting the board.
# Then you can run the ./setup_bridged to test out bridging to your LAN.

set -euo pipefail

AP_IF="wlan0"
HOSTAPD_BIN="hostapd_s1g"
HOSTAPD_CFG="./hostapd_s1g.hotspot.conf"
SUBNET_CIDR="192.168.1.1/24"
DHCP_RANGE_START="192.168.1.100"
DHCP_RANGE_END="192.168.1.200"
DHCP_LEASE="12h"


# Auto-select uplink for NAT: prefer br0 if present, else eth0
#UPLINK_IF="$(ip link show br0 >/dev/null 2>&1 && echo br0 || echo eth0)"

echo "[*] Hotspot bring-up on ${AP_IF} (no bridge)."

# 0) Make sure nobody else owns the AP interface
systemctl stop wpa_supplicant 2>/dev/null || true
pkill -x wpa_supplicant 2>/dev/null || true
# Ensure wlan0 isn't enslaved to any bridge (doesn't delete the bridge itself)
ip link set "${AP_IF}" nomaster 2>/dev/null || true

# 1) Start hostapd (hotspot config)
pkill -x hostapd_s1g 2>/dev/null || true
"${HOSTAPD_BIN}" "${HOSTAPD_CFG}" -B

# 2) Give AP interface its IP (idempotent)
ip addr replace "${SUBNET_CIDR}" dev "${AP_IF}"
ip link set "${AP_IF}" up

# 3) DHCP for clients via dnsmasq (only needs to be written once)
sudo tee "/etc/dnsmasq.d/halow.conf" >/dev/null <<EOF
interface=${AP_IF}
bind-interfaces
dhcp-authoritative
dhcp-range=${DHCP_RANGE_START},${DHCP_RANGE_END},${DHCP_LEASE}
dhcp-option=3,${SUBNET_CIDR%/*}     # router = ${SUBNET_CIDR%/*}
dhcp-option=6,${SUBNET_CIDR%/*}     # dns    = ${SUBNET_CIDR%/*}
EOF


systemctl restart dnsmasq

