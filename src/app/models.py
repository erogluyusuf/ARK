from tortoise import fields, models

class Victim(models.Model):
    # --- Kimlik Bilgileri ---
    tc_no = fields.CharField(max_length=11, unique=True, pk=True)
    name = fields.CharField(max_length=100)
    phone = fields.CharField(max_length=20, null=True)
    
    # --- Medikal Kritik Bilgiler ---
    blood_type = fields.CharField(max_length=10, null=True) # Örn: A Rh+
    diseases = fields.TextField(null=True)    # HTML'den gelen Durum bilgisi buraya yazılacak
    medications = fields.TextField(null=True) # Kullandığı ilaçlar
    allergies = fields.TextField(null=True)   # Alerjiler
    
    # --- Durum Bilgisi ---
    is_safe = fields.BooleanField(default=False) # Güvende mi?
    wifi_ip = fields.CharField(max_length=20, null=True) # O anki IP adresi
    last_seen = fields.DatetimeField(auto_now=True) # Son görülme zamanı

    class Meta:
        table = "victims"