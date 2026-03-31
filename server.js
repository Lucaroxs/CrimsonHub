require('dotenv').config();
const express = require('express');
const cors = require('cors');
const axios = require('axios');
const crypto = require('crypto');

const app = express();
app.use(cors());
app.use(express.json());

// Geçici kod depolama (production'da Redis kullan)
const activeCodes = new Map();
const pendingAuth = new Map();

// Discord OAuth2 Config
const DISCORD_API = 'https://discord.com/api/v10';
const CLIENT_ID = process.env.DISCORD_CLIENT_ID;
const CLIENT_SECRET = process.env.DISCORD_CLIENT_SECRET;
const REDIRECT_URI = process.env.DISCORD_REDIRECT_URI;
const BOT_TOKEN = process.env.DISCORD_BOT_TOKEN;
const REQUIRED_GUILD_ID = process.env.REQUIRED_GUILD_ID;

// 30 dakikalık kod oluştur
function generateCode() {
    return crypto.randomBytes(4).toString('hex').toUpperCase();
}

// Kod temizleme (30 dakika sonra)
function scheduleCodeExpiry(code) {
    setTimeout(() => {
        if (activeCodes.has(code)) {
            console.log(`Code expired: ${code}`);
            activeCodes.delete(code);
        }
    }, 30 * 60 * 1000); // 30 dakika
}

// Ana sayfa - Discord login
app.get('/', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Roblox Script Auth</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    height: 100vh;
                    margin: 0;
                }
                .container {
                    background: white;
                    padding: 40px;
                    border-radius: 10px;
                    box-shadow: 0 10px 40px rgba(0,0,0,0.3);
                    text-align: center;
                }
                h1 { color: #333; margin-bottom: 20px; }
                .discord-btn {
                    background: #5865F2;
                    color: white;
                    padding: 15px 30px;
                    border: none;
                    border-radius: 5px;
                    font-size: 16px;
                    cursor: pointer;
                    text-decoration: none;
                    display: inline-block;
                }
                .discord-btn:hover { background: #4752C4; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>🎮 Roblox Script Authentication</h1>
                <p>Discord ile giriş yaparak 30 dakikalık erişim kodu alın</p>
                <a href="/auth/discord" class="discord-btn">Discord ile Giriş Yap</a>
            </div>
        </body>
        </html>
    `);
});

// Discord OAuth başlat
app.get('/auth/discord', (req, res) => {
    const state = crypto.randomBytes(16).toString('hex');
    const authUrl = `https://discord.com/api/oauth2/authorize?client_id=${CLIENT_ID}&redirect_uri=${encodeURIComponent(REDIRECT_URI)}&response_type=code&scope=identify%20guilds&state=${state}`;
    res.redirect(authUrl);
});

