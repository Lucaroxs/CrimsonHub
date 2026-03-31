# Roblox Script Authentication API

Discord OAuth2 tabanlı authentication sistemi.

## Kurulum

1. Discord Developer Portal'dan uygulama oluştur:
   - https://discord.com/developers/applications
   - OAuth2 > Redirects: `https://crimsonhub-f52q.onrender.com/callback` ekle

2. `.env` dosyası oluştur:
```bash
cp .env.example .env
```

3. `.env` dosyasını doldur:
   - `DISCORD_CLIENT_ID`: Discord uygulamanın Client ID
   - `DISCORD_CLIENT_SECRET`: Discord uygulamanın Client Secret
   - `DISCORD_BOT_TOKEN`: Discord bot token (opsiyonel)
   - `REQUIRED_GUILD_ID`: Kullanıcıların bulunması gereken Discord sunucu ID
   - `PORT`: API port (varsayılan: 3000)

4. Bağımlılıkları yükle:
```bash
npm install
```

5. Sunucuyu başlat:
```bash
npm start
```

## Kullanım

1. Tarayıcıda `https://crimsonhub-f52q.onrender.com` aç
2. "Discord ile Giriş Yap" butonuna tıkla
3. Discord ile giriş yap ve izinleri onayla
4. Ekranda görünen 8 haneli kodu kopyala
5. Roblox'ta scripti çalıştır ve kodu gir
6. Kod 30 dakika geçerlidir

## Endpoints

- `GET /` - Ana sayfa (Discord login)
- `GET /auth/discord` - Discord OAuth başlat
- `GET /callback` - Discord callback
- `GET /verify/:code` - Kod doğrulama (Roblox'tan)
- `GET /admin/codes` - Aktif kodları listele

## Production Deployment (Render)

Bu proje Render'da deploy edilmiştir:
- URL: https://crimsonhub-f52q.onrender.com
- Discord Redirect URI: https://crimsonhub-f52q.onrender.com/callback

Environment Variables (Render Dashboard):
```
DISCORD_CLIENT_ID=xxx
DISCORD_CLIENT_SECRET=xxx
DISCORD_REDIRECT_URI=https://crimsonhub-f52q.onrender.com/callback
REQUIRED_GUILD_ID=xxx
PORT=3000
```
