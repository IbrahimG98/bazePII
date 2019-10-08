--/* Baze podataka II (Integralni ispit) */ 24.06.2019.
--1/2
--1. Koristeci iskljucivo SQL kod, kreirati bazu pod vlastitim brojem indeksa sa defaultnim postavkama.
--Unutar svoje baze podataka kreirati tabele sa sljedecom strukturom:
CREATE DATABASE ispit062019
USE  ispit062019
--a) Narudzba
--- NarudzbaID, primarni kljuc
--- Kupac, 40 UNICODE karakter
--- PunaAdresa, 80 UNICODE karakter
--- DatumNarudzbe, datumska varijabla, definirati kao datum
--- Prevoz, novcana varijabla
--- Uposlenik, 40 UNICODE karakter
--- GradUposlenika, 30 UNICODE karakter
--- DatumZaposlenja, datumska varijabla, definirati kao datum
--- BtGodStaza, cjelobrojna varijabla

CREATE TABLE Narudzba
(
NarudzbaID int constraint pk_narudzba primary key(NarudzbaID),
Kupac nvarchar(40),
PunaAdresa nvarchar(80),
DatumNarudzbe date,
Prevoz money,
Uposlenik nvarchar(40),
GradUposlenika nvarchar(30),
DatumZaposlenja date,
BrGodStaza int

)
--b) Proizvod
--- ProizvodID, cjelobrojna varijabla, primarni kljuc
--- NazivProizoda, 40 UNICODE karakter
--- NazivDobavljaca, 40 UNICODE karakter
--- StanjeNaSklad, cjelobrojna varijabla
--- NarucenaKol, cjelobrojna varijabla

CREATE TABLE Proizvod
(
ProizvodID int constraint pk_proizvodid primary key(ProizvodID),
NazivProizvoda nvarchar(40),
NazivDobavljaca nvarchar(40),
StanjeNaSklad int,
NarucenaKol int
)
--c) DetaljiNarudzbe
--- NarudzbaID, cjelobrojna varijabla, obavezan unos
--- ProizvodID, cjelobrojna varijabla, obavezan unos
--- CijenaProizvoda, novcana varijabla
--- Kolicina, cjelobrojna varijabla, obavezan unos
--- Popoust, varijabla za realne vrijednosti
CREATE TABLE DetaljiNarudzbe
(
NarudzbaID int constraint fk_narudzbaid foreign key (NarudzbaID) references Narudzba(NarudzbaID),
ProizvodID int constraint fk_proizvodid foreign key (ProizvodID) references Proizvod(ProizvodID),
CijenaProizvoda money,
Kolicina int not null,
Popust real,
constraint pk_DetaljiNarudzbe primary key (NarudzbaID,ProizvodID)
)
--Napomena: Na jednoj narudzbi se nalazi jedan ili vise proizvoda.
--(15 bodova)

--2. Import podataka u kreirane tabele.
--a) Narudzbe
--Koristeci bazu Northwind iz tabela Orders, Customers i Employees importovati podatke po sljedecem pravilu:
--- OrderID -> ProizvodID
--- CompanyName -> Kupac
--- PunaAdresa – spojeno adresa, postanski broj I grad, pri cemu ce se izmedju rijeci staviti srednja crta sa razmakom
--prije I poslije nje
--- OrderDate -> DatumNarudzbe
--- Freight -> Prevoz
--- Uposlenik – spojeno prezime I ime sa razmakom izmedju njih
--- City -> Grad iz kojeg je uposlenik
--- HireDate -> DatumZaposlenja
--- BrGodStaza – broj godina od datuma zaposlenja
INSERT INTO Narudzba
SELECT O.OrderID,C.CompanyName,C.Address+' - '+C.PostalCode+' - '+C.City,O.OrderDate,O.Freight,E.FirstName+' '+E.LastName,E.City,E.HireDate,DATEDIFF(YEAR,E.HireDate,GETDATE())
FROM Northwind.dbo.Orders AS O INNER JOIN Northwind.dbo.Employees AS E ON O.EmployeeID=E.EmployeeID INNER JOIN Northwind.dbo.Customers AS C ON O.CustomerID=C.CustomerID

