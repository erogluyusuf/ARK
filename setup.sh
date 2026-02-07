#!/bin/bash

# ARK: Autonomous Resilient Kommunikation - System Setup
# Author: Yusuf Eroğlu

echo "[!] ARK Sistem Kurulumu Başlatılıyor..."

# 1. Gerekli Paketlerin Kontrolü ve Kurulumu
sudo apt-get update
sudo apt-get install -y hostapd dnsmasq rfkill net-tools iw

# 2. IP Yönlendirme (İnternet Paylaşımı İçin)
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf

# 3. Wi-Fi Kartını (wlan0) Özgürleştirme
# NetworkManager'ın wlan0'ı kurcalamasını engelliyoruz
echo -e "\n[keyfile]\nunmanaged-devices=interface-name:wlan0" | sudo tee -a /etc/NetworkManager/NetworkManager.conf
sudo systemctl reload NetworkManager

# 4. Hostapd ve Dnsmasq Konfigürasyonlarını Taşıma
# Repodaki hazır config dosyalarını sistem dizinlerine kopyalıyoruz
sudo cp ./config/hostapd.conf /etc/hostapd/hostapd.conf
sudo cp ./config/dnsmasq.conf /etc/dnsmasq.conf

# 5. Kartı Sıfırla ve IP Ata
sudo rfkill unblock wifi
sudo ip link set wlan0 down
sudo ip addr flush dev wlan0
sudo ip addr add 192.168.4.1/24 dev wlan0
sudo ip link set wlan0 up

# 6. Servisleri Başlat
sudo systemctl unmask hostapd
sudo systemctl enable hostapd dnsmasq
sudo systemctl restart hostapd dnsmasq

# 7. Docker Konteynerlerini Başlat
docker compose up -d --build

echo "[OK] ARK Sistemi Hazır!"
echo "[!] Wi-Fi: ARK_MAP | Adres: http://192.168.4.1:9999"