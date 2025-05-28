USE RekrutacjaUczelnia
GO

CREATE TRIGGER trg_Kandydat_Validate
ON Kandydat
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE LEN(PESEL) <> 11 OR PESEL LIKE '%[^0-9]%'
    )
    BEGIN
        RAISERROR ('PESEL musi sk³adaæ siê z dok³adnie 11 cyfr.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE DATEDIFF(year, Data_urodzenia, GETDATE()) < 18
    )
    BEGIN
        RAISERROR ('Kandydat musi mieæ co najmniej 18 lat.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

CREATE TRIGGER trg_Podanie_Validate
ON Podanie
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM inserted WHERE Priorytet <= 0
    )
    BEGIN
        RAISERROR ('Priorytet musi byæ liczb¹ dodatni¹.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF EXISTS (
        SELECT i.ID_kandydata, i.Priorytet
        FROM inserted i
        JOIN Podanie p ON p.ID_kandydata = i.ID_kandydata AND p.Priorytet = i.Priorytet AND p.ID_podania <> i.ID_podania
    )
    BEGIN
        RAISERROR ('Dla jednego kandydata priorytet podañ musi byæ unikalny.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

CREATE TRIGGER trg_Przedmiot_maturalny_Validate
ON Przedmiot_maturalny
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM inserted WHERE Wynik < 0 OR Wynik > 100
    )
    BEGIN
        RAISERROR ('Wynik z przedmiotu maturalnego musi byæ w zakresie od 0 do 100.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

CREATE TRIGGER trg_Podanie_DataZlozenia
ON Podanie
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE Data_zlozenia > CAST(GETDATE() AS DATE)
    )
    BEGIN
        RAISERROR ('Data zlozenia podania nie moze byc z przyszlosci.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

CREATE TRIGGER trg_NormalizePoziom
ON Przedmiot_maturalny
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE LOWER(Poziom) NOT IN ('podstawowy', 'rozszerzony')
    )
    BEGIN
        RAISERROR ('Niepoprawna wartosc w polu Poziom. Dozwolone: podstawowy, rozszerzony.', 16, 1);
        RETURN;
    END

    MERGE Przedmiot_maturalny AS target
    USING inserted AS source
    ON target.ID_przedmiotu = source.ID_przedmiotu

    WHEN MATCHED THEN
        UPDATE SET
            Przedmiot = source.Przedmiot,
            Poziom = LOWER(source.Poziom),
            Wynik = source.Wynik,
            ID_podania = source.ID_podania

    WHEN NOT MATCHED THEN
        INSERT (Przedmiot, Poziom, Wynik, ID_podania)
        VALUES (source.Przedmiot, LOWER(source.Poziom), source.Wynik, source.ID_podania);
END;
GO

CREATE TRIGGER trg_ValidateKodPocztowy
ON Adres
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE Kod_pocztowy NOT LIKE '[0-9][0-9]-[0-9][0-9][0-9]'
    )
    BEGIN
        RAISERROR ('Niepoprawny format kodu pocztowego. Wymagany format: XX-XXX (np. 30-053).', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

/*
CREATE OR ALTER PROCEDURE ObliczWynikRekrutacyjny
    @ID_podania INT
AS
BEGIN

    DECLARE 
        @ID_kierunku INT,
        @algorytm NVARCHAR(255),
        @suma DECIMAL(6,2) = 0,
        @mat DECIMAL(5,2) = 0,
        @ang DECIMAL(5,2) = 0,
        @reszta DECIMAL(5,2) = 0;

    SELECT @ID_kierunku = ID_kierunku
    FROM Podanie
    WHERE ID_podania = @ID_podania;

    SELECT @algorytm = Algorytm_przeliczania
    FROM Kierunek_studiow
    WHERE ID_kierunku = @ID_kierunku;

    IF @algorytm = 'standard'
    BEGIN
        SELECT @suma = ISNULL(SUM(Wynik), 0)
        FROM Przedmiot_maturalny
        WHERE ID_podania = @ID_podania;
    END
    ELSE IF @algorytm = 'mat70_reszta30'
    BEGIN
        SELECT 
            @mat = ISNULL(SUM(Wynik), 0)
        FROM Przedmiot_maturalny
        WHERE ID_podania = @ID_podania AND Przedmiot = 'Matematyka';

        SELECT 
            @reszta = ISNULL(SUM(Wynik), 0)
        FROM Przedmiot_maturalny
        WHERE ID_podania = @ID_podania AND Przedmiot <> 'Matematyka';

        SET @suma = (@mat * 0.7) + (@reszta * 0.3);
    END
    ELSE IF @algorytm = 'ang50_mat30_reszta20'
    BEGIN
        SELECT @ang = ISNULL(SUM(Wynik), 0)
        FROM Przedmiot_maturalny
        WHERE ID_podania = @ID_podania AND Przedmiot = 'Angielski';

        SELECT @mat = ISNULL(SUM(Wynik), 0)
        FROM Przedmiot_maturalny
        WHERE ID_podania = @ID_podania AND Przedmiot = 'Matematyka';

        SELECT @reszta = ISNULL(SUM(Wynik), 0)
        FROM Przedmiot_maturalny
        WHERE ID_podania = @ID_podania AND Przedmiot NOT IN ('Angielski', 'Matematyka');

        SET @suma = (@ang * 0.5) + (@mat * 0.3) + (@reszta * 0.2);
    END
    ELSE
    BEGIN
        RAISERROR('Nieobs³ugiwany algorytm przeliczania.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Wynik_rekrutacyjny WHERE ID_podania = @ID_podania)
    BEGIN
        UPDATE Wynik_rekrutacyjny
        SET Suma_punktow = @suma
        WHERE ID_podania = @ID_podania;
    END
    ELSE
    BEGIN
        INSERT INTO Wynik_rekrutacyjny (Suma_punktow, Status_przyjecia, ID_podania)
        VALUES (@suma, NULL, @ID_podania);
    END
END;

CREATE OR ALTER PROCEDURE AktualizujStatusPrzyjecia
    @ID_kierunku INT
AS
BEGIN
    DECLARE @Liczba_miejsc INT, @Prog DECIMAL(5,2);

    SELECT 
        @Liczba_miejsc = Liczba_miejsc,
        @Prog = Prog_punktowy
    FROM Kierunek_studiow
    WHERE ID_kierunku = @ID_kierunku;

    ;WITH Ranking AS (
        SELECT 
            wr.ID_wyniku,
            wr.Suma_punktow,
            RANK() OVER (ORDER BY wr.Suma_punktow DESC) AS Pozycja
        FROM Wynik_rekrutacyjny wr
        JOIN Podanie p ON p.ID_podania = wr.ID_podania
        WHERE p.ID_kierunku = @ID_kierunku
    )

    UPDATE wr
    SET Status_przyjecia = 'Przyjêty'
    FROM Wynik_rekrutacyjny wr
    JOIN Ranking r ON r.ID_wyniku = wr.ID_wyniku
    WHERE r.Pozycja <= @Liczba_miejsc
      AND (
          @Prog IS NULL OR r.Suma_punktow >= @Prog
      );

    UPDATE wr
    SET Status_przyjecia = 'Odrzucony'
    FROM Wynik_rekrutacyjny wr
    JOIN Podanie p ON p.ID_podania = wr.ID_podania
    WHERE p.ID_kierunku = @ID_kierunku
      AND Status_przyjecia IS NULL;
END;
*/