--b) Proizvod
--Koristeci bazu Northwind iz tabela Products I Suppliers putem podupita importovati podake po sljedecem pravilu:
--- ProductID -> ProizvodID
--- ProductName -> NazivProizvoda
--- CompanyName -> NazivDobavljaca
--- UnitsInStock -> StanjeNaSklad
--- UnitsOnOrder -> NarucenaKol
INSERT INTO Proizvod
SELECT P.ProductID,P.ProductName,P.CompanyName,P.UnitsInStock,P.UnitPrice
FROM (
    SELECT P.ProductID,P.ProductName,S.CompanyName,P.UnitsInStock,P.UnitPrice
	FROM Northwind.dbo.Products AS P INNER JOIN Northwind.dbo.Suppliers AS S ON P.SupplierID=S.SupplierID
) AS P
--c) DetaljiNarudzbe
--Koristeci bazu Northwind iz tabele OrderDetails importovati podake po sljedecem pravilu:
--- OrderID -> NarudzbaID
--- ProductID -> ProizvodID
--- CijenaProizvoda – manja zaokruzena vrijednost kolone UnitPrice, npr UnitPrice = 3,60 / CijenaProizvoda = 3,00
--(15 bodova)
INSERT INTO DetaljiNarudzbe
SELECT OD.OrderID,OD.ProductID,FLOOR(OD.UnitPrice),OD.Quantity,OD.Discount
FROM Northwind.dbo.[Order Details] AS OD 

--a)


--3. a) U tabelu Narudzba dodati kolonu SifraUposlenika kao 20 UNICODE karaktera.
-- Postaviti uslov da podatak mora biti duzine
--tacno 15 karaktera/* Baze podataka II (Integralni ispit) */ 24.06.2019.
ALTER TABLE Narudzba
ADD SifraUposlenika nvarchar(20) constraint CK_Sifra CHECK(LEN(SifraUposlenika)=15)
--2/2
--b) Kolonu SifraUpooslenika popuniti na nacin da se obrne string koji se dobije spajanjem grada uposlenika
-- I prvih 10 karaktera
--datuma zaposlenja pri cemu se izmedju grada I 10 karaktera nalazi jedno prazno mjesto. 
--Provjeriti da li je izvrsena izmjena.
UPDATE Narudzba
SET SifraUposlenika=REVERSE(LEFT(GradUposlenika,4)+' '+CAST(DatumZaposlenja as nvarchar(10)))
SELECT * FROM Narudzba

--c) U tabeli Narudzba u koloni SifraUposlenika izvrsiti zamjenu svih zapisa kojima grad uposlenika zavrsava slovom “d” 
--tako da
--se umjesto toga ubaci slucajno generisani string duzine 20 karaktera. Provjeriti da li je izvrsena zamjena.
ALTER TABLE Narudzba
DROP CONSTRAINT CK_Sifra
UPDATE Narudzba
SET SifraUposlenika=LEFT(newid(),20)
WHERE GradUposlenika LIKE '%d'
SELECT * FROM Narudzba
--(15 odova)
--4. Koristeci svoju bazu iz tabela Narudzba I DetaljiNarudzbe kreirati pogled koji ce imati sljedecu strukturu: Uposlenik,
--SifraUposlenika, ukupan broj proizvoda izveden iz NazivProizvoda, uz uslove da je sifra uposlenika 20 karaktera, te da je
--ukupan broj proizvoda veci od 2. Provjeriti sadrzaj pogleda,
-- pri cemu se treba izvrsiti sortiranje po ukupnom broju proizvoda u
--opadajucem redosljedu
CREATE VIEW pogled_prvi
AS
SELECT N.Uposlenik,N.SifraUposlenika,COUNT(P.NazivProizvoda) AS Ukupno
FROM Narudzba AS N INNER JOIN DetaljiNarudzbe AS DN ON DN.NarudzbaID=N.NarudzbaID INNER JOIN Proizvod AS P ON DN.ProizvodID=P.ProizvodID
WHERE LEN(N.SifraUposlenika)=20
GROUP BY N.Uposlenik,N.SifraUposlenika
HAVING COUNT(P.NazivProizvoda)>2

SELECT * FROM pogled_prvi
ORDER BY Ukupno desc

