--BAZE PODATAKA - PRIMJER PRAKTIČNOG ISPITA


--1. Koristeći izričito SQL kod kreirati bazu podataka (sa default-nim postavkama) pod nazivom Broj Vašeg dosijea, a zatim u njoj kreirati tabele prema datom opisu pri čemu treba omogućiti da se u primarne ključeve mogu insertovati vrijednosti iz drugih tabela.  
CREATE DATABASE pripremni31052019
USE pripremni31052019
--a) Narudzba  
--	NarudzbaID 		cjelobrojna vrijednost, primarni ključ
--	DatumNarudzbe 	datumska varijabla (samo datum)
--	DatumPrijema 		datumska varijabla (samo datum)
--	DatumIsporuke 	datumska varijabla (samo datum)
--	TrosakPrevoza 		novčani tip
--	PunaAdresa 		70 UNICODE znakova
CREATE TABLE Narudzba
(
NarudzbaID int constraint PK_NarudzbaID primary key(NarudzbaID),
DatumNarudzbe date,
DatumPrijema date,
DatumIsporuke date,
TrosakPrevoza money,
PunaAdresa nvarchar(70)

)


--b) Dobavljac
--	DobavljacID 		cjelobrojna vrijednost, primarni ključ
--	NazivDobavljaca	40 UNICODE znakova, obavezan unos
--	PunaAdresa 		60 UNICODE znakova
--	Drzava 				15 UNICODE znakova
CREATE TABLE Dobavljac
(
DobavljacID int constraint PK_DobavljacID primary key(DobavljacID),
NazivDobavljaca nvarchar(40) not null,
PunaAdresa nvarchar(60),
Drzava nvarchar(15)
)
--c) Proizvod
--	NarudzbaID			cjelobrojna vrijednost, primarni ključ
--	DobavljacID 		cjelobrojna vrijednost, obavezan unos
--	ProizvodID 			cjelobrojna vrijednost, obavezan unos
--	NazivProizvoda 	40 UNICODE znakova, obavezan unos
--	Cijena 				cjelobrojna vrijednost, obavezan unos
--	Kolicina 				cjelobrojna vrijednost, obavezan unos
--	Popust 				decimalna vrijednost, obavezan unos
--	Raspolozivost 		bit, obavezan unos 
CREATE TABLE Proizvod
(
NarudzbaID int constraint FK_Narudzba foreign key (NarudzbaID) references Narudzba(NarudzbaID) not null,
DobavljacID int constraint FK_Dobavljac foreign key (DobavljacID) references Dobavljac(DobavljacID) not null,
ProizvodID int not null,
NazivProizvoda nvarchar(40) not null,
Cijena int not null,
Kolicina int not null,
Popust decimal(8,2) not null,
Raspolozivost bit not null,
constraint Pk_Proizvod primary key(NarudzbaID,DobavljacID,ProizvodID)


)
--Primarni ključ tabele se sastoji od prva tri polja.
--________________________________________________________________________________________________
--2. 
--a) U tabelu Narudzba insertovati podatke iz tabele Orders baze Northwind pri čemu će puna adresa biti sačinjena od 
--adrese, poštanskog broja i grada isporuke. Između dijelova adrese umetnuti prazno mjesto.
-- Ukoliko nije unijeta vrijednost poštanskog broja zamijeniti je sa 00000.
-- Uslov je da se insertuju zapisi iz 1997. i većih godina (1998, 1999...), te da postoji datum isporuke.
-- Zapise sortirati po vrijednosti troška prevoza.
--	OrderID -> NarudzbaID
--	OrderDate -> DatumNarudzbe 	
--	RequiredDate -> DatumPrijema 		
--	ShippedDate -> DatumIsporuke 	
--	Freight -> TrosakPrevoza 		
--	PunaAdresa (sastaviti prema navedenom obrascu)
INSERT INTO Narudzba
SELECT O.OrderID,O.OrderDate,O.RequiredDate,O.ShippedDate,O.Freight,O.ShipAddress+' '+ISNULL(O.ShipPostalCode,'00000')+' '+O.ShipCity
FROM Northwind.dbo.Orders AS O
WHERE YEAR(O.OrderDate)>=1997    --ili datepart(year,O.OrderDate)
ORDER BY O.Freight
--b) U tabelu Dobavljac insertovati zapise iz tabele Suppliers baze Northwind.
-- Puna adresa će se sastojati od adrese, poštanskog broja i grada dobavljača.
--	SupplierID -> DobavljacID
--	CompanyName -> NazivDobavljaca
--	PunaAdresa (sastaviti prema navedenom obrascu)
--	Country -> Drzava
INSERT INTO Dobavljac
SELECT S.SIDe,S.SN,S.Adresa,S.SDr
FROM (SELECT S.SupplierID AS SIDe,S.CompanyName AS SN,S.Address+S.PostalCode+S.City AS Adresa,S.Country AS SDr FROM Northwind.dbo.Suppliers AS S   
) AS S

