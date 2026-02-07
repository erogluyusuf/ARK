#!/bin/bash
echo "[!] Değişiklikler taranıyor..."
git add .
echo "[!] Paket mühürleniyor..."
git commit -m "update: $(date +'%Y-%m-%d %H:%M') otomatik güncelleme"
echo "[!] GitHub'a uçuruluyor..."
git push origin main
echo "[OK] Tüm değişiklikler artık GitHub'da canlı!"
