using System.Collections.Generic;
using System.Data.SqlClient;

namespace JsonReader.Fetchers
{

	static public class FetchContainers
	{
		public static IEnumerable<Job> ProduceContainers(System.Func<string, string> loadFile) {
			return FetchCommon.ProduceCommon(loadFile, "FetchContainers.sql", "Containers.json");
		}
	}
}
