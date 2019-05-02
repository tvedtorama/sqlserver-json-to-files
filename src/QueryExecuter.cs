
using System.Collections.Generic;
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

		public static string Execute(System.Func<string, SqlCommand> commandCreator, string queryWithForJson, IList<SqlParameter> sqlParams)
		{
			var cmd = commandCreator(queryWithForJson);
            foreach (var p in sqlParams)
                cmd.Parameters.Add(p);
			var jsonResult = new StringBuilder();
			var reader = cmd.ExecuteReader();
 			try {
				while (reader.Read())
				{
					jsonResult.Append(reader.GetValue(0).ToString());
				}
			} catch (System.Data.SqlClient.SqlException err) {
				System.Diagnostics.Trace.TraceError(err.Message);
				jsonResult.Append("[]"); 
			}
            return jsonResult.ToString();
		}
    }
}
