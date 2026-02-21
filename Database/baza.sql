CREATE DATABASE [BirackiSistem];
GO
USE [BirackiSistem];
GO

-- DRZAVA
CREATE TABLE Drzava (
    Id INT IDENTITY PRIMARY KEY,
    Naziv NVARCHAR(100) NOT NULL,
	Obrisan BIT NOT NULL DEFAULT 0
);

-- GRAD
CREATE TABLE Grad (
    Id INT IDENTITY PRIMARY KEY,
    Naziv NVARCHAR(100) NOT NULL,
    DrzavaId INT NOT NULL,
	Obrisan BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (DrzavaId) REFERENCES Drzava(Id)
);

-- OPSTINA
CREATE TABLE Opstina (
    Id INT IDENTITY PRIMARY KEY,
    Naziv NVARCHAR(100) NOT NULL,
    GradId INT NOT NULL,
	Obrisan BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (GradId) REFERENCES Grad(Id)
);

-- ULOGA
CREATE TABLE Uloga (
    Id INT IDENTITY PRIMARY KEY,
    Naziv NVARCHAR(50) NOT NULL,
	Obrisan BIT NOT NULL DEFAULT 0
);

-- Korisnik (BIRACI + ADMIN)
CREATE TABLE Korisnik (
    Id INT IDENTITY PRIMARY KEY,
    Ime NVARCHAR(100) NOT NULL,
    Prezime NVARCHAR(100) NOT NULL,
    Email NVARCHAR(200),
    KorisnickoIme NVARCHAR(100) NOT NULL UNIQUE,
    PasswordSalt NVARCHAR(128),
    PasswordHash NVARCHAR(128),
    PinSalt NVARCHAR(128) NULL,
    PinHash NVARCHAR(128) NULL,
    UlogaId INT NOT NULL,
    OpstinaId INT NOT NULL,
    Slika VARBINARY(MAX) NULL,
    Obrisan BIT NOT NULL DEFAULT 0,
	SistemAdministrator BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (UlogaId) REFERENCES Uloga(Id),
    FOREIGN KEY (OpstinaId) REFERENCES Opstina(Id)
);

-- STRANKE
CREATE TABLE Stranka (
    Id INT IDENTITY PRIMARY KEY,
    Naziv NVARCHAR(100) NOT NULL,
    Opis NVARCHAR(MAX) NULL,
    DatumOsnivanja DATE NULL,
    BrojClanova INT NULL,
    Sjediste NVARCHAR(200) NULL,
    WebUrl NVARCHAR(200) NULL,
    Logo VARBINARY(MAX) NULL,
	Obrisan BIT NOT NULL DEFAULT 0
);

-- TIP IZBORA
CREATE TABLE TipIzbora (
    Id INT IDENTITY PRIMARY KEY,
    Naziv NVARCHAR(100) NOT NULL,
    DozvoljenoViseGlasova BIT NOT NULL,
    MaxBrojGlasova INT NULL,
    OpstinaId INT NOT NULL,
	Obrisan BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (OpstinaId) REFERENCES Opstina(Id)
);

-- IZBOR
CREATE TABLE Izbor (
    Id INT IDENTITY PRIMARY KEY,
    TipIzboraId INT NOT NULL,
    DatumPocetka DATETIME NOT NULL,
    DatumKraja DATETIME NOT NULL,
    Status NVARCHAR(20) NOT NULL,
	Obrisan BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (TipIzboraId) REFERENCES TipIzbora(Id)
);

-- KANDIDATI
CREATE TABLE Kandidat (
    Id INT IDENTITY PRIMARY KEY,
    Ime NVARCHAR(100) NOT NULL,
    Prezime NVARCHAR(100) NOT NULL,
    StrankaId INT NULL,
    IzborId INT NOT NULL,
    Slika VARBINARY(MAX) NULL,
	Obrisan BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (StrankaId) REFERENCES Stranka(Id),
    FOREIGN KEY (IzborId) REFERENCES Izbor(Id)
);

