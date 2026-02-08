#!/bin/bash
# ARK: FINAL GOLDEN SETUP (Fixed Channel 40 - TR)
# Author: Yusuf Eroğlu

INTERFACE="wlan0"
GATEWAY_IP="192.168.4.1"
PASSWORD="ark12345"

echo "------------------------------------------------"
echo "[!] ARK Sistem (5GHz - KANAL 40) Başlatılıyor..."
echo "------------------------------------------------"

# 1. Kartı ve Servisleri Temizle
systemctl stop hostapd dnsmasq NetworkManager wpa_supplicant 2> /dev/null
killall hostapd wpa_supplicant dnsmasq 2> /dev/null
rm -rf /var/run/hostapd
rm -rf /var/run/wpa_supplicant

# Donanımı sıfırla
nmcli radio wifi off 2> /dev/null
rfkill unblock wifi
ip link set $INTERFACE down
sleep 1
ip link set $INTERFACE up

# 2. DNS Çakışmasını Önle
systemctl stop systemd-resolved
rm -f /etc/resolv.conf
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# 3. IP Ver
ip addr flush dev $INTERFACE
ip addr add $GATEWAY_IP/24 dev $INTERFACE

# 4. Hostapd Ayarı (KANAL 40 - SABİT)
# ACS (Tarama) yok, doğrudan 40. kanaldan ateşliyoruz.
echo "[+] Hostapd ayarlanıyor (Kanal 40 - TR)..."
cat > /etc/hostapd/hostapd.conf <<CONF
interface=$INTERFACE
driver=nl80211
ssid=ARK_MAP_5G
hw_mode=a
# --- KANAL 40 (Pi'nin Seçtiği En Temiz Kanal) ---
channel=40
# -----------------------------------------------
ieee80211n=1
ieee80211ac=1
wmm_enabled=1
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$PASSWORD
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
rsn_pairwise=CCMP
country_code=TR
ieee80211d=1
ieee80211h=1
local_pwr_constraint=3
spectrum_mgmt_required=1
CONF

# 5. Dnsmasq Ayarı
cat > /etc/dnsmasq.conf <<CONF
interface=$INTERFACE
dhcp-range=192.168.4.10,192.168.4.50,255.255.255.0,12h
domain-needed
bogus-priv
address=/generate_204/$GATEWAY_IP
address=/hotspot-detect.html/$GATEWAY_IP
CONF

# 6. Başlat
echo "[+] Servisler başlatılıyor..."
sysctl -w net.ipv4.ip_forward=1 > /dev/null
systemctl unmask hostapd
systemctl restart dnsmasq

# Hostapd'yi arka planda başlat (-B komutu önemli)
hostapd -B /etc/hostapd/hostapd.conf

# 7. Python Uygulamasını Başlat
echo "[+] Web sunucusu başlatılıyor..."
cd /home/yusuf/ARK
nohup python3 -m uvicorn main:app --host 0.0.0.0 --port 9999 > ark_log.txt 2>&1 &

echo "------------------------------------------------"
echo "✅ ARK SİSTEMİ AKTİF (Kanal 40)"
echo "📡 Ağ: ARK_MAP_5G"
echo "ℹ️  Not: Telefonunuzda 5GHz desteği olduğundan emin olun."
echo "------------------------------------------------"