--c) U tabelu Proizvod insertovati zapise iz odgovarajućih kolona tabela Order Details
-- i Product uz uslov da vrijednost cijene bude veća od 10, te da je na proizvod odobren popust.
-- S obzirom na zadatak 2a voditi računa o postavljanju odgovarajućeg uslova da ne bi došlo do konflikta u
-- odnosu na NarudzbaID - potrebno je postaviti uslov da se insertuju zapisi iz 1997. i većih godina (1998, 1999...), 
--te da postoji datum isporuke.
--	OrderID -> NarudzbaID			
--	SupplierID -> DobavljacID 		
--	ProductID -> ProizvodID 			
--	ProductName -> NazivProizvoda 	
--	UnitPrice -> Cijena 				
--	Quatntity -> Kolicina 				
--	Discount -> Popust 				
--	Discontinued -> Raspolozivost
INSERT INTO Proizvod
SELECT O.OrderID,P.SupplierID,P.ProductID,P.ProductName,P.UnitPrice,OD.Quantity,OD.Discount,P.Discontinued
FROM Northwind.dbo.[Order Details] AS OD INNER JOIN Northwind.dbo.Products AS P ON OD.ProductID=P.ProductID 
INNER JOIN Northwind.dbo.Orders AS O ON OD.OrderID=O.OrderID
WHERE YEAR(O.OrderDate)>=1997 AND P.UnitPrice>10 AND P.Discontinued=1 
--3. 	Iz tabele Proizvod dati pregled ukupnog broja ostvarenih narudzbi po dobavljaču i proizvodu.
--________________________________________________________________________________________________

