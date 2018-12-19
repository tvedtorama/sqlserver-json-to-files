using System.Collections.Generic;
using System.Data.SqlClient;

namespace JsonReader.Fetchers
{

	static public class FetchPoints 
	{
		public static IEnumerable<Job> ProducePoints(System.Func<string, string> loadFile) {
			return FetchCommon.ProduceCommon(loadFile, "FetchPoints.sql", "Points.json");
		}
	}
}
