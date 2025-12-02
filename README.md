KoTiJeOvoRadio? - Seminarski rad iz predmeta Razvoj Softvera II

Mobilna i desktop aplikacija za unajmljivanje radnika i firma za zanatske potrebe
razvijena u Flutteru, .NET i SQLServer
Upute za pokretanje aplikacije

Extraktujte fit-env-02-12-2025 env zip u Ko-Ti-Je-Ovo-Radio/KoRadio folder
Pokrenite docker-compose up --build iz Ko-Ti-Je-Ovo-Radio/KoRadio putanje
Extraktujte fit-build-02-12-2025 desktop preuzimajući ko_radio_desktop.exe file
Extraktujte fit-build-02-12-2025 mobile preuzimajući app-release.apk file i učitajte ga u mobilni emulator
Kredencijali korisnika koji imaju pristup mobilnoj aplikaciji

Lozinka svakog korisnika je test123
Korisnici koji imaju samo ulogu korisnik
korisnik@email.com
korisnik2@email.com
test@email.com
Korisnici koji imaju ulogu korisnika i radnika
imezanata@email.com npr. struja@email.com
Korisnici koji imaju ulogu korisnika i ili radnika/radnika firme
terenac@email.com
monter@email.com
novi@email.com
dva@email.com
uposlenik@email.com
Kredencijali korisnika koji imaju pristup desktop aplikaciji

Lozinka svakog korisnika je test123, isključujući administratora
Admin
Email: admin@email.com
Lozinka: admin
Administrator firme
vlasnik@email.com
Administrator trgovine
trgovina@email.com
PayPal Kredencijali

Email: sb-shm3c43271033@business.example.com
Lozinka: $Uh>k0as
RabbitMQ

RabbitMQ se koristi za slanje mailova svim korisnicima aplikacije, tako što email sadrži katalog proizvoda koji određuju administratori trgovine poslan na mail u pdf formatu.
SignalR

SignalR se koristi za real time obavijesti o prispjelim notifikacija korisniku.
