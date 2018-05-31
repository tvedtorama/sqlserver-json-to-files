using System.Collections.Generic;
using System.Data.SqlClient;

namespace JsonReader.Fetchers
{

	static public class FetchCustomers 
	{
		public static IEnumerable<Job> ProduceCustomers(System.Func<string, string> loadFile) {
			var fetchCustomers = loadFile("FetchCustomers.sql");

			System.Func<IList<SqlParameter>> paramList = () => new List<SqlParameter> {};
			yield return new Job {Query = fetchCustomers, FilePath = $"Customers.json", Params = paramList()};
		}
	}
}
