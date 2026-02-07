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

# Veri Şablonu
class VictimData(BaseModel):
    tc_no: str
    name: str
    phone: str | None = None
    blood_type: str | None = None
    diseases: str | None = None

# --- 1. ANA SAYFA ---
@app.get("/", response_class=HTMLResponse)
async def home(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

# --- 2. KAYIT API ---
@app.post("/register")
async def register_victim(data: VictimData):
    victim, created = await Victim.update_or_create(
        tc_no=data.tc_no,
        defaults=data.dict()
    )
    return {"status": "OK", "message": f"Kayıt Başarılı. Yanındayız {data.name}."}

# --- 3. CAPTIVE PORTAL YAKALAYICILAR ---
@app.get("/generate_204")
@app.get("/hotspot-detect.html")
@app.get("/canonical.html")
@app.get("/success.txt")
async def captive_portal(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

# --- 4. HATA YAKALAYICI (Bağlantıda Kalmayı Sağlar) ---
@app.exception_handler(StarletteHTTPException)
async def custom_http_exception_handler(request, exc):
    if exc.status_code == 404:
        return templates.TemplateResponse("index.html", {"request": request})
    return JSONResponse({"detail": exc.detail}, status_code=exc.status_code)

# Veritabanı Bağlantısı
register_tortoise(
    app,
    db_url="sqlite://db.sqlite3",
    modules={"models": ["src.app.models"]},
    generate_schemas=True,
    add_exception_handlers=True,
)

# --- 5. ÇALIŞTIRMA (HAYATİ KISIM) ---
if __name__ == "__main__":
    import uvicorn
    # host="0.0.0.0" olmazsa telefonlar bağlanamaz
    uvicorn.run(app, host="0.0.0.0", port=9999)