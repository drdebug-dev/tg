# پل Bot API تلگرام (VPS خارجی)

هاست ایران به `api.telegram.org` دسترسی ندارد. این سرویس روی VPS خارجی فقط ترافیک HTTPS را به Bot API پروکسی می‌کند. توکن روی این سرور ذخیره نمی‌شود.

```
هاست ایران (polling / sendMessage)  →  https://BRIDGE_DOMAIN  →  api.telegram.org
```

## راه‌اندازی

۱. DNS: رکورد A ساب‌دامین (مثلاً `tg-api.example.com`) را به IP همین VPS بدهید.

۲. تنظیمات:

```bash
cp .env.example .env
# BRIDGE_DOMAIN و CERTBOT_EMAIL را پر کنید
```

۳. nginx را بالا بیاورید (پورت ۸۰ برای صدور گواهی لازم است):

```bash
docker compose up -d nginx
```

۴. گواهی Let’s Encrypt:

```bash
# مقادیر را از .env بخوانید یا دستی جایگزین کنید
docker compose run --rm --entrypoint certbot certbot certonly \
  --webroot -w /var/www/certbot \
  -d tg-api.example.com \
  --email admin@example.com \
  --agree-tos --no-eff-email
```

۵. nginx را ری‌استارت کنید تا گواهی واقعی را بردارد:

```bash
docker compose up -d
docker compose restart nginx
```

۶. تست از خود VPS:

```bash
curl -sS https://tg-api.example.com/
```

باید پاسخ HTML/متن تلگرام بیاید، نه خطای اتصال.

اختیاری: در `.env` مقدار `ALLOW_IRAN_IP` را IP هاست ایران بگذارید تا فقط همان سرور به پل وصل شود.

## اپ روی هاست ایران

در `.env` یا Environment پنل:

```
TELEGRAM_API_BASE=https://tg-api.example.com
```

بدون اسلش انتهایی. بعد اپ را ری‌استارت کنید.

از داخل کانتینر اپ چک کنید که VPS در دسترس است:

```bash
curl -sS https://tg-api.example.com/
```

اگر دامنه فیلتر بود، IP VPS را در DNS خصوصی یا `/etc/hosts` هاست ایران بگذارید.
