# پل Bot API تلگرام (VPS خارجی)

هاست ایران به `api.telegram.org` دسترسی ندارد. این سرویس ترافیک را به Bot API پروکسی می‌کند. توکن روی این سرور ذخیره نمی‌شود.

```
هاست ایران  →  https://BRIDGE_DOMAIN (nginx موجود روی VPS)  →  telegram-bridge:8089  →  api.telegram.org
```

اگر روی VPS از قبل nginx یا برنامه دیگری پورت ۸۰/۴۴۳ را گرفته، **حالت پیش‌فرض همین است** و آن پورت‌ها را اشغال نمی‌کند.

## راه‌اندازی (کنار برنامه‌های دیگر)

۱. DNS: رکورد A ساب‌دامین (مثلاً `tg-api.example.com`) را به IP همین VPS بدهید.

۲. اگر کانتینر قبلی به‌خاطر پورت ۸۰ fail شده، اول آن را بردارید:

```bash
docker compose down
```

۳. تنظیمات:

```bash
cp .env.example .env
# BRIDGE_DOMAIN را پر کنید؛ BEHIND_PROXY=1 بماند
```

۴. پل را بالا بیاورید (فقط `127.0.0.1:8089`):

```bash
docker compose up -d --build
```

۵. روی **nginx موجود** یک vhost اضافه کنید. نمونه: [`host-nginx.conf`](host-nginx.conf)

- اگر nginx روی خود سیستم نصب است: `proxy_pass http://127.0.0.1:8089;`
- اگر nginx داخل Docker است (مثلاً `faktoos_nginx`):

```bash
docker network connect <شبکه_nginx> telegram-bridge
```

و در vhost بگذارید: `proxy_pass http://telegram-bridge:80;`

گواهی HTTPS را همان nginx موجود صادر کند (certbot / پنل). بعد `nginx -s reload`.

۶. تست:

```bash
curl -sS https://tg-api.example.com/
```

باید پاسخ تلگرام بیاید، نه خطای اتصال.

## اپ روی هاست ایران

```
TELEGRAM_API_BASE=https://tg-api.example.com
```

بدون اسلش انتهایی. بعد اپ را ری‌استارت کنید.

## حالت مستقل (VPS خالی، پورت ۸۰ آزاد)

فقط اگر هیچ وب‌سروری روی ۸۰/۴۴۳ نیست:

```bash
docker compose -f docker-compose.yml -f docker-compose.standalone.yml up -d
```
