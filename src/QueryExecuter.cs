
using System.Data.SqlClient;
using System.Text;

namespace JsonReader
{
	static class QueryExecuter
	{
		public static SqlConnection OpenConnection(string connectionString)
		{
			var conn = new SqlConnection(connectionString);
			conn.Open();
            return conn;
		}

		public static string Execute(System.Func<string, SqlCommand> commandCreator, string queryWithForJson)
		{
			var cmd = commandCreator(queryWithForJson);
			var jsonResult = new StringBuilder();
			var reader = cmd.ExecuteReader();
			if (!reader.HasRows)
			{
				jsonResult.Append("[]");
			}
			else
			{
				while (reader.Read())
				{
					jsonResult.Append(reader.GetValue(0).ToString());
				}
			}
            return jsonResult.ToString();
		}
    }
}