-- GLASANJE
CREATE TABLE Glas (
    Id INT IDENTITY PRIMARY KEY,
    KorisnikId INT NOT NULL,
    KandidatId INT NOT NULL,
    VrijemeGlasanja DATETIME NOT NULL,
	Obrisan BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (KorisnikId) REFERENCES Korisnik(Id),
    FOREIGN KEY (KandidatId) REFERENCES Kandidat(Id)
);

-- KATEGORIJE
CREATE TABLE Kategorija (
    Id INT IDENTITY PRIMARY KEY,
    Naziv NVARCHAR(100) NOT NULL,
    Opis NVARCHAR(500) NULL,
	Obrisan BIT NOT NULL DEFAULT 0
);

-- PITANJA
CREATE TABLE Pitanje (
    Id INT IDENTITY PRIMARY KEY,
    KategorijaId INT NOT NULL,
    PitanjeText NVARCHAR(MAX) NOT NULL,
    OdgovorText NVARCHAR(MAX) NOT NULL,
    DatumKreiranja DATETIME NOT NULL DEFAULT GETDATE(),
	Obrisan BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (KategorijaId) REFERENCES Kategorija(Id)
);

-- ULOGA
--------------------------
INSERT INTO Uloga (Naziv) VALUES ('Admin');
INSERT INTO Uloga (Naziv) VALUES ('Birač');

----------------------------
-- DRZAVE

INSERT INTO Drzava (Naziv) VALUES
('Bosna i Hercegovina'),
('Srbija'),
('Hrvatska'),
('Crna Gora'),
('Slovenija'),
('Sjeverna Makedonija'),
('Albanija'),
('Bugarska'),
('Rumunija'),
(N'Grčka'),
('Kosovo');

-- Bosna i Hercegovina
INSERT INTO Grad (Naziv, DrzavaId) VALUES
('Sarajevo', 1),
('Mostar', 1),
('Tuzla', 1),
('Zenica', 1),
('Banja Luka', 1);

-- Srbija
INSERT INTO Grad (Naziv, DrzavaId) VALUES
('Beograd', 2),
('Novi Sad', 2),
(N'Niš', 2);

-- Hrvatska
INSERT INTO Grad (Naziv, DrzavaId) VALUES
('Zagreb', 3),
('Split', 3),
('Rijeka', 3);

-- Crna Gora
INSERT INTO Grad (Naziv, DrzavaId) VALUES
('Podgorica', 4),
(N'Nikšić', 4);

-- Slovenija
INSERT INTO Grad (Naziv, DrzavaId) VALUES
('Ljubljana', 5),
('Maribor', 5);

-- Sjeverna Makedonija
INSERT INTO Grad (Naziv, DrzavaId) VALUES
('Skoplje', 6),
('Bitola', 6);

-- Albanija
INSERT INTO Grad (Naziv, DrzavaId) VALUES
('Tirana', 7),
('Drač', 7);

-- Bugarska
INSERT INTO Grad (Naziv, DrzavaId) VALUES
('Sofija', 8),
('Plovdiv', 8);

-- Rumunija
INSERT INTO Grad (Naziv, DrzavaId) VALUES
(N'Bukurešt', 9),
(N'Kluž', 9);

-- Grčka
INSERT INTO Grad (Naziv, DrzavaId) VALUES
('Atina', 10),
('Solun', 10);

-- Kosovo
INSERT INTO Grad (Naziv, DrzavaId) VALUES
(N'Priština', 11),
(N'Peć', 11);

----------------------------
-- OPSTINE

INSERT INTO Opstina (Naziv, GradId) VALUES
('Centar', 1),
('Stari Grad', 1),
('Novo Sarajevo', 1),
('Novi Grad', 1),
(N'Ilidža', 1),
(N'Hadžići', 1),
(N'Ilijaš', 1),
(N'Vogošća', 1),
('Trnovo', 1);

-- Mostar (GradId = 2)
INSERT INTO Opstina (Naziv, GradId) VALUES
('Mostar Stari Grad', 2),
('Mostar Jug', 2);

-- Tuzla (GradId = 3)
INSERT INTO Opstina (Naziv, GradId) VALUES
('Centar Tuzla', 3);

-- Zenica (GradId = 4)
INSERT INTO Opstina (Naziv, GradId) VALUES
('Zenica', 4);

-- Beograd (GradId = 6)
INSERT INTO Opstina (Naziv, GradId) VALUES
('Stari Grad', 6),
('Novi Beograd', 6),
('Zemun', 6);

-- Zagreb (GradId = 9)
INSERT INTO Opstina (Naziv, GradId) VALUES
('Donji Grad', 9),
('Novi Zagreb', 9);

-- Podgorica (GradId = 12)
INSERT INTO Opstina (Naziv, GradId) VALUES
('Podgorica', 12);

----------------------------
-- STANKE

INSERT INTO Stranka (Naziv, Opis, DatumOsnivanja, BrojClanova, Sjediste, WebUrl) VALUES
(
'SDA',
N'Stranka demokratske akcije je politička stranka desnog centra koja djeluje u Bosni i Hercegovini
od početka višestranačkog političkog sistema. Njeno djelovanje zasniva se na očuvanju suvereniteta
i teritorijalnog integriteta države, jačanju institucionalnog sistema, zaštiti nacionalnog identiteta
Bošnjaka, te razvoju demokratskog društva zasnovanog na vladavini prava. SDA posebnu pažnju posvećuje
ekonomskom razvoju, jačanju javnih institucija, obrazovanju, kao i unapređenju položaja građana kroz
socijalne i razvojne politike, uz aktivno zalaganje za evropske i euroatlantske integracije.',
'1990-05-26', 200000, 'Sarajevo', 'https://www.sda.ba'
),
(
'SDP BiH',
N'Socijaldemokratska partija Bosne i Hercegovine je multietnička, lijevo orijentisana politička stranka
koja zagovara principe socijalne pravde, jednakosti svih građana i solidarnosti u društvu. Fokus njenog
političkog djelovanja usmjeren je na zaštitu radničkih prava, jačanje javnog sektora, borbu protiv
socijalne nejednakosti i diskriminacije, te izgradnju funkcionalne i pravne države. SDP BiH se zalaže
za demokratske reforme, transparentnost vlasti, poštivanje ljudskih prava i ubrzani put Bosne i
Hercegovine ka članstvu u Evropskoj uniji.',
'1999-04-22', 50000, 'Sarajevo', 'https://www.sdp.ba'
),
(
'Narod i Pravda',
N'Narod i Pravda je politička stranka desnog centra koja je nastala kao odgovor na potrebu za snažnijom
borbom protiv korupcije i zloupotrebe javnih resursa. Program stranke temelji se na jačanju pravne
države, nezavisnosti pravosuđa i odgovornosti nosilaca javnih funkcija. Poseban fokus stavlja se na
reformu javne uprave, unapređenje transparentnosti institucija, ekonomski razvoj i stvaranje jednakih
uslova za sve građane. Stranka se zalaže za moderne demokratske vrijednosti i evropske integracije.',
'2018-03-12', 15000, 'Sarajevo', 'https://www.narodipravda.ba'
),
(
N'Naša Stranka',
N'Naša Stranka je liberalna i građanski orijentisana politička organizacija koja djeluje s ciljem
izgradnje otvorenog, inkluzivnog i pravednog društva. Poseban akcenat stavlja na zaštitu ljudskih
prava, slobodu pojedinca, ravnopravnost spolova i prava manjinskih grupa. Program stranke uključuje
jačanje institucija, borbu protiv korupcije, održivi razvoj i unapređenje javnih politika u oblastima
obrazovanja, kulture i zaštite okoliša. Naša Stranka se dosljedno zalaže za evropske vrijednosti i
transparentno upravljanje.',
'2008-04-10', 12000, 'Sarajevo', 'https://www.nasastranka.ba'
),
(
'SBB',
N'Savez za bolju budućnost je politička stranka koja svoje djelovanje temelji na principima ekonomskog
razvoja, modernizacije društva i jačanja medijskih sloboda. Program stranke usmjeren je na unapređenje
poslovnog ambijenta, podsticanje investicija, otvaranje novih radnih mjesta i razvoj infrastrukture.
SBB zagovara efikasnu i racionalnu javnu administraciju, borbu protiv korupcije i jačanje uloge
privatnog sektora u ekonomskom razvoju. Posebnu pažnju posvećuje savremenim komunikacijama i
informisanju građana.',
'2009-09-15', 30000, 'Sarajevo', 'https://www.sbb.ba'
),
(
'DF',
N'Demokratska fronta je lijevo orijentisana politička stranka koja promoviše antifašizam, socijalnu
pravdu i zaštitu državnih institucija Bosne i Hercegovine. Njen politički program fokusiran je na
jačanje suvereniteta države, ravnopravnost svih naroda i građana, te borbu protiv nacionalizma i
diskriminacije. DF se zalaže za snažne javne institucije, socijalno odgovorne politike, zaštitu
radničkih prava i unapređenje sistema obrazovanja i zdravstva, uz jasno opredjeljenje za evropske
integracije.',
'2013-04-07', 25000, 'Sarajevo', 'https://www.df.ba'
);

