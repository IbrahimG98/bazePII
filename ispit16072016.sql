/*
1. Kroz SQL kod, napraviti bazu podataka koja nosi ime vašeg broja dosijea. U postupku kreiranja u
obzir uzeti samo DEFAULT postavke.

Unutar svoje baze podataka kreirati tabelu sa sljedeæom strukturom:
a) Proizvodi:
I. ProizvodID, automatski generatpr vrijednosti i primarni kljuè
II. Sifra, polje za unos 10 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
III. Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
IV. Cijena, polje za unos decimalnog broja (obavezan unos)

b) Skladista
I. SkladisteID, automatski generator vrijednosti i primarni kljuè
II. Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
III. Oznaka, polje za unos 10 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
IV. Lokacija, polje za unos 50 UNICODE karaktera (obavezan unos)

c) SkladisteProizvodi
I) Stanje, polje za unos decimalnih brojeva (obavezan unos)

Napomena: Na jednom skladištu može biti uskladišteno više proizvoda, dok isti proizvod može biti
uskladišten na više razlièitih skladišta. Onemoguæiti da se isti proizvod na skladištu može pojaviti više
puta.
*/
CREATE DATABASE ispit16072016

CREATE TYPE alias   /* Ime alias NOT NULL,*/
FROM nvarchar (100)

USE ispit16072016

create table Proizvodi
(
 ProizvodID int constraint PK_Proizvodi PRIMARY KEY IDENTITY(1,1),
 Sifra NVARCHAR(10) CONSTRAINT UQ_Sifra UNIQUE NONCLUSTERED NOT NULL,
 Naziv NVARCHAR(50) NOT NULL,
 Cijena DECIMAL(8,2) NOT NULL
)

CREATE TABLE Skladista
(
 SkladisteID int constraint PK_Skladista primary key identity(1,1),
 Naziv nvarchar(50) not null,
 Oznaka nvarchar(10) constraint UQ_Oznaka UNIQUE NONCLUSTERED NOT NULL,
 Lokacija NVARCHAR(50) NOT NULL
)

CREATE TABLE SkladisteProizvodi
(
SkladisteID INT CONSTRAINT FK_SkladisteProizvodi_Skladiste FOREIGN KEY(SkladisteID) references Skladista(SkladisteID),
ProizvodID INT CONSTRAINT FK_SkladisteProizvodi_Proizvodi FOREIGN KEY(ProizvodID) references Proizvodi(ProizvodID),
constraint PK_SkladistaProizvodi PRIMARY KEY(SkladisteID,ProizvodID),
 Stanje decimal(8,2) not null
)

/*
2. Popunjavanje tabela podacima
a) Putem INSERT komande u tabelu Skladista dodati minimalno 3 skladišta.

b) Koristeæi bazu podataka AdventureWorks2014, preko INSERT i SELECT komande importovati
10 najprodavanijih bicikala (kategorija proizvoda 'Bikes' i to sljedeæe kolone:
I. Broj proizvoda (ProductNumber) - > Sifra,
II. Naziv bicikla (Name) -> Naziv,
III. Cijena po komadu (ListPrice) -> Cijena,

c) Putem INSERT i SELECT komandi u tabelu SkladisteProizvodi za sva dodana skladista
importovati sve proizvode tako da stanje bude 100
*/

--a

INSERT INTO Skladista
VALUES ('Skladiste1','A100-50','Mostar'),
		('Skladiste2','A100-51','Sarajevo'),
		('Skladiste3','A100-52','Tuzla')

		select * from Skladista

--b
INSERT INTO Proizvodi
SELECT top 10 P.ProductNumber,P.Name,P.ListPrice
FROM AdventureWorks2014.Production.Product AS P INNER JOIN AdventureWorks2014.Production.ProductSubcategory AS PS
	 ON P.ProductSubcategoryID = PS.ProductSubcategoryID INNER JOIN AdventureWorks2014.Production.ProductCategory AS PC
	 ON PS.ProductCategoryID = PC.ProductCategoryID INNER JOIN AdventureWorks2014.Sales.SalesOrderDetail AS SOD
	 ON P.ProductID = SOD.ProductID
WHERE PC.Name = 'Bikes'
GROUP BY  P.ProductNumber,P.Name,P.ListPrice
ORDER BY SUM(SOD.OrderQty) desc

select * from Proizvodi


INSERT INTO SkladisteProizvodi
SELECT 3,ProizvodID,100
FROM  Proizvodi

SELECT * FROM SkladisteProizvodi






/*
3. Kreirati uskladištenu proceduru koja æe vršiti poveæanje stanja skladišta za odreðeni proizvod na
odabranom skladištu. Provjeriti ispravnost procedure
*/
CREATE PROCEDURE proc_SkladisteProizvodi_update
(
@SkladisteID INT,
@ProizvodID INT,
@NovoStanje DECIMAL(8,2)
)
AS
BEGIN
UPDATE SkladisteProizvodi
SET Stanje = Stanje + @NovoStanje
WHERE SkladisteID = @SkladisteID and ProizvodID =@ProizvodID
END

select * from SkladisteProizvodi

exec proc_SkladisteProizvodi_update 1,3,15



/*
4. Kreiranje indeksa u bazi podataka nad tabelama
a) Non-clustered indeks nad tabelom Proizvodi. Potrebno je indeksirati Sifru i Naziv. Takoðer,
potrebno je ukljuèiti kolonu Cijena
b) Napisati proizvoljni upit nad tabelom Proizvodi koji u potpunosti iskorištava indeks iz
prethodnog koraka
c) Uradite disable indeksa iz koraka a)
*/

