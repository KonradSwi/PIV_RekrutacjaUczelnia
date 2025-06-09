IF NOT EXISTS (
    SELECT name 
    FROM sys.databases 
    WHERE name = N'RekrutacjaUczelnia'
)
BEGIN
    CREATE DATABASE RekrutacjaUczelnia;
END;
GO

USE RekrutacjaUczelnia;
GO

-- Tabela: Wydzial
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'Wydzial'
)
BEGIN
    CREATE TABLE Wydzial (
        ID_wydzialu INT IDENTITY(1,1) PRIMARY KEY,
        Nazwa_wydzialu NVARCHAR(100) NOT NULL
    );
END;
GO

-- Tabela: Kierunek_studiow
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'Kierunek_studiow'
)
BEGIN
    CREATE TABLE Kierunek_studiow (
        ID_kierunku INT IDENTITY(1,1) PRIMARY KEY,
        Nazwa_kierunku NVARCHAR(100) NOT NULL,
        Prog_punktowy DECIMAL(5,2),
        Rodzaj_studiow NVARCHAR(50) NOT NULL,
        Liczba_miejsc INT NOT NULL,
        Algorytm_przeliczania NVARCHAR(255) NOT NULL,
        ID_wydzialu INT NOT NULL,
        FOREIGN KEY (ID_wydzialu) REFERENCES Wydzial(ID_wydzialu)
    );
END;
GO

-- Tabela: Szkola
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'Szkola'
)
BEGIN
    CREATE TABLE Szkola (
        ID_szkoly INT IDENTITY(1,1) PRIMARY KEY,
        Nazwa_szkoly NVARCHAR(150) NOT NULL,
        Typ_szkoly NVARCHAR(50)
    );
END;
GO

-- Tabela: Adres
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'Adres'
)
BEGIN
    CREATE TABLE Adres (
        ID_adresu INT IDENTITY(1,1) PRIMARY KEY,
        Ulica NVARCHAR(255) NOT NULL,
        Nr_domu NVARCHAR(10) NOT NULL,
		Nr_lokalu NVARCHAR(10),
		Miasto NVARCHAR(100) NOT NULL,
		Kod_pocztowy VARCHAR(10) NOT NULL
    );
END;
GO

-- Tabela: Kandydat
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'Kandydat'
)
BEGIN
    CREATE TABLE Kandydat (
        ID_kandydata INT IDENTITY(1,1) PRIMARY KEY,
        Imie NVARCHAR(50) NOT NULL,
        Nazwisko NVARCHAR(50) NOT NULL,
        PESEL CHAR(11) NOT NULL UNIQUE,
        Data_urodzenia DATE NOT NULL,
        Telefon VARCHAR(15),
        Email NVARCHAR(100),
		ID_adresu INT NOT NULL,
        ID_szkoly INT NOT NULL,
        FOREIGN KEY (ID_adresu) REFERENCES Adres(ID_adresu),
		FOREIGN KEY (ID_szkoly) REFERENCES Szkola(ID_szkoly)
    );
END;
GO

-- Tabela: Podanie
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'Podanie'
)
BEGIN
    CREATE TABLE Podanie (
        ID_podania INT IDENTITY(1,1) PRIMARY KEY,
        Data_zlozenia DATE NOT NULL,
        Priorytet INT NOT NULL,
        Status_podania NVARCHAR(50),
        ID_kandydata INT NOT NULL,
        ID_kierunku INT NOT NULL,
        FOREIGN KEY (ID_kandydata) REFERENCES Kandydat(ID_kandydata),
        FOREIGN KEY (ID_kierunku) REFERENCES Kierunek_studiow(ID_kierunku)
    );
END;
GO

-- Tabela: Przedmiot_maturalny
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'Przedmiot_maturalny'
)
BEGIN
    CREATE TABLE Przedmiot_maturalny (
        ID_przedmiotu INT IDENTITY(1,1) PRIMARY KEY,
        Przedmiot NVARCHAR(100) NOT NULL,
        Poziom NVARCHAR(20) NOT NULL,
        Wynik DECIMAL(5,2) NOT NULL,
        ID_podania INT NOT NULL,
        FOREIGN KEY (ID_podania) REFERENCES Podanie(ID_podania)
    );
END;
GO

-- Tabela: Wynik_rekrutacyjny
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'Wynik_rekrutacyjny'
)
BEGIN
    CREATE TABLE Wynik_rekrutacyjny (
        ID_wyniku INT IDENTITY(1,1) PRIMARY KEY,
        Suma_punktow DECIMAL(6,2) NOT NULL,
        Status_przyjecia NVARCHAR(50),
        ID_podania INT NOT NULL UNIQUE,
        FOREIGN KEY (ID_podania) REFERENCES Podanie(ID_podania)
    );
END;
GO