SELECT D.NazivDobavljaca ,NazivProizvoda,COUNT(P.NarudzbaID) AS BrojNarudzbi
FROM Proizvod AS P INNER JOIN Dobavljac AS D ON P.DobavljacID=D.DobavljacID INNER JOIN Narudzba AS N ON P.NarudzbaID=N.NarudzbaID
GROUP BY D.NazivDobavljaca,NazivProizvoda
--4. 	Iz tabele Proizvod dati pregled ukupnog prometa ostvarenog po dobavljaču i narudžbi uz 
--uslov da se prikažu samo oni zapisi kod kojih je vrijednost prometa manja od 1000 i odobreni popust veći od 10%.
-- Ukupni promet izračunati uz uzimanje u obzir i odobrenog popusta.
--________________________________________________________________________________________________
SELECT D.NazivDobavljaca,N.NarudzbaID,SUM((P.Cijena -(P.Cijena*P.Popust))*P.Kolicina) AS Ukupno
FROM Proizvod AS P INNER JOIN Dobavljac AS D ON P.DobavljacID=D.DobavljacID INNER JOIN Narudzba AS N ON P.NarudzbaID=N.NarudzbaID
WHERE P.Popust >0.1
GROUP BY D.NazivDobavljaca,N.NarudzbaID
HAVING SUM((P.Cijena -(P.Cijena*P.Popust))*P.Kolicina)<1000
--5. Iz tabele Narudzba dati pregled svih narudzbi kod kojih je broj dana od datuma narudžbe do datuma 
--isporuke manji od 10. Pregled će se sastojati od ID narudžbe, broja dana razlike i kalendarske godine,
-- pri čemu je razdvojiti pregled po godinama - 1997 i 1998 (prvo sve 1997, zatim sve 1998). 
--Sortirati po broju dana isporuke u opadajućem redoslijedu.
--________________________________________________________________________________________________
SELECT N.NarudzbaID,DATEDIFF(DAY,N.DatumNarudzbe,N.DatumIsporuke) AS RazlikaDana,DATEPART(YEAR,N.DatumNarudzbe) AS KalendGodina
FROM Narudzba AS N
WHERE YEAR(N.DatumNarudzbe)=1997 AND DATEDIFF(DAY,N.DatumNarudzbe,N.DatumIsporuke)<10
UNION 
SELECT N.NarudzbaID,DATEDIFF(DAY,N.DatumNarudzbe,N.DatumIsporuke) AS RazlikaDana,DATEPART(YEAR,N.DatumNarudzbe) AS KalendGodina
FROM Narudzba AS N
WHERE YEAR(N.DatumNarudzbe)=1998 AND DATEDIFF(DAY,N.DatumNarudzbe,N.DatumIsporuke)<10
ORDER BY RazlikaDana DESC
--6. Iz tabele Narudzba dati pregled svih narudzbi kod kojih je isporuka izvršena u istom mjesecu.
--Pregled će se sastojati od ID narudžbe, broja dana razlike, mjeseca narudžbe, 
--mjeseca isporuke i kalendarske godine, pri čemu je potrebno razdvojiti pregled po godinama
-- (1997 i 1998 - prvo sve 1997, zatim sve 1998). Sortirati po broju dana isporuke u opadajućem redoslijedu.
--________________________________________________________________________________________________

SELECT N.NarudzbaID,DATEDIFF(DAY,N.DatumNarudzbe,N.DatumIsporuke) as RazlikaDana,
		MONTH(N.DatumNarudzbe) as MjesecNarudzbe,MONTH(N.DatumIsporuke) as MjesecIsporuke,
		     YEAR(N.DatumNarudzbe) as Godina
FROM Narudzba AS N 
WHERE MONTH(N.DatumNarudzbe) = MONTH(N.DatumIsporuke) and YEAR(N.DatumNarudzbe) = 1997
union
SELECT N.NarudzbaID,DATEDIFF(DAY,N.DatumNarudzbe,N.DatumIsporuke) as RazlikaDana,
		MONTH(N.DatumNarudzbe) as MjesecNarudzbe,MONTH(N.DatumIsporuke) as MjesecIsporuke,
		     YEAR(N.DatumNarudzbe) as Godina
FROM Narudzba AS N 
WHERE MONTH(N.DatumNarudzbe) = MONTH(N.DatumIsporuke) and YEAR(N.DatumNarudzbe) = 1998
ORDER BY RazlikaDana desc
--7. Iz tabele Narudzba dati pregled svih narudžbi koje su isporučene u Graz ili Köln. 
--Pregled će se sastojati od ID narudžbe i naziva grada. Sortirati po nazivu grada.
--________________________________________________________________________________________________

