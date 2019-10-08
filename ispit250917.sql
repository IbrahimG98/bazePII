--1.	Kroz SQL kod napraviti bazu podataka koja nosi ime vašeg broja dosijea,
-- a zatim u svojoj bazi podataka kreirati tabele sa sljedeæom strukturom:
CREATE DATABASE ispit250917
USE ispit250917



--a)	Klijenti
--i.	Ime, polje za unos 50 karaktera (obavezan unos)
--ii.	Prezime, polje za unos 50 karaktera (obavezan unos)
--iii.	Drzava, polje za unos 50 karaktera (obavezan unos)
--iv.	Grad, polje za  unos 50 karaktera (obavezan unos)
--v.	Email, polje za unos 50 karaktera (obavezan unos)
--vi.	Telefon, polje za unos 50 karaktera (obavezan unos)
CREATE TABLE Klijenti
(
KlijentID int CONSTRAINT PK_KlijentID PRIMARY KEY IDENTITY(1,1),
Ime nvarchar(50) not null,
Prezime nvarchar(50) not null,
Drzava nvarchar(50) not null,
Grad nvarchar(50) not null,
Email nvarchar(50) not null,
Telefon nvarchar(50) not null
)
--b)	Izleti
--i.	Sifra, polje za unos 10 karaktera (obavezan unos)
--ii.	Naziv, polje za unos 100 karaktera (obavezan unos)
--iii.	DatumPolaska, polje za unos datuma (obavezan unos)
--iv.	DatumPovratka, polje za unos datuma (obavezan unos)
--v.	Cijena, polje za unos decimalnog broja (obavezan unos)
--vi.	Opis, polje za unos dužeg teksta (nije obavezan unos)
CREATE TABLE Izleti
(
IzletID int CONSTRAINT PK_IzletID PRIMARY KEY IDENTITY(1,1),
Sifra nvarchar(10) not null,
Naziv nvarchar(100) not null,
DatumPolaska date not null,
DatumPovratka date not null,
Cijena DECIMAL(8,2) not null,
Opis text 
)
--c)	Prijave
--i.	Datum, polje za unos datuma i vremena (obavezan unos)
--ii.	BrojOdraslih polje za unos cijelog broja (obavezan unos)
--iii.	BrojDjece polje za unos cijelog broja (obavezan unos)
--Napomena: Na izlet se može prijaviti više klijenata,
-- dok svaki klijent može prijaviti više izleta.
-- Prilikom prijave klijent je obavezan unijeti broj odraslih i broj djece koji putuju u sklopu izleta.
CREATE TABLE Prijave
(
KlijentID int CONSTRAINT FK_Prijave_Klijent FOREIGN KEY (KlijentID) references Klijenti(KlijentID),
IzletID int CONSTRAINT FK_Prijave_Izlet	FOREIGN KEY(IzletID) references Izleti(IzletID),
Datum datetime not null,
BrojOdraslih int not null,
BrojDjece int not null,
CONSTRAINT PK_Prijave PRIMARY KEY (KlijentID,IzletID)
)
--10 bodova

--2.	Iz baze podataka AdventureWorks2014 u svoju bazu podataka prebaciti sljedeæe podatke:
--a)	U tabelu Klijenti prebaciti sve uposlenike koji su radili u odjelu prodaje (Sales) 
--i.	FirstName -> Ime
--ii.	LastName -> Prezime
--iii.	CountryRegion (Name) -> Drzava
--iv.	Addresss (City) -> Grad
--v.	EmailAddress (EmailAddress)  -> Email (Izmeðu imena i prezime staviti taèku)
--vi.	PersonPhone (PhoneNumber) -> Telefon
--b)	U tabelu Izleti dodati 3 izleta (proizvoljno)																												10 bodova

--a)
INSERT INTO Klijenti
SELECT P.FirstName,P.LastName,CR.Name,A.City,P.FirstName+'.'+P.LastName+'@adventure-works.com',PP.PhoneNumber
FROM AdventureWorks2017.HumanResources.Employee AS E INNER JOIN AdventureWorks2017.Person.Person AS P ON E.BusinessEntityID=P.BusinessEntityID
INNER JOIN AdventureWorks2017.Person.BusinessEntityAddress AS BEA ON P.BusinessEntityID=BEA.BusinessEntityID
INNER JOIN AdventureWorks2017.Person.Address AS A ON BEA.AddressID=A.AddressID INNER JOIN AdventureWorks2017.Person.StateProvince AS SP ON A.StateProvinceID=SP.StateProvinceID
INNER JOIN AdventureWorks2017.Person.CountryRegion AS CR ON SP.CountryRegionCode=CR.CountryRegionCode 
INNER JOIN AdventureWorks2017.Person.EmailAddress AS EM ON P.BusinessEntityID=EM.BusinessEntityID
INNER JOIN AdventureWorks2017.Person.PersonPhone AS PP ON P.BusinessEntityID=PP.BusinessEntityID
WHERE E.JobTitle LIKE '%Sales%'

