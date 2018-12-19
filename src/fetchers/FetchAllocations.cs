using System.Collections.Generic;
using System.Data.SqlClient;

namespace JsonReader.Fetchers
{

	static public class FetchAllocations
	{
		public static IEnumerable<Job> ProduceAllocations(System.Func<string, string> loadFile) {
			return FetchCommon.ProduceCommon(loadFile, "FetchAllocations.sql", "AllocationData.json");
		}
	}
}
