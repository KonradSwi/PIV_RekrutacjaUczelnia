using System.Data;

namespace PIVRekrutacjaUczelnia;

public partial class MainPage : ContentPage
{
    public MainPage()
    {
        InitializeComponent();
    }

    private async void OnZlozPodanieClicked(object sender, EventArgs e)
    {
        await Navigation.PushAsync(new ZlozPodaniePage());
    }

    private async void OnZobaczKandydatowClicked(object sender, EventArgs e)
    {
        await Navigation.PushAsync(new ListaKandydatowPage());
    }

    private async void OnObliczWynikiClicked(object sender, EventArgs e)
    {
        try
        {
            string sqlPodaniaAll = "SELECT ID_podania FROM Podanie";
            var podaniaAllDt = DatabaseHelper.ExecuteSelect(sqlPodaniaAll);

            foreach (DataRow podanieRow in podaniaAllDt.Rows)
            {
                int idPodania = Convert.ToInt32(podanieRow["ID_podania"]);

                string sqlWynik = "EXEC ObliczWynikRekrutacyjny @ID_podania";
                var paramWynik = new Dictionary<string, object>
                {
                    { "@ID_podania", idPodania }
                };

                DatabaseHelper.ExecuteNonQuery(sqlWynik, paramWynik);
            }

            string sqlKierunki = "SELECT ID_kierunku FROM Kierunek_studiow";
            var dtKierunki = DatabaseHelper.ExecuteSelect(sqlKierunki);

            foreach (DataRow kierunekRow in dtKierunki.Rows)
            {
                int idKierunku = Convert.ToInt32(kierunekRow["ID_kierunku"]);

                string sqlStatus = "EXEC AktualizujStatusPrzyjecia @ID_kierunku";
                var paramStatus = new Dictionary<string, object>
                {
                    { "@ID_kierunku", idKierunku }
                };

                DatabaseHelper.ExecuteNonQuery(sqlStatus, paramStatus);
            }

            await DisplayAlert("Sukces", "Wyniki i statusy zostały zaktualizowane.", "OK");
        }
        catch (Exception ex)
        {
            await DisplayAlert("Błąd", $"Coś poszło nie tak: {ex.Message}", "OK");
        }
    }

}