--b)
--IzletID int CONSTRAINT PK_IzletID PRIMARY KEY IDENTITY(1,1),
--Sifra nvarchar(10) not null,
--Naziv nvarchar(100) not null,
--DatumPolaska date not null,
--DatumPovratka date not null,
--Cijena DECIMAL(8,2) not null,
--Opis text 

INSERT INTO Izleti(Sifra,Naziv,DatumPolaska,DatumPovratka,Cijena)
VALUES ('sifra1','Putovanje u Istanbul','20190806','20190816',200),
('sifra2','Putovanje u Bali','20190907','20190919',500),
('sifra3','Putovanje u Hanoi','20191106','20191126',1200)
SELECT * FROM Izleti





--3.	Kreirati uskladištenu proceduru za unos nove prijave.
-- Proceduri nije potrebno proslijediti parametar Datum. 
--Datum se uvijek postavlja na trenutni. Koristeæi kreiranu proceduru u tabelu Prijave dodati 10 prijava.
-- 10 bodova
--KlijentID int CONSTRAINT FK_Prijave_Klijent FOREIGN KEY (KlijentID) references Klijenti(KlijentID),
--IzletID int CONSTRAINT FK_Prijave_Izlet	FOREIGN KEY(IzletID) references Izleti(IzletID),
--Datum datetime not null,
--BrojOdraslih int not null,
--BrojDjece int not null,
CREATE PROCEDURE proc_dodajPrijavu
(
@KlijentID int,
@IzletID int,
@BrojOdraslih int,
@BrojDjece int
)
AS
BEGIN
INSERT INTO Prijave
VALUES(@KlijentID,@IzletID,GETDATE(),@BrojOdraslih,@BrojDjece)
END

EXEC proc_dodajPrijavu 1,1,2,2
EXEC proc_dodajPrijavu 4,2,2,1
EXEC proc_dodajPrijavu 3,2,2,1
EXEC proc_dodajPrijavu 2,3,2,0
EXEC proc_dodajPrijavu 11,3,2,3
EXEC proc_dodajPrijavu 12,1,2,1
EXEC proc_dodajPrijavu 17,2,2,1
EXEC proc_dodajPrijavu 14,1,2,2
EXEC proc_dodajPrijavu 9,2,2,1
EXEC proc_dodajPrijavu 7,2,2,1
EXEC proc_dodajPrijavu 8,2,2,2
SELECT * FROM Prijave

--4.	Kreirati index koji æe sprijeèiti dupliciranje polja Email u tabeli Klijenti. 
--Obavezno testirati ispravnost kreiranog indexa.
--5 bodova
CREATE UNIQUE NONCLUSTERED INDEX IX_UQ_Email ON Klijenti(Email)
SELECT * FROM Klijenti
INSERT INTO Klijenti
VALUES ('test','test','Canada','Calgary','Brian.Welcker@adventure-works.com','222-222-3333')


--5.	Svim izletima koji imaju više od 3 prijave cijenu umanjiti za 10%.
--10 bodova
SELECT * FROM Prijave
UPDATE Izleti
SET Cijena=Cijena-(Cijena*0.1)
WHERE IzletID IN (
SELECT IzletID FROM Prijave GROUP BY IzletID HAVING COUNT(IzletID)>3

)

SELECT * FROM Izleti

--6.	Kreirati view (pogled) koji prikazuje podatke o izletu:
-- šifra, naziv, datum polaska, datum povratka i cijena, te ukupan broj prijava na izletu,
-- ukupan broj putnika, ukupan broj odraslih i ukupan broj djece. Obavezno prilagoditi format datuma (dd.mm.yyyy).
--10 bodova