--a
DROP INDEX IX_Sifra_Naziv ON Proizvodi
create nonclustered index IX_Sifra_Naziv
ON Proizvodi(Sifra,Naziv)
include(Cijena)

--b

select Sifra,Naziv
from Proizvodi
WHERE Naziv LIKE '%[0-5]' AND Sifra LIKE '%[0-5]'

ALTER INDEX IX_Sifra_Naziv ON Proizvodi
disable




/*
5. Kreirati view sa sljedeæom definicijom. Objekat treba da prikazuje sifru, naziv i cijenu proizvoda,
oznaku, naziv i lokaciju skladišta, te stanje na skladištu.
*/

CREATE VIEW prvi_pogled
AS
SELECT P.Sifra,P.Naziv as Proizvod,P.Cijena,
		S.Oznaka,S.Naziv as Skladiste,S.Lokacija,
		SP.Stanje
FROM Proizvodi as P INNER JOIN SkladisteProizvodi as SP
	 ON P.ProizvodID = SP.ProizvodID INNER JOIN Skladista AS S
	 ON SP.SkladisteID = S.SkladisteID



/*
6. Kreirati uskladištenu proceduru koja æe na osnovu unesene šifre proizvoda prikazati ukupno stanje
zaliha na svim skladištima. U rezultatu prikazati sifru, naziv i cijenu proizvoda te ukupno stanje zaliha.
U proceduri koristiti prethodno kreirani view. Provjeriti ispravnost kreirane procedure
*/
create procedure proc_PrikaziUkupStanj
(
@Sifra NVARCHAR(10)
)
AS
BEGIN
SELECT Sifra,Proizvod,Cijena,SUM(Stanje) AS [Ukupno stanje]
FROM prvi_pogled
WHERE Sifra = @Sifra
GROUP BY Sifra,Proizvod,Cijena
END

SELECT * FROM prvi_pogled

EXEC proc_PrikaziUkupStanj 'BK-R50B-52'


/*
7. Kreirati uskladištenu proceduru koja æe vršiti upis novih proizvoda, te kao stanje zaliha za uneseni
proizvod postaviti na 0 za sva skladišta. Provjeriti ispravnost kreirane procedure.
*/

ALTER PROCEDURE proc_Proizvodi_Insert
(
@Sifra NVARCHAR(10),
@Naziv nvarchar(50),
@Cijena DECIMAL(8,2)
)
AS
BEGIN
INSERT INTO Proizvodi
VALUES (@Sifra,@Naziv,@Cijena)

INSERT INTO SkladisteProizvodi
SELECT SkladisteID,(SELECT ProizvodID FROM Proizvodi WHERE Sifra = @Sifra),0
FROM Skladista
END

EXEC proc_Proizvodi_Insert 'Sifra2','Kola',2.5

SELECT * FROM SkladisteProizvodi

/*
8. Kreirati uskladištenu proceduru koja æe za unesenu šifru proizvoda vršiti brisanje proizvoda
ukljuèujuæi stanje na svim skladištima. Provjeriti ispravnost procedure.
*/

create procedure proc_Proizvodi_delete
(
@Sifra NVARCHAR(10)
)
AS
BEGIN
DELETE FROM SkladisteProizvodi
WHERE ProizvodID IN (
					SELECT ProizvodID
					FROM Proizvodi
					WHERE Sifra = @Sifra
					)

DELETE FROM Proizvodi
WHERE Sifra = @Sifra
END

exec proc_Proizvodi_delete 'Sifra2'


/*
9. Kreirati uskladištenu proceduru koja æe za unesenu šifru proizvoda, oznaku skladišta ili lokaciju
skladišta vršiti pretragu prethodno kreiranim view-om (zadatak 5). Procedura obavezno treba da
vraæa rezultate bez obrzira da li su vrijednosti parametara postavljene. Testirati ispravnost procedure
u sljedeæim situacijama:
a) Nije postavljena vrijednost niti jednom parametru (vraæa sve zapise)
b) Postavljena je vrijednost parametra šifra proizvoda, a ostala dva parametra nisu
c) Postavljene su vrijednosti parametra šifra proizvoda i oznaka skladišta, a lokacija
nije
d) Postavljene su vrijednosti parametara šifre proizvoda i lokacije, a oznaka skladišta
nije
e) Postavljene su vrijednosti sva tri parametra
*/

alter procedure proc_Preteraga
(
@Sifra NVARCHar(10) = null,
@Oznaka nvarchar(10) = null,
@Lokacija nvarchar(50) = null
)
as
begin
select *
from prvi_pogled
WHERE (Sifra = @Sifra or @Sifra is null) and ( Oznaka = @Oznaka or @Oznaka is null)
		and (Lokacija = @Lokacija OR @Lokacija is null)
end

exec proc_Preteraga
exec proc_Preteraga 'BK-M68S-42'
exec proc_Preteraga 'BK-M68S-42','A100-50'
exec proc_Preteraga @Sifra = 'BK-M68S-42',@Lokacija = 'Sarajevo'

exec proc_Preteraga 'BK-M68S-42',,'Sarejevo'




/*
10. Napraviti full i diferencijalni backup baze podataka na default lokaciju servera:

*/