# پل Bot API تلگرام — VPS خارجی `dg.pingol.ir`

هاست ایران به `api.telegram.org` دسترسی ندارد. ترافیک از این دامنه به Bot API پروکسی می‌شود. توکن اینجا ذخیره نمی‌شود.

```
هاست ایران  →  https://dg.pingol.ir (DNS مستقیم به VPS + Traefik)  →  telegram-bridge  →  api.telegram.org
```

روی اپ ایران:

```
TELEGRAM_API_BASE=https://dg.pingol.ir
TELEGRAM_API_SSL_VERIFY=false
```

`SSL_VERIFY=false` لازم است تا وقتی Traefik هنوز گواهی Let’s Encrypt برای این ساب‌دامین ندارد (الان self-signed می‌دهد). بعد از صدور گواهی واقعی می‌توانید `true` بگذارید.

## راه‌اندازی روی VPS

۱. در Cloudflare رکورد A برای `dg.pingol.ir` به IP همین VPS باشد.

   **پروکسی نارنجی را خاموش کنید (DNS only / ابر خاکستری).** از ایران IPهای Cloudflare اغلب کند یا فیلترند.

   روی Traefik برای این دامنه `tls.certresolver` بگذارید (همان resolver بقیه سایت‌های pingol.ir). بدون آن Traefik گواهی self-signed می‌دهد و اپ ایران با `CERTIFICATE_VERIFY_FAILED` قطع می‌شود.

۲. شبکه Traefik را پیدا کنید:

```bash
docker network ls
docker ps --format '{{.Names}}' | grep -i traefik
```

۳. `.env` را از نمونه بسازید و `TRAEFIK_NETWORK` را همان نام شبکه Traefik بگذارید:

```bash
cp .env.example .env
# BRIDGE_DOMAIN=dg.pingol.ir
# TRAEFIK_NETWORK=...
```

۴. اگر کانتینر قبلی به‌خاطر پورت ۸۰ fail شده:

```bash
docker compose down
```

۵. بالا آوردن با اتصال به شبکه Traefik:

```bash
docker compose -f docker-compose.yml -f docker-compose.traefik.yml up -d --build
```

اگر overlay را نمی‌خواهید:

```bash
docker compose up -d --build
docker network connect <شبکه_traefik> telegram-bridge
```

۶. تست از خود VPS:

```bash
curl -sS http://127.0.0.1:8089/
curl -sS "https://dg.pingol.ir/bot<BOT_TOKEN>/getMe"
```

`getMe` باید JSON با `"ok":true` برگرداند. صفحه خالی دامنه (`/`) سایت نیست؛ مسیر درست Bot API است.

اگر باز متن `404 page not found` آمد، Traefik هنوز این Host را ندارد: اسم `TRAEFIK_ENTRYPOINT` و شبکه را با استک‌های دیگر روی همین VPS مقایسه کنید.

## nginx به‌جای Traefik

اگر لبه سرور nginx است نه Traefik، نمونه vhost: [`host-nginx.conf`](host-nginx.conf) با `server_name dg.pingol.ir`.