--(12 bodova)
--5. Koristeci vlastitu bazu kreirati proceduru nad tabelom Narudzbe kojom ce se duzina podataka u koloni SifraUposlenika
--smanjiti sa 20 na 4 slucajno generisana karaktera. Pokrenuti proceduru.
CREATE PROCEDURE proc_updateSifre
AS
BEGIN
UPDATE Narudzba
SET SifraUposlenika=LEFT(newid(),4)
WHERE LEN(SifraUposlenika)=20
END
EXEC proc_updateSifre
SELECT * FROM Narudzba
--(3 bodova)
--55 bodova – granica za 6
--6. Koristeci vlastitu bazu kreirati pogled koji ce imati sljedecu strukturu: NazivProizvoda, Ukupno – ukupnu sumu prodaje
--proizvoda uz uzimanje u obzir I popusta. Suma mora biti zaokruzena na dvije decimale. U pogled uvrstiti one proizvode koji 
--su
--naruceni, uz uslov da je suma veca od 1000. 
--Provjeriti sadrzaj pogleda pri cemu ispis treba sortirati u opadajucem redoslijedu
--po vrijednosti sume.
--(10 bodova)
CREATE VIEW pogled_drugi
AS
SELECT P.NazivProizvoda,ROUND(SUM((DN.CijenaProizvoda-(DN.CijenaProizvoda*DN.Popust))*DN.Kolicina),2) AS Ukupno
FROM Proizvod AS P INNER JOIN DetaljiNarudzbe AS DN ON DN.ProizvodID=P.ProizvodID
WHERE P.NarucenaKol>0
GROUP BY P.NazivProizvoda
HAVING SUM((DN.CijenaProizvoda-(DN.CijenaProizvoda*DN.Popust))*DN.Kolicina)>1000
--65 bodova – granica za 7
--7. a) Koristeci vlastitu bazu podataka kreirati pogled koji ce imati sljedecu strukturu:
--- Kupac,
--- NazivProizvoda
--- Suma po cijeni proizvoda
--Pri cemu ce se u pogled smjestiti samo oni zapisi kod kojih je cijena proizvoda veca od srednje vrijednosti cijene proizvoda.
--Provjeriti sadrzaj pogleda pri cemu izlaz treba sortirati u rastucem redoslijedu izracunatoj sumi.
CREATE VIEW pogled_treci
AS
SELECT N.Kupac,P.NazivProizvoda,SUM(DN.CijenaProizvoda) AS Suma
FROM DetaljiNarudzbe AS DN INNER JOIN Proizvod AS P ON DN.ProizvodID=P.ProizvodID INNER JOIN Narudzba AS N ON DN.NarudzbaID=N.NarudzbaID
WHERE DN.CijenaProizvoda > (SELECT AVG(D.CijenaProizvoda)
FROM DetaljiNarudzbe AS D)
GROUP BY N.Kupac,P.NazivProizvoda

SELECT * FROM pogled_treci
ORDER BY Suma asc
--(10 bodova)
--75 bodova – granica za 8
--b) Koristeci vlastitu bazu podataka kreirati proceduru kojom ce se, koristeci prethodno kreirani pogled,
-- definirati parametri:
--Kupac, NazivProizvoda I SumaPoCijeni. Proceduru kreirati tako da je prilikom izvrsavanja moguce unijeti bilo koji broj
--parametara (mozemo ostaviti bilo koji parametar bez unijete vrijednosti), uz uslov da vrijednost sume bude veca od srednje
--vrijednosti suma koje su smjestene u pogled. Sortirati po sumi cijene. Procedura se treba izvrsiti ako se unese vrijednost za bilo
--koji parametar. Nakon kreiranja pokrenuti proceduru za sljedece vrijednosti parametara:
--1. SumaPoCijeni = 123
--2. Kupac = Hanari Carnes
--3. NazivProizvoda = Cote de Blaye
--(10 bodova)
CREATE PROCEDURE proc_1
(@Kupac nvarchar(40)=null,
@NazivProizvoda nvarchar(40)=null,
@SumaPoCijeni decimal(8,2)=null)
AS 
BEGIN
SELECT Kupac,NazivProizvoda,Suma
FROM pogled_treci 
WHERE Suma > (SELECT AVG(Suma)
FROM pogled_treci) AND (Kupac=@Kupac OR @Kupac is null) AND (NazivProizvoda=@NazivProizvoda OR @NazivProizvoda is null)
AND (Suma=@SumaPoCijeni OR @SumaPoCijeni is null)
END
EXEC proc_1
EXEC proc_1 'Hanari Carnes'
EXEC proc_1 @NazivProizvoda='Côte de Blaye'

--85 bodova – granica za 9
--8. a) Kreirati indeks nad tabelom Proizvod. Potrebno je indeksirati NazivDobavljaca. Ukljuciti I kolone StanjeNaSklad I
--NarucenaKol. Napisati proizvoljni upit nad tabelom Proizvod koji u potpunosti koristi prednost kreiranog indeksa.
CREATE NONCLUSTERED INDEX IX_Proizvod ON Proizvod(NazivDobavljaca)
INCLUDE (StanjeNaSklad,NarucenaKol)

SELECT NazivDobavljaca,StanjeNaSklad
FROM Proizvod
WHERE StanjeNaSklad>50

--b) Uraditi disable indeksa iz prethodnog koraka.
--(5 bodova)
ALTER INDEX IX_Proizvod ON Proizvod
DISABLE  

--9. Napraviti backup baze podataka na default lokaciju servera.
--(5 bodova)
BACKUP DATABASE ispit062019 to disc='ispit062019.bak'
--95 bodova – granica za 10
--10. Kreirati proceduru kojom ce se u jednom pokretanju izvrsiti brisanje svih pogleda I procedura koji su kreirani u vasoj bazi.
--(5 bodova)
CREATE PROCEDURE proc_brisisve
AS 
BEGIN
DROP VIEW pogled_prvi
DROP VIEW pogled_drugi
DROP VIEW pogled_treci
DROP PROCEDURE proc_1
DROP PROCEDURE proc_updateSifre
DROP PROCEDURE proc_brisisve


END
EXEC proc_brisisve

--100 bodova