# --- 4. YÖNETİCİ PANELİ (ADMİN) ---
@app.get("/list", response_class=HTMLResponse)
async def admin_dashboard(request: Request):
    # Verileri çek (En son güncellenen en üstte)
    victims = await Victim.all().order_by("-updated_at")
    
    # İstatistikleri hesapla
    critical_count = 0
    help_count = 0
    safe_count = 0
    
    for v in victims:
        if "KRİTİK" in v.diseases:
            critical_count += 1
        elif "YARDIM" in v.diseases:
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
