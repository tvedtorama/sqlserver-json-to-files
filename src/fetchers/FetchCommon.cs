using System.Collections.Generic;
using System.Data.SqlClient;

namespace JsonReader.Fetchers
{

	static public class FetchCommon 
	{
		public static IEnumerable<Job> ProduceCommon(System.Func<string, string> loadFile, string fileName, string outputFileName) {
			var fetchCustomers = loadFile(fileName);

			System.Func<IList<SqlParameter>> paramList = () => new List<SqlParameter> {};
			yield return new Job {Query = fetchCustomers, FilePath = outputFileName, Params = paramList()};
		}
	}
}
