using System.Collections.Generic;
using System.Data.SqlClient;

namespace JsonReader.Fetchers
{

	static public class FetchIdentities 
	{
		public static IEnumerable<Job> ProduceIdentities(System.Func<string, string> loadFile) {
			var fetchCustomers = loadFile("FetchIdentities.sql");

			System.Func<IList<SqlParameter>> paramList = () => new List<SqlParameter> {};
			yield return new Job {Query = fetchCustomers, FilePath = $"Identities.json", Params = paramList()};
		}
	}
}
