#!/bin/bash

# Renkler
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}### ARK Hotspot Kurulumu Başlatılıyor ###${NC}"

# 1. Paketleri Yükle
apt-get update
apt-get install -y hostapd dnsmasq ifupdown

# 2. Servisleri Durdur
systemctl stop hostapd
systemctl stop dnsmasq

# 3. Statik IP Klasörünü Hazırla (Eksikse oluştur)
mkdir -p /etc/network/interfaces.d

# 4. wlan0 Ayarını Yap (192.168.4.1)
cat <<EOF > /etc/network/interfaces.d/wlan0
auto wlan0
iface wlan0 inet static
    address 192.168.4.1
    netmask 255.255.255.0
EOF

# 5. Arayüzü IP ile Ayağa Kaldır (Kritik Nokta)
ip addr flush dev wlan0
ip addr add 192.168.4.1/24 dev wlan0
ip link set wlan0 up

# 6. DHCP (dnsmasq) Ayarı
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.bak 2>/dev/null
cat <<EOF > /etc/dnsmasq.conf
interface=wlan0
bind-interfaces
dhcp-range=192.168.4.10,192.168.4.100,255.255.255.0,12h
dhcp-option=3,192.168.4.1
dhcp-option=6,192.168.4.1
address=/#/192.168.4.1
EOF

# 7. Hotspot (hostapd) Ayarı (ARK_NET)
cat <<EOF > /etc/hostapd/hostapd.conf
interface=wlan0
driver=nl80211
ssid=ARK_NET
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
wpa_passphrase=ark12345
EOF

# Hostapd Config Yolunu Göster
sed -i 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|g' /etc/default/hostapd

# 8. Servisleri Başlat
systemctl unmask hostapd
systemctl enable hostapd dnsmasq
systemctl restart hostapd dnsmasq

# 9. Docker'ı Emin Olmak İçin Yeniden Başlat
docker compose restart

echo -e "${GREEN}KURULUM BİTTİ! Telefondan ARK_NET ağına bağlanabilirsin.${NC}"