// Discord callback
app.get('/callback', async (req, res) => {
    const { code, state } = req.query;

    if (!code) {
        return res.send('Authentication failed!');
    }

    try {
        // Access token al
        const tokenResponse = await axios.post(`${DISCORD_API}/oauth2/token`, new URLSearchParams({
            client_id: CLIENT_ID,
            client_secret: CLIENT_SECRET,
            grant_type: 'authorization_code',
            code: code,
            redirect_uri: REDIRECT_URI
        }), {
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        });

        const { access_token } = tokenResponse.data;

        // Kullanıcı bilgilerini al
        const userResponse = await axios.get(`${DISCORD_API}/users/@me`, {
            headers: { Authorization: `Bearer ${access_token}` }
        });

        const user = userResponse.data;

        // Kullanıcının sunucularını kontrol et
        const guildsResponse = await axios.get(`${DISCORD_API}/users/@me/guilds`, {
            headers: { Authorization: `Bearer ${access_token}` }
        });

        const guilds = guildsResponse.data;
        const isInRequiredGuild = guilds.some(guild => guild.id === REQUIRED_GUILD_ID);

        if (!isInRequiredGuild) {
            return res.send(`
                <!DOCTYPE html>
                <html>
                <head>
                    <title>Access Denied</title>
                    <style>
                        body {
                            font-family: Arial, sans-serif;
                            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
                            display: flex;
                            justify-content: center;
                            align-items: center;
                            height: 100vh;
                            margin: 0;
                        }
                        .container {
                            background: white;
                            padding: 40px;
                            border-radius: 10px;
                            text-align: center;
                        }
                        h1 { color: #f5576c; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <h1>❌ Erişim Reddedildi</h1>
                        <p>Bu scripti kullanmak için gerekli Discord sunucusunda olmalısınız!</p>
                    </div>
                </body>
                </html>
            `);
        }

        // 30 dakikalık kod oluştur
        const accessCode = generateCode();
        activeCodes.set(accessCode, {
            userId: user.id,
            username: user.username,
            createdAt: Date.now(),
            expiresAt: Date.now() + (30 * 60 * 1000)
        });

        scheduleCodeExpiry(accessCode);

        console.log(`New code generated for ${user.username}: ${accessCode}`);

        res.send(`
            <!DOCTYPE html>
            <html>
            <head>
                <title>Authentication Success</title>
                <style>
                    body {
                        font-family: Arial, sans-serif;
                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        height: 100vh;
                        margin: 0;
                    }
                    .container {
                        background: white;
                        padding: 40px;
                        border-radius: 10px;
                        box-shadow: 0 10px 40px rgba(0,0,0,0.3);
                        text-align: center;
                    }
                    h1 { color: #667eea; margin-bottom: 20px; }
                    .code {
                        background: #f0f0f0;
                        padding: 20px;
                        border-radius: 5px;
                        font-size: 32px;
                        font-weight: bold;
                        letter-spacing: 3px;
                        margin: 20px 0;
                        color: #333;
                    }
                    .timer { color: #666; margin-top: 10px; }
                    .copy-btn {
                        background: #667eea;
                        color: white;
                        padding: 10px 20px;
                        border: none;
                        border-radius: 5px;
                        cursor: pointer;
                        margin-top: 15px;
                    }
                    .copy-btn:hover { background: #5568d3; }
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>✅ Başarılı!</h1>
                    <p>Hoş geldin, <strong>${user.username}</strong>!</p>
                    <div class="code" id="code">${accessCode}</div>
                    <button class="copy-btn" onclick="copyCode()">Kodu Kopyala</button>
                    <p class="timer">⏱️ Bu kod 30 dakika geçerlidir</p>
                    <p style="color: #999; font-size: 12px;">Kodu Roblox scriptine gir</p>
                </div>
                <script>
                    function copyCode() {
                        const code = document.getElementById('code').innerText;
                        navigator.clipboard.writeText(code);
                        alert('Kod kopyalandı: ' + code);
                    }
                </script>
            </body>
            </html>
        `);

    } catch (error) {
        console.error('Auth error:', error.response?.data || error.message);
        res.send('Authentication failed! Check server logs.');
    }
});

// Kod doğrulama endpoint (Roblox'tan çağrılır)
app.get('/verify/:code', (req, res) => {
    const code = req.params.code.toUpperCase();
    
    if (!activeCodes.has(code)) {
        return res.json({ 
            success: false, 
            message: 'Invalid or expired code' 
        });
    }

    const codeData = activeCodes.get(code);
    const now = Date.now();

    if (now > codeData.expiresAt) {
        activeCodes.delete(code);
        return res.json({ 
            success: false, 
            message: 'Code expired. Please get a new code.' 
        });
    }

    const remainingTime = Math.floor((codeData.expiresAt - now) / 1000 / 60);

    res.json({
        success: true,
        username: codeData.username,
        remainingMinutes: remainingTime,
        expiresAt: codeData.expiresAt
    });
});

// Aktif kodları listele (admin endpoint)
app.get('/admin/codes', (req, res) => {
    const codes = [];
    activeCodes.forEach((data, code) => {
        codes.push({
            code,
            username: data.username,
            remainingMinutes: Math.floor((data.expiresAt - Date.now()) / 1000 / 60)
        });
    });
    res.json({ codes });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 Auth API running on http://localhost:${PORT}`);
    console.log(`📝 Discord OAuth: http://localhost:${PORT}/auth/discord`);
});
