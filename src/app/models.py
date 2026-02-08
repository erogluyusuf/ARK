from fastapi import FastAPI, Request
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse
from tortoise.contrib.fastapi import register_tortoise
from pydantic import BaseModel
from src.app.models import Victim
from starlette.exceptions import HTTPException as StarletteHTTPException
import datetime

app = FastAPI(title="ARK Afet Sistemi")

# HTML Dosyalarının Yeri
templates = Jinja2Templates(directory="src/app/templates")

# --- HTML'den Gelen Veri Kalıbı (Pydantic) ---
class VictimInput(BaseModel):
    tc_no: str
    name: str
    blood_type: str | None = None
    diseases: str # HTML formunda 'durum' (safe, help, critical) buraya geliyor

# --- 1. ANA SAYFA (VATANDAŞ EKRANI) ---
@app.get("/", response_class=HTMLResponse)
async def home(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

# --- 2. YÖNETİCİ PANEKİ (KOMUTA MERKEZİ) ---
@app.get("/list", response_class=HTMLResponse)
async def admin_dashboard(request: Request):
    # En son güncellenen veriler en üstte olacak şekilde çek
    victims = await Victim.all().order_by("-last_seen")
    
    # İstatistikleri hesapla
    critical_count = 0
    help_count = 0
    safe_count = 0
    
    for v in victims:
        if v.diseases and "KRİTİK" in v.diseases:
            critical_count += 1
        elif v.diseases and "YARDIM" in v.diseases:
            help_count += 1
        else:
            safe_count += 1

    return templates.TemplateResponse("admin.html", {
        "request": request,
        "victims": victims,
        "critical_count": critical_count,
        "help_count": help_count,
        "safe_count": safe_count
    })

# --- 3. KAYIT API (VERİ İŞLEME) ---
@app.post("/register")
async def register_victim(data: VictimInput, request: Request):
    # İstemcinin IP adresini yakala
    client_ip = request.client.host
    
    # HTML'den gelen kısa kodları (safe, help) insan diline çevir
    guvende_mi = False
    durum_metni = "BİLİNMİYOR"

    if data.diseases == "safe":
        guvende_mi = True
        durum_metni = "İYİYİM / GÜVENDEYİM"
    elif data.diseases == "help":
        guvende_mi = False
        durum_metni = "YARALI / YARDIM LAZIM"
    elif data.diseases == "critical":
        guvende_mi = False
        durum_metni = "KRİTİK - ENKAZ ALTINDA"

    # Veritabanına Kaydet veya Varsa Güncelle
    # update_or_create: TC No aynıysa üzerine yazar, yoksa yeni oluşturur.
    victim, created = await Victim.update_or_create(
        tc_no=data.tc_no,
        defaults={
            "name": data.name,
            "blood_type": data.blood_type,
            "diseases": durum_metni,      # Metin olarak durumu yaz
            "is_safe": guvende_mi,        # İstatistik için True/False
            "wifi_ip": client_ip,         # O anki IP adresi
            "last_seen": datetime.datetime.now() # Şu anki zaman
        }
    )
    
    msg_prefix = "Kayıt Alındı." if created else "Bilgiler Güncellendi."
    return {"status": "OK", "message": f"{msg_prefix} Yanındayız, {data.name}."}

# --- 4. CAPTIVE PORTAL (YAKALAYICI) ---
# Telefonların "Wi-Fi'da internet yok" kontrolünü kandırıp sayfaya yönlendiren kısım
@app.exception_handler(StarletteHTTPException)
async def custom_http_exception_handler(request, exc):
    return templates.TemplateResponse("index.html", {"request": request})

@app.get("/generate_204")
@app.get("/hotspot-detect.html")
@app.get("/canonical.html")
@app.get("/success.txt")
@app.get("/ncsi.txt")
async def captive_portal(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

# --- VERİTABANI BAĞLANTISI ---
register_tortoise(
    app,
    db_url="sqlite://db.sqlite3",
    modules={"models": ["src.app.models"]},
    generate_schemas=True,
    add_exception_handlers=True,
)

if __name__ == "__main__":
    import uvicorn
    # 0.0.0.0 ile tüm ağa açıyoruz, Port 9999
    uvicorn.run(app, host="0.0.0.0", port=9999)