CREATE VIEW pogled_prvi
AS
SELECT I.Sifra,I.Naziv,CONVERT(nvarchar,I.DatumPolaska,104)AS DatumPolaska,CONVERT(nvarchar,I.DatumPovratka,104) AS DatumPovratka,COUNT(P.IzletID) AS BrPrijava,SUM(P.BrojOdraslih+P.BrojDjece) AS Ukupno,SUM(P.BrojOdraslih) AS BrOdraslih,SUM(P.BrojDjece) AS BrDjece
FROM Izleti AS I INNER JOIN Prijave AS P ON I.IzletID=P.IzletID
GROUP BY I.Sifra,I.Naziv,I.DatumPolaska,I.DatumPovratka






--7.	Kreirati uskladištenu proceduru koja æe na osnovu unesene šifre izleta prikazivati zaradu od izleta i to
-- sljedeæe kolone: naziv izleta, zarada od odraslih, zarada od djece, ukupna zarada.
-- Popust za djecu se obraèunava 50% na ukupnu cijenu za djecu. Obavezno testirati ispravnost kreirane procedure.
--10 bodova

CREATE PROCEDURE proc_SifraZarada
(
@Sifra nvarchar(10)
)
AS
BEGIN

SELECT I.Naziv AS Naziv,SUM(P.BrojOdraslih)*I.Cijena AS ZaradaOdrasli,(SUM(P.BrojDjece)*I.Cijena)*0.5 AS ZaradaDjeca,SUM(P.BrojOdraslih)*I.Cijena +(SUM(P.BrojDjece)*I.Cijena)*0.5 AS Ukupno
FROM Izleti AS I INNER JOIN Prijave AS P ON P.IzletID=I.IzletID
WHERE I.Sifra=@Sifra
GROUP BY I.Naziv,I.Cijena

END

EXEC proc_SifraZarada 'sifra1'


--8.	a) Kreirati tabelu IzletiHistorijaCijena u koju je potrebno pohraniti 
--identifikator izleta kojem je cijena izmijenjena, datum izmjene cijene, staru i novu cijenu.
-- Voditi raèuna o tome da se jednom izletu može više puta mijenjati cijena te svaku izmjenu treba zapisati u ovu tabelu.
CREATE TABLE IzletiHistorijaCijena
(
IHCID int constraint PK_IHCD primary key identity(1,1),
IzletID int constraint FK_Izlet foreign key(IzletID) references Izleti(IzletID),
DatumIzmjene date,
StaraCijena decimal(8,2),
NovaCijena decimal(8,2)
)
--b) Kreirati trigger koji æe pratiti izmjenu cijene u tabeli Izleti
-- te za svaku izmjenu u prethodno kreiranu tabelu pohraniti podatke izmijeni.


CREATE TRIGGER tr_izmjene
    ON Izleti
    AFTER UPDATE
    AS
    BEGIN
    SET NOCOUNT ON;
	INSERT INTO IzletiHistorijaCijena
	SELECT D.IzletID,GETDATE(),D.Cijena,I.Cijena
	FROM deleted AS D INNER JOIN Izleti AS I ON I.IzletID=D.IzletID




    END

UPDATE Izleti
SET Cijena=Cijena+10
WHERE Sifra='sifra1'

SELECT * FROM IzletiHistorijaCijena


--c) Za odreðeni izlet (proizvoljno) ispisati sljdedeæe podatke: naziv izleta,
-- datum polaska, datum povratka, trenutnu cijenu te kompletnu historiju izmjene 
--cijena tj. datum izmjene, staru i novu cijenu.
--20 bodova

SELECT I.Naziv AS Naziv,I.DatumPolaska AS DatPolaska,I.DatumPovratka AS DatPovratka,IHC.DatumIzmjene AS DatumIzmjene,IHC.StaraCijena AS StaraCijena,IHC.NovaCijena AS TrenutnaCijena
FROM Izleti AS I INNER JOIN IzletiHistorijaCijena AS IHC ON I.IzletID=IHC.IzletID
WHERE Sifra='sifra1'

--9.	Obrisati sve klijente koji nisu imali niti jednu prijavu na izlet. 
--										10 bodova
DELETE 
FROM Klijenti 
WHERE Klijenti.KlijentID NOT IN (SELECT K.KlijentID FROM Prijave AS P INNER JOIN Klijenti AS K ON P.KlijentID=K.KlijentID)


--10.	Kreirati full i diferencijalni backup baze podataka na lokaciju servera D:\BP2\Backup		  5 bodova
BACKUP DATABASE ispit250917 TO DISC='D:\BP2\Backup\ispit250917.bak'

--bez navodjenja putanje
BACKUP DATABASE ispit250917 TO DISC='ispit250917.bak'
WITH DIFFERENTIAL

