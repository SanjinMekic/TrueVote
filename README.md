# 🗳️ TrueVote – Pokretanje sistema i kredencijali

Ovaj dokument opisuje osnovne korake za pokretanje TrueVote sistema i pristupne podatke za testiranje aplikacije.

---

## ⚙️ Pokretanje sistema

### 1. Baza podataka

- Potrebno je **manuelno pokrenuti SQL skriptu** (`baza.sql`)
- Skripta kreira:
  - bazu podataka
  - sve tabele
  - početne (seed) podatke

---

### 2. Konfiguracija

U `appsettings.json` podesiti konekciju na bazu:

    {
      "ConnectionStrings": {
        "DefaultConnection": "Server=localhost;Database=BirackiSistem;Integrated Security=True;TrustServerCertificate=True;"
      }
    }

### 3. Pokretanje backend-a

Pokrenuti .NET Web API:

`dotnet run`

Backend će biti dostupan na:

`http://localhost:5080`

Swagger:

`http://localhost:5080/swagger`
### 4. Pokretanje aplikacija

1. Desktop aplikacija → za administratore

3. Mobilna aplikacija → za birače

### 🔑 Kredencijali
#####👤 Administrator

- Username: admin

- Password: admin

✔ Omogućava:

- upravljanje sistemom

- kreiranje izbora, kandidata, korisnika

- pregled statistike

####🧑 Birač

- Username: birac

- Password: birac

✔ Omogućava:

- glasanje

- pregled historije glasanja

- pristup izborima

###🔐 PIN (važna napomena)

1. Prilikom prve prijave korisnik kreira 4-cifreni PIN

3. PIN se koristi za potvrdu glasanja

5. PIN se čuva kao hash (sigurnosni mehanizam)

####📌 Napomena

1. Sistem koristi Basic Authentication

3. Lozinke i PIN-ovi su hashirani (salt + hash)

5. Baza mora biti pokrenuta prije backend-a

###👨‍💻 Autor

Sanjin Mekić
TrueVote – sistem za elektronsko glasanje