# GW16159 + EKH05 Setup

This repository contains **bringup scripts and configuration files** for setting up a **WPA3 HaLow Access Point (AP)** using the **Gateworks GW16159** radio with the **MorseMicro EKH05 evaluation kit**. 
It has been tested on a Gateworks VeniceFLEX board.

## Usage Modes

1. **Hotspot (Peer-to-Peer AP)**  
   - Creates a simple WPA3 HaLow AP.  
   - Intended for **network evaluation** (e.g., using `iperf3` to test throughput and latency).  

2. **Bridged (LAN Gateway)**  
   - Configures the Gateworks board as a **bridge** between the EKH05 and a LAN.  
   - Useful for connecting the EKH05 to an existing network for viewing the web server for viewing camera/sensors.  

## Documentation

- [Setup Guide](./docs/GW16159_EKH05_Setup.pdf)  

<embed src="./docs/GW16159_EKH05_Setup.pdf" width="100%" height="600px" type="application/pdf">

---
