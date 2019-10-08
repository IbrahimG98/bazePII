/*
1. Kroz SQL kod, napraviti bazu podataka koja nosi ime va�eg broja dosijea. U postupku kreiranja u
obzir uzeti samo DEFAULT postavke.

Unutar svoje baze podataka kreirati tabelu sa sljede�om strukturom:
a) Proizvodi:
I. ProizvodID, automatski generatpr vrijednosti i primarni klju�
II. Sifra, polje za unos 10 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
III. Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
IV. Cijena, polje za unos decimalnog broja (obavezan unos)

b) Skladista
I. SkladisteID, automatski generator vrijednosti i primarni klju�
II. Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
III. Oznaka, polje za unos 10 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
IV. Lokacija, polje za unos 50 UNICODE karaktera (obavezan unos)

c) SkladisteProizvodi
I) Stanje, polje za unos decimalnih brojeva (obavezan unos)

Napomena: Na jednom skladi�tu mo�e biti uskladi�teno vi�e proizvoda, dok isti proizvod mo�e biti
uskladi�ten na vi�e razli�itih skladi�ta. Onemogu�iti da se isti proizvod na skladi�tu mo�e pojaviti vi�e
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
a) Putem INSERT komande u tabelu Skladista dodati minimalno 3 skladi�ta.

b) Koriste�i bazu podataka AdventureWorks2014, preko INSERT i SELECT komande importovati
10 najprodavanijih bicikala (kategorija proizvoda 'Bikes' i to sljede�e kolone:
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
3. Kreirati uskladi�tenu proceduru koja �e vr�iti pove�anje stanja skladi�ta za odre�eni proizvod na
odabranom skladi�tu. Provjeriti ispravnost procedure
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
a) Non-clustered indeks nad tabelom Proizvodi. Potrebno je indeksirati Sifru i Naziv. Tako�er,
potrebno je uklju�iti kolonu Cijena
b) Napisati proizvoljni upit nad tabelom Proizvodi koji u potpunosti iskori�tava indeks iz
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
5. Kreirati view sa sljede�om definicijom. Objekat treba da prikazuje sifru, naziv i cijenu proizvoda,
oznaku, naziv i lokaciju skladi�ta, te stanje na skladi�tu.
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
6. Kreirati uskladi�tenu proceduru koja �e na osnovu unesene �ifre proizvoda prikazati ukupno stanje
zaliha na svim skladi�tima. U rezultatu prikazati sifru, naziv i cijenu proizvoda te ukupno stanje zaliha.
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
7. Kreirati uskladi�tenu proceduru koja �e vr�iti upis novih proizvoda, te kao stanje zaliha za uneseni
proizvod postaviti na 0 za sva skladi�ta. Provjeriti ispravnost kreirane procedure.
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
8. Kreirati uskladi�tenu proceduru koja �e za unesenu �ifru proizvoda vr�iti brisanje proizvoda
uklju�uju�i stanje na svim skladi�tima. Provjeriti ispravnost procedure.
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
9. Kreirati uskladi�tenu proceduru koja �e za unesenu �ifru proizvoda, oznaku skladi�ta ili lokaciju
skladi�ta vr�iti pretragu prethodno kreiranim view-om (zadatak 5). Procedura obavezno treba da
vra�a rezultate bez obrzira da li su vrijednosti parametara postavljene. Testirati ispravnost procedure
u sljede�im situacijama:
a) Nije postavljena vrijednost niti jednom parametru (vra�a sve zapise)
b) Postavljena je vrijednost parametra �ifra proizvoda, a ostala dva parametra nisu
c) Postavljene su vrijednosti parametra �ifra proizvoda i oznaka skladi�ta, a lokacija
nije
d) Postavljene su vrijednosti parametara �ifre proizvoda i lokacije, a oznaka skladi�ta
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