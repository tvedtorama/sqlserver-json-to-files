using System.Collections.Generic;
using System.Data.SqlClient;

namespace JsonReader.Fetchers
{

	static public class FetchOperators 
	{
		public static IEnumerable<Job> ProduceOperators(System.Func<string, string> loadFile) {
			return FetchCommon.ProduceCommon(loadFile, "FetchOperators.sql", "Operators.json");
		}
	}
}
