#!/bin/bash
# ARK: Final Secured Setup (STABLE TR 5GHz)
# Author: Yusuf Eroğlu
dene
INTERFACE="wlan0"
GATEWAY_IP="192.168.4.1"
PASSWORD="ark12345"

echo "------------------------------------------------"
echo "[!] ARK Sistem (5GHz - TR STABIL) Başlatılıyor..."
echo "------------------------------------------------"

# 1. Kilitlenen Wi-Fi Kartını Sıfırla (ÖNEMLİ)
# Kart "US/TR" çakışmasından dolayı kilitlendiyse bunu açar.
nmcli radio wifi off 2> /dev/null
rfkill unblock wifi
sleep 2

# 2. Temizlik
systemctl stop hostapd dnsmasq NetworkManager wpa_supplicant 2> /dev/null
killall hostapd wpa_supplicant dnsmasq 2> /dev/null

# 3. DNS Çakışmasını Önle
systemctl stop systemd-resolved
rm -f /etc/resolv.conf
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# 4. NetworkManager'ı Sustur
mkdir -p /etc/NetworkManager/conf.d/
echo -e "[keyfile]\nunmanaged-devices=interface-name:$INTERFACE" > /etc/NetworkManager/conf.d/99-ark-internal.conf

# 5. IP Yapılandırması
ip link set $INTERFACE down
ip addr flush dev $INTERFACE
ip link set $INTERFACE up
ip addr add $GATEWAY_IP/24 dev $INTERFACE

# 6. Hostapd Ayarı (TR Uyumlu 5GHz)
echo "[+] Hostapd ayarlanıyor (Kanal 36 - TR)..."
cat > /etc/hostapd/hostapd.conf <<CONF
interface=$INTERFACE
driver=nl80211
ssid=ARK_MAP_5G
hw_mode=a
channel=36
# Hız Ayarları (AC/Wi-Fi 5)
ieee80211n=1
ieee80211ac=1
wmm_enabled=1
# Şifreleme
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$PASSWORD
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
rsn_pairwise=CCMP
# KRİTİK AYARLAR (Kopmaması İçin)
country_code=TR
ieee80211d=1  # Ülke bilgisini telefona bildir (Bağlantı hızlanır)
ieee80211h=1  # 5GHz güç kontrolünü aç (Hata vermeyi engeller)
local_pwr_constraint=3
spectrum_mgmt_required=1
CONF

# 7. Dnsmasq Ayarı
cat > /etc/dnsmasq.conf <<CONF
interface=$INTERFACE
dhcp-range=192.168.4.10,192.168.4.50,255.255.255.0,12h
domain-needed
bogus-priv
address=/generate_204/$GATEWAY_IP
address=/hotspot-detect.html/$GATEWAY_IP
CONF

# 8. Başlat
echo "[+] Servisler başlatılıyor..."
sysctl -w net.ipv4.ip_forward=1 > /dev/null
systemctl unmask hostapd
systemctl restart dnsmasq

# Hostapd'yi başlat
hostapd -B /etc/hostapd/hostapd.conf

# 9. Python Uygulamasını Başlat
echo "[+] Web sunucusu başlatılıyor..."
cd /home/yusuf/ARK
nohup python3 -m uvicorn main:app --host 0.0.0.0 --port 9999 > ark_log.txt 2>&1 &

echo "------------------------------------------------"
echo "✅ ARK SİSTEMİ AKTİF"
echo "📡 Ağ: ARK_MAP_5G"
echo "⚠️ Not: Eğer ağ görünmezse Pi'yi kapatıp açın."
echo "------------------------------------------------"