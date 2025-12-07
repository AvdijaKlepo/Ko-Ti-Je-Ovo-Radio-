![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![.NET](https://img.shields.io/badge/.NET-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)
![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)

> **NOTE: For the English version, please scroll down to the bottom of this document.**

---

# KoTiJeOvoRadio?
**Seminarski rad iz predmeta Razvoj Softvera II**

Mobilna i desktop aplikacija za angažman radnika i firma za zanatske potrebe razvijena u Flutteru, .NET i SQLServer.

## Upute za pokretanje aplikacije

1.  Extraktujte `fit-env-02-12-2025 env zip` u `Ko-Ti-Je-Ovo-Radio/KoRadio` folder.
2.  Pokrenite docker-compose iz `Ko-Ti-Je-Ovo-Radio/KoRadio` putanje:
    ```bash
    docker-compose up --build
    ```
3.  Extraktujte `fit-build-02-12-2025 desktop` preuzimajući `Debug folder` i pokrenite iz njega `ko_radio_desktop.exe`.
4.  Extraktujte `fit-build-02-12-2025 mobile` preuzimajući `flutter-apk` folder i učitajte iz njega `app-release.apk` u mobilni emulator.

---

## Kredencijali korisnika koji imaju pristup mobilnoj aplikaciji

**Lozinka svakog korisnika je `test123`**

### Korisnici koji imaju samo ulogu korisnik
*   `korisnik@email.com`
*   `korisnik2@email.com`
*   `test@email.com`

### Korisnici koji imaju ulogu korisnika i radnika
*   `imezanata@email.com` (npr. `struja@email.com`)

### Korisnici koji imaju ulogu korisnika i ili radnika/radnika firme
*   `terenac@email.com`
*   `monter@email.com`
*   `novi@email.com`
*   `dva@email.com`
*   `uposlenik@email.com`

---

## Kredencijali korisnika koji imaju pristup desktop aplikaciji

**Lozinka svakog korisnika je `test123`, isključujući administratora.**

| Uloga | Email | Lozinka |
| :--- | :--- | :--- |
| **Admin** | `admin@email.com` | `admin` |
| **Administrator firme** | `vlasnik@email.com` | `test123` |
| **Administrator trgovine** | `trgovina@email.com` | `test123` |

---

## Ostali Kredencijali i Tehnologije

### PayPal Kredencijali
*   **Email:** `sb-shm3c43271033@business.example.com`
*   **Lozinka:** `$Uh>k0as`

### RabbitMQ
RabbitMQ se koristi za slanje mailova svim korisnicima aplikacije, koji sadrže katalog proizvoda u pdf formatu određen programatično kroz desktop aplikaciju ili učitan od strane administratora.

### SignalR
SignalR se koristi za real time obavijesti o prispjelim notifikacijama za korisnika.

<br>
<br>
<br>

---
<a name="english-version"></a>

# KoTiJeOvoRadio? (English Version)
**Seminar paper for the subject Software Development II**

Mobile and desktop application for hiring workers and firms for craft needs developed in Flutter, .NET, and SQLServer.

## Instructions for running the application

1.  Extract `fit-env-02-12-2025 env zip` into the `Ko-Ti-Je-Ovo-Radio/KoRadio` folder.
2.  Run docker-compose from the `Ko-Ti-Je-Ovo-Radio/KoRadio` path:
    ```bash
    docker-compose up --build
    ```
3.  Extract `fit-build-02-12-2025 desktop` retrieving the `Debug` folder from which you will run the `ko_radio_desktop.exe` file.
4.  Extract `fit-build-02-12-2025 mobile` retrieving the `flutter-apk` folder and load from it the `app-release.apk` file into the mobile emulator.

---

## User credentials with access to the mobile application

**The password for every user is `test123`**

### Users who only have the user role
*   `korisnik@email.com`
*   `korisnik2@email.com`
*   `test@email.com`

### Users who have the user and worker role
*   `tradename@email.com` (e.g. `struja@email.com`)

### Users who have the role of user and/or worker/firm worker
*   `terenac@email.com`
*   `monter@email.com`
*   `novi@email.com`
*   `dva@email.com`
*   `uposlenik@email.com`

---

## User credentials with access to the desktop application

**The password for every user is `test123`, excluding the administrator.**

| Role | Email | Password |
| :--- | :--- | :--- |
| **Admin** | `admin@email.com` | `admin` |
| **Firm Administrator** | `vlasnik@email.com` | `test123` |
| **Store Administrator** | `trgovina@email.com` | `test123` |

---

## Other Credentials and Technologies

### PayPal Credentials
*   **Email:** `sb-shm3c43271033@business.example.com`
*   **Password:** `$Uh>k0as`

### RabbitMQ
RabbitMQ is used to send emails to all application users, where the email contains a product catalog defined by store administrators sent to the mail in PDF format.

### SignalR
SignalR is used for real-time notifications regarding received notifications to the user.
