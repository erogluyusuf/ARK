from fastapi import FastAPI, Request
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse, JSONResponse
from tortoise.contrib.fastapi import register_tortoise
from pydantic import BaseModel
from src.app.models import Victim
import os
from starlette.exceptions import HTTPException as StarletteHTTPException

app = FastAPI(title="ARK Afet Sistemi")

# HTML Şablonları
templates = Jinja2Templates(directory="src/app/templates")

# HTML'deki form verileriyle tam uyumlu Pydantic Modeli
class VictimData(BaseModel):
    tc_no: str
    name: str
    blood_type: str | None = None
    diseases: str | None = None # HTML'deki 'durum' (help, safe, critical) buraya gelir

# --- 1. ANA SAYFA ---
@app.get("/", response_class=HTMLResponse)
async def home(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

# --- 2. KAYIT API (HAYAT KURTARAN VERİ KAYDI) ---
@app.post("/register")
async def register_victim(data: VictimData):
    # update_or_create: Aynı TC ile tekrar girerse bilgisini günceller, yeni kayıt açmaz (Veri kirliliğini önler)
    victim, created = await Victim.update_or_create(
        tc_no=data.tc_no,
        defaults={
            "name": data.name,
            "blood_type": data.blood_type,
            "diseases": data.diseases
        }
    )
    status_msg = "Kayıt Başarılı. Yanındayız." if created else "Bilgileriniz Güncellendi."
    return {"status": "OK", "message": f"{status_msg} {data.name}"}

# --- 3. CAPTIVE PORTAL & 404 YAKALAYICI (BAĞLANTIDA TUTAN SİHİR) ---
@app.exception_handler(StarletteHTTPException)
async def custom_http_exception_handler(request, exc):
    # Kullanıcı yanlış bir URL'ye gitse bile ARK Paneline geri döner
    return templates.TemplateResponse("index.html", {"request": request})

@app.get("/generate_204")
@app.get("/hotspot-detect.html")
@app.get("/canonical.html")
@app.get("/success.txt")
async def captive_portal(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

# VERİTABANI BAĞLANTISI (db.sqlite3)
register_tortoise(
    app,
    db_url="sqlite://db.sqlite3",
    modules={"models": ["src.app.models"]},
    generate_schemas=True,
    add_exception_handlers=True,
)

if __name__ == "__main__":
    import uvicorn
    # Port 9999 üzerinden tüm ağa yayın yapıyoruz
    uvicorn.run(app, host="0.0.0.0", port=9999)