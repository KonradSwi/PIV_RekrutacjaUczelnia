using System.Data;

namespace PIVRekrutacjaUczelnia;

public partial class ListaKandydatowPage : ContentPage
{
    public ListaKandydatowPage()
    {
        InitializeComponent();
        LoadData();
    }

    private void LoadData()
    {
        string query = @"
SELECT 
    k.Imie, 
    k.Nazwisko, 
    ks.Nazwa_kierunku, 
    ks.Rodzaj_studiow, 
    wr.Suma_punktow, 
    wr.Status_przyjecia
FROM Kandydat k
JOIN Podanie p ON k.ID_kandydata = p.ID_kandydata
JOIN Kierunek_studiow ks ON p.ID_kierunku = ks.ID_kierunku
LEFT JOIN Wynik_rekrutacyjny wr ON p.ID_podania = wr.ID_podania
ORDER BY 
    CASE WHEN wr.Suma_punktow IS NULL THEN 1 ELSE 0 END,
    wr.Suma_punktow DESC";

        var dt = DatabaseHelper.ExecuteSelect(query);
        kandydaciView.ItemsSource = dt.Rows.Cast<DataRow>().Select(row => new
        {
            Imie = row["Imie"].ToString(),
            Nazwisko = row["Nazwisko"].ToString(),
            Kierunek = row["Nazwa_kierunku"].ToString(),
            Rodzaj = row["Rodzaj_studiow"].ToString(),
            Suma_punktow = row["Suma_punktow"] == DBNull.Value ? "Brak" : row["Suma_punktow"].ToString(),
            Status_przyjecia = row["Status_przyjecia"] == DBNull.Value ? "Brak" : row["Status_przyjecia"].ToString()
        }).ToList();
    }
}