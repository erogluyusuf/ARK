#!/bin/bash
echo "[!] GitHub'dan güncel veriler kontrol ediliyor..."
git pull origin main --rebase

echo "[!] Değişiklikler taranıyor..."
git add .

echo "[!] Paket mühürleniyor..."
git commit -m "update: $(date +'%Y-%m-%d %H:%M') otomatik güncelleme"

echo "[!] GitHub'a uçuruluyor..."
git push origin main

echo "[OK] İşlem tamam, her şey GitHub'da!"
