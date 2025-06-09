INSERT INTO Wydzial (Nazwa_wydzialu)
VALUES 
    (N'Wydzia³ Informatyki'),
    (N'Wydzia³ Matematyki'),
    (N'Wydzia³ Ekonomiczny');

INSERT INTO Kierunek_studiow (Nazwa_kierunku, Prog_punktowy, Rodzaj_studiow, Liczba_miejsc, Algorytm_przeliczania, ID_wydzialu)
VALUES 
    (N'Informatyka', 80.00, N'stacjonarne', 100, N'standard', 1),
    (N'Matematyka stosowana', 75.00, N'stacjonarne', 60, N'mat70_reszta30', 2),
    (N'Finanse i rachunkowoœæ', 70.00, N'niestacjonarne', 40, N'ang50_mat30_reszta20', 3);

INSERT INTO Szkola (Nazwa_szkoly, Typ_szkoly)
VALUES 
    (N'I Liceum Ogólnokszta³c¹ce im. Miko³aja Kopernika', N'Liceum'),
    (N'Technikum Elektroniczne nr 1', N'Technikum'),
	(N'Zespó³ Szkó³ im. Marii Sk³odowskiej-Curie w Gdañsku', N'Liceum');

INSERT INTO Adres (Ulica, Nr_domu, Nr_lokalu, Miasto, Kod_pocztowy)
VALUES 
    (N'Polna', '12', '3A', N'Warszawa', '00-123'),
    (N'Lipowa', '8', NULL, N'Kraków', '31-456'),
    (N'Dêbowa', '45B', '5', N'Poznañ', '60-789');

INSERT INTO Kandydat (Imie, Nazwisko, PESEL, Data_urodzenia, Telefon, Email, ID_adresu, ID_szkoly)
VALUES 
    (N'Jan', N'Kowalski', '01234567890', '2005-03-12', '501123456', 'jan.kowalski@example.com', 1, 1),
    (N'Anna', N'Nowak', '98765432109', '2004-07-20', '502987654', 'anna.nowak@example.com', 2, 2),
    (N'Piotr', N'Wiœniewski', '11223344556', '2005-12-05', '503112233', 'piotr.wisniewski@example.com', 3, 3);

INSERT INTO Podanie (Data_zlozenia, Priorytet, Status_podania, ID_kandydata, ID_kierunku)
VALUES 
    ('2025-05-01', 1, N'oczekuj¹ce', 1, 1),
    ('2025-05-02', 2, N'oczekuj¹ce', 1, 2),
    ('2025-05-03', 1, N'oczekuj¹ce', 2, 2),
    ('2025-05-04', 1, N'oczekuj¹ce', 3, 3);

-- Dla podania 1
INSERT INTO Przedmiot_maturalny (Przedmiot, Poziom, Wynik, ID_podania)
VALUES 
    (N'Matematyka', N'podstawowy', 95.00, 1),
	(N'Matematyka', N'rozszerzony', 85.00, 1),
	(N'Fizyka', N'rozszerzony', 75.00, 1),
    (N'Informatyka', N'rozszerzony', 90.00, 1);

-- Dla podania 2
INSERT INTO Przedmiot_maturalny (Przedmiot, Poziom, Wynik, ID_podania)
VALUES 
	(N'Matematyka', N'podstawowy', 95.00, 2),
    (N'Matematyka', N'rozszerzony', 85.00, 2),
    (N'Fizyka', N'rozszerzony', 75.00, 2);

-- Dla podania 3
INSERT INTO Przedmiot_maturalny (Przedmiot, Poziom, Wynik, ID_podania)
VALUES 
    (N'Matematyka', N'rozszerzony', 78.50, 3),
    (N'Fizyka', N'rozszerzony', 80.00, 3);

-- Dla podania 4
INSERT INTO Przedmiot_maturalny (Przedmiot, Poziom, Wynik, ID_podania)
VALUES 
    (N'Matematyka', N'rozszerzony', 88.00, 4),
    (N'Angielski', N'rozszerzony', 82.00, 4);
