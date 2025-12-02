# 🛠️ KoTiJeOvoRadio?

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![.NET](https://img.shields.io/badge/.NET-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)
![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

> **Seminarski rad iz predmeta Razvoj Softvera II**
> 
> Mobilna i desktop aplikacija za unajmljivanje radnika i firmi za zanatske potrebe.

---

## 📥 Upute za pokretanje (Installation)

### 1. Priprema okruženja
1. Ekstraktujte `fit-env-02-12-2025.zip` u folder:
   `Ko-Ti-Je-Ovo-Radio/KoRadio`

### 2. Docker (Backend)
Pokrenite terminal u `Ko-Ti-Je-Ovo-Radio/KoRadio` i izvršite:
```bash
docker-compose up --build
```

### 3. Aplikacije
*   🖥️ **Desktop:** Ekstraktujte `fit-build-02-12-2025` (desktop) i pokrenite `ko_radio_desktop.exe`.
*   📱 **Mobile:** Ekstraktujte `fit-build-02-12-2025` (mobile), uzmite `app-release.apk` i instalirajte na emulator/uređaj.

---

## 🔐 Kredencijali (Credentials)

### 📱 Mobilna Aplikacija
**Default Password:** `test123`

| Tip Naloga | Email Adrese |
| :--- | :--- |
| **Korisnici** | `korisnik@email.com`<br>`korisnik2@email.com`<br>`test@email.com` |
| **Korisnik + Radnik** | `struja@email.com` |
| **Kombinovano** <br>*(Korisnik i/ili Radnik i/ili Zaposlenik firme)* | `terenac@email.com`<br>`monter@email.com`<br>`novi@email.com`<br>`dva@email.com`<br>`uposlenik@email.com` |

### 🖥️ Desktop Aplikacija

| Uloga | Email | Lozinka |
| :--- | :--- | :--- |
| 🛡️ **Admin** | `admin@email.com` | `admin` |
| 🏢 **Admin Firme** | `vlasnik@email.com` | `test123` |
| 🏪 **Admin Trgovine** | `trgovina@email.com` | `test123` |

### 💳 PayPal Sandbox
*   **Email:** `sb-shm3c43271033@business.example.com`
*   **Pass:** `$Uh>k0as`

---

## 🧩 Arhitektura i Servisi

### 🐰 RabbitMQ
RabbitMQ servis služi za slanje emailova svim korisnicima aplikacije. Email sadrži PDF katalog proizvoda definisan od strane administratora trgovine.

### 📡 SignalR
Implementiran za **Real-time notifikacije**. Omogućava korisnicima da trenutno prime obavijest bez potrebe za osvježavanjem aplikacije.
