using System.Collections.Generic;
using System.Data.SqlClient;

namespace JsonReader.Fetchers
{

	static public class FetchCustomers 
	{
		public static IEnumerable<Job> ProduceCustomers(System.Func<string, string> loadFile) {
			return FetchCommon.ProduceCommon(loadFile, "FetchCustomers.sql", "Customers.json");
		}
	}
}