INSERT INTO Kategorija (Naziv, Opis) VALUES
(N'Glasanje', N'Pitanja o procesu glasanja i validnosti glasa'),
(N'Sigurnost', N'Pitanja vezana za sigurnost, anonimnost i zaštitu podataka'),
(N'Tehnički problemi', N'Pitanja o greškama i tehničkim poteškoćama'),
(N'Registracija', N'Pitanja o korisničkim nalozima i prijavi'),
(N'Opšte informacije', N'Opšte informacije o izbornom sistemu');

INSERT INTO Pitanje (KategorijaId, PitanjeText, OdgovorText) VALUES
(1, N'Kako mogu glasati?', N'Korisnik se prijavljuje u sistem i bira jednog ili više kandidata u skladu s pravilima izbora.'),
(1, N'Mogu li glasati više puta?', N'Ne. Sistem dozvoljava glasanje samo jednom po izboru.'),
(1, N'Da li mogu promijeniti glas?', N'Ne, nakon potvrde glasanja glas se trajno evidentira.'),

(2, N'Da li je moje glasanje anonimno?', N'Da. Vaš glas možete samo Vi vidjeti kroz historiju glasanja, dok je za ostale korisnike anoniman.'),
(2, N'Kako se štite moji podaci?', N'Podaci su zaštićeni hashiranjem, enkripcijom i kontrolom pristupa.'),

(3, N'Šta ako mi se aplikacija ugasi tokom glasanja?', N'Ako glas nije potvrđen, neće biti evidentiran.'),
(3, N'Kome da se obratim za tehničku podršku?', N'Administratorskoj službi putem zvaničnih kanala.'),

(4, N'Ko kreira korisničke naloge?', N'Korisničke naloge kreira administrator sistema.'),
(4, N'Kako dobijam PIN?', N'PIN kreirate prilikom prve prijave u aplikaciju, te isti koristite neposredno prije glasanja.'),

(5, N'Ko može koristiti sistem?', N'Sistem mogu koristiti registrovani birači sa važećim pravom glasa.'),
(5, N'Zašto koristiti elektronsko glasanje?', N'Radi povećanja transparentnosti, sigurnosti i smanjenja izbornih nepravilnosti.');