using System.Data.SqlClient;
using System.Data;

namespace PIVRekrutacjaUczelnia;

public static class DatabaseHelper
{
    private static string connectionString = "Server=KONRAD;Database=RekrutacjaUczelnia;Trusted_Connection=True;";

    public static DataTable ExecuteSelect(string query)
    {
        using SqlConnection conn = new(connectionString);
        using SqlCommand cmd = new(query, conn);
        conn.Open();
        using SqlDataAdapter adapter = new(cmd);
        DataTable dt = new();
        adapter.Fill(dt);
        return dt;
    }

    public static int ExecuteNonQuery(string query, Dictionary<string, object> parameters)
    {
        using SqlConnection conn = new(connectionString);
        using SqlCommand cmd = new(query, conn);
        foreach (var param in parameters)
            cmd.Parameters.AddWithValue(param.Key, param.Value);

        conn.Open();
        return cmd.ExecuteNonQuery();
    }

    public static List<Kierunek> GetKierunki()
    {
        List<Kierunek> kierunki = new();
        string query = "SELECT ID_kierunku, Nazwa_kierunku, Rodzaj_studiow FROM Kierunek_studiow";

        using SqlConnection conn = new(connectionString);
        using SqlCommand cmd = new(query, conn);
        conn.Open();
        using SqlDataReader reader = cmd.ExecuteReader();
        while (reader.Read())
        {
            kierunki.Add(new Kierunek
            {
                ID_kierunku = reader.GetInt32(0),
                Nazwa_kierunku = reader.GetString(1),
                Rodzaj_studiow = reader.GetString(2)
            });
        }
        return kierunki;
    }

    public static int ExecuteInsertWithOutput(string query, Dictionary<string, object> parameters)
    {
        using SqlConnection conn = new(connectionString);
        using SqlCommand cmd = new(query, conn);

        foreach (var param in parameters)
            cmd.Parameters.AddWithValue(param.Key, param.Value);

        conn.Open();
        object result = cmd.ExecuteScalar();
        return Convert.ToInt32(result);
    }
}
