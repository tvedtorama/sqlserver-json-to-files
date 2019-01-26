using System.Collections.Generic;
using System.Data.SqlClient;

namespace JsonReader.Fetchers
{

	static public class FetchIdentities 
	{
		public static IEnumerable<Job> ProduceIdentities(System.Func<string, string> loadFile) {
			return FetchCommon.ProduceCommon(loadFile, "FetchIdentities.sql", "IdentityData.json");
		}
	}
}