SELECT N.NarudzbaID,RIGHT(N.PunaAdresa,4) AS Grad
FROM Narudzba AS N 
WHERE RIGHT(N.PunaAdresa,4) LIKE 'Graz' OR RIGHT(N.PunaAdresa,4) LIKE 'Köln'
--8. Iz tabela Narudzba, Dobavljac i Proizvod kreirati pregled koji će se sastojati od polja NarudzbaID,
-- GodNarudzbe kao godinu iz polja DatumNarudzbe, NazivProizvoda, NazivDobavljaca, Drzava, TrosakPrevoza, 
--Ukupno kao ukupna vrijednost narudžbe koja će se računati uz uzimanje u obzir i popusta i postotak koji će davati
-- informaciju o vrijednosti postotka troška prevoza u odnosu na ukupnu vrijenost narudžbe. Uslov je da postotak bude
-- veći od 30% i da je ukupna vrijednost veća od troška prevoza. Sortirati po vrijednosti postotka u opadajućem redoslijedu.
--________________________________________________________________________________________________
SELECT N.NarudzbaID,YEAR(N.DatumNarudzbe) AS GodinaNarudzbe,P.NazivProizvoda,D.NazivDobavljaca,D.Drzava,N.TrosakPrevoza,
SUM((P.Cijena -(P.Cijena*P.Popust))*P.Kolicina) AS Ukupno,N.TrosakPrevoza/SUM((P.Cijena -(P.Cijena*P.Popust))*P.Kolicina) AS PostotakTroskaPrevoza
FROM Narudzba AS N INNER JOIN Proizvod AS P ON N.NarudzbaID=P.NarudzbaID INNER JOIN
 Dobavljac AS D ON D.DobavljacID=P.DobavljacID
 GROUP BY N.NarudzbaID,P.NazivProizvoda,D.NazivDobavljaca,D.Drzava,N.TrosakPrevoza,N.DatumNarudzbe
 HAVING N.TrosakPrevoza/SUM((P.Cijena -(P.Cijena*P.Popust))*P.Kolicina) >0.30 AND SUM((P.Cijena -(P.Cijena*P.Popust))*P.Kolicina) >N.TrosakPrevoza
 ORDER BY PostotakTroskaPrevoza desc

--9. Iz tabela Narudzba, Dobavljac i Proizvod kreirati pogled koji će sadržavati ID narudžbe, dan iz datuma prijema,
-- raspoloživost, naziv grada iz pune adrese naručitelja i državu dobavljača. Uslov je da je datum prijema u 2. ili 3.
-- dekadi mjeseca i da grad naručitelja Bergamo.
--________________________________________________________________________________________________

CREATE VIEW pogled_prvi
AS
SELECT N.NarudzbaID,DAY(N.DatumPrijema) AS DanPrijema,P.Raspolozivost,RIGHT(N.PunaAdresa,7) AS Grad
FROM Proizvod AS P INNER JOIN Dobavljac AS D ON P.DobavljacID=D.DobavljacID INNER JOIN Narudzba AS N ON N.NarudzbaID=P.NarudzbaID
WHERE DATEPART(DAY,N.DatumPrijema)>=10 AND RIGHT(N.PunaAdresa,7)='Bergamo'
--10. Iz tabela Proizvod i Dobavljac kreirati proceduru proc1 koja će sadržavati ID i 
--naziv dobavljača i ukupan broj proizvoda
--koji je realizirao dobavljač.
-- Pokrenuti proceduru za vrijednost ukupno realiziranog broja proizvoda 22 i 14.
--________________________________________________________________________________________________
ALTER PROCEDURE proc1
(
@UkupanBrojRealiziranihproiz int
)
AS
BEGIN
SELECT D.DobavljacID,D.NazivDobavljaca,COUNT(P.ProizvodID) AS UkupnoProizvoda
FROM Dobavljac AS D INNER JOIN Proizvod AS P ON D.DobavljacID=P.DobavljacID
GROUP BY D.DobavljacID,D.NazivDobavljaca
HAVING COUNT(P.ProizvodID)=@UkupanBrojRealiziranihproiz
END

EXEC proc1 29
--SQL skriptu (bila prazna ili ne) imenovati Vašim brojem dosijea, te istu upload-ovati na FTP u folder Upload.
 
--Podaci za FTP:  
--username: student_fd 
--password: student_fd 



