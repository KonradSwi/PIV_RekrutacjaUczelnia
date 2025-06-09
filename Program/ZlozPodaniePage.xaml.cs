namespace PIVRekrutacjaUczelnia;

public partial class ZlozPodaniePage : ContentPage
{
    private List<Kierunek> kierunki = new();
    private List<PrzedmiotMaturalnyModel> przedmioty = new();


    public ZlozPodaniePage()
    {
        InitializeComponent();
        LoadKierunki();
    }

    private void LoadKierunki()
    {
        try
        {
            kierunki = DatabaseHelper.GetKierunki();
            kierunekPicker.ItemsSource = kierunki;
            kierunekPicker.ItemDisplayBinding = new Binding("FullName");
        }
        catch (Exception ex)
        {
            DisplayAlert("B³¹d", $"Nie uda³o siê za³adowaæ kierunków: {ex.Message}", "OK");
        }
    }

    private void OnDodajPrzedmiotClicked(object sender, EventArgs e)
    {
        if (przedmiotPicker.SelectedItem == null || poziomPicker.SelectedItem == null || string.IsNullOrWhiteSpace(wynikEntry.Text))
        {
            DisplayAlert("B³¹d", "WprowadŸ wszystkie dane przedmiotu.", "OK");
            return;
        }

        if (!int.TryParse(wynikEntry.Text, out int wynik) || wynik < 0 || wynik > 100)
        {
            DisplayAlert("B³¹d", "Wynik musi byæ liczb¹ od 0 do 100.", "OK");
            return;
        }

        var nowy = new PrzedmiotMaturalnyModel
        {
            Przedmiot = przedmiotPicker.SelectedItem.ToString(),
            Poziom = poziomPicker.SelectedItem.ToString(),
            Wynik = wynik
        };

        przedmioty.Add(nowy);
        przedmiotyList.ItemsSource = null;
        przedmiotyList.ItemsSource = przedmioty;

        // Czyœæ pola
        przedmiotPicker.SelectedIndex = -1;
        poziomPicker.SelectedIndex = -1;
        wynikEntry.Text = string.Empty;
    }

    private async void OnZlozClicked(object sender, EventArgs e)
    {
        if (kierunekPicker.SelectedItem is not Kierunek selectedKierunek)
        {
            await DisplayAlert("B³¹d", "Wybierz kierunek studiów.", "OK");
            return;
        }

        try
        {
            // Dodaj kandydata i pobierz ID
            string insertKandydat = @"
                INSERT INTO Kandydat (Imie, Nazwisko, PESEL, Data_urodzenia, Email, Telefon, ID_adresu, ID_szkoly)
                VALUES (@Imie, @Nazwisko, @PESEL, @DataUrodzenia, @Email, @Telefon, 1, 1);
                SELECT SCOPE_IDENTITY();";


            var kandydatParams = new Dictionary<string, object>
            {
                { "@Imie", imieEntry.Text },
                { "@Nazwisko", nazwiskoEntry.Text },
                { "@PESEL", peselEntry.Text },
                { "@DataUrodzenia", dataUrodzeniaPicker.Date },
                { "@Email", emailEntry.Text },
                { "@Telefon", telefonEntry.Text }
            };

            int idKandydata = DatabaseHelper.ExecuteInsertWithOutput(insertKandydat, kandydatParams);

            // Dodaj podanie i pobierz jego ID
            string insertPodanie = @"
    INSERT INTO Podanie (Data_zlozenia, Priorytet, Status_podania, ID_kandydata, ID_kierunku)
    VALUES (@Data, 1, 'oczekuj¹ce', @IDKandydata, @IDKierunku);
    SELECT SCOPE_IDENTITY();";

            var podanieParams = new Dictionary<string, object>
{
    { "@Data", DateTime.Now },
    { "@IDKandydata", idKandydata },
    { "@IDKierunku", selectedKierunek.ID_kierunku }
};

            int idPodania = DatabaseHelper.ExecuteInsertWithOutput(insertPodanie, podanieParams);

            foreach (var przedmiot in przedmioty)
            {
                string insertPrzedmiot = @"
        INSERT INTO Przedmiot_maturalny (Przedmiot, Poziom, Wynik, ID_podania)
        VALUES (@Przedmiot, @Poziom, @Wynik, @IDPodania);";

                var przedmiotParams = new Dictionary<string, object>
    {
        { "@Przedmiot", przedmiot.Przedmiot },
        { "@Poziom", przedmiot.Poziom },
        { "@Wynik", przedmiot.Wynik },
        { "@IDPodania", idPodania }
    };

                DatabaseHelper.ExecuteNonQuery(insertPrzedmiot, przedmiotParams);
            }

            await DisplayAlert("Sukces", "Podanie zosta³o z³o¿one!", "OK");
        }
        catch (Exception ex)
        {
            await DisplayAlert("B³¹d", ex.Message, "OK");
        }
    }
}

public class Kierunek
{
    public int ID_kierunku { get; set; }
    public string Nazwa_kierunku { get; set; }
    public string Rodzaj_studiow { get; set; }

    public string FullName => $"{Nazwa_kierunku} ({Rodzaj_studiow})";
}

public class PrzedmiotMaturalnyModel
{
    public string Przedmiot { get; set; }
    public string Poziom { get; set; }
    public int Wynik { get; set; }

    public string Display => $"{Przedmiot} ({Poziom}) - {Wynik}%";
}
