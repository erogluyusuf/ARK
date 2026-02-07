# ARK: Autonomous Resilient Kommunikation System
**Version:** 0.1.0-alpha  
**Platform:** Raspberry Pi 5 / Broadcom BCM2712  
**OS:** Ubuntu 24.04 LTS (GNU/Linux 6.8.0-1045-raspi aarch64)  
**Status:** Mission-Critical / Active Development

## 1. TECHNICAL OVERVIEW
ARK is a decentralized communication and logistics orchestration layer designed for high-availability in zero-connectivity environments. The system leverages containerized microservices to provide local network sovereignty, geospatial data distribution, and resilient protocol handling.

## 2. SYSTEM ARCHITECTURE
The system is built on a hardened Linux stack, optimized for the ARM64 architecture:

* **Networking Layer:** Custom `hostapd` and `dnsmasq` integration to override regulatory constraints and establish an autonomous 802.11 Access Point.
* **Application Layer:** FastAPI-based core service running under Uvicorn ASGI server, providing RESTful API interfaces for local clients.
* **Infrastructure:** Dockerized environment for service isolation and failover management.
* **Data Persistence:** Local SQLite WAL (Write-Ahead Logging) mode for robust data integrity under intermittent power scenarios.

## 3. CORE PROTOCOLS & SERVICES
* **Autonomous AP:** Automatic 2.4GHz/5GHz band negotiation and IPAM (IP Address Management).
* **Offline Registry:** Localized dependency mirroring (wheels/vendor) to ensure deployment without external WAN access.
* **Geospatial Engine:** Local tile server and mapping services for search and rescue navigation.

## 4. DEPLOYMENT & INITIALIZATION
ARK is designed for **Offline-First** deployment. All runtime dependencies must be localized before field operations.

### Pre-deployment Synchronization:
```bash
# Update local wheel registry
pip download -r requirements.txt -d wheels/

# Build hardened container image
docker compose build --no-cache --network=host
```

### Field Initialization:
```bash
# Execute system-wide hardware orchestration
sudo ./setup.sh
```
## 5. NETWORK SPECIFICATIONS
* **SSID: ARK_MAP**
* **Gateway Address: 192.168.4.1**
* **Core API Port: 9999**
* **Communication Protocol: TCP/IP over local 802.11 mesh**

## 6. COMPLIANCE & SECURITY
ARK handles mission-critical data. The architecture follows the principle of least privilege within Docker namespaces. Security audits for local peer-to-peer data exchange are ongoing.

## 7. MAINTENANCE & SUPPORT
Developed by Yusuf Eroğlu. This project is maintained as a technical framework for disaster resilience.

##NOTICE: This software is intended for use in environments where public infrastructure is unavailable. All hardware parameters are optimized for Raspberry Pi 5.












