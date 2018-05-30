
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using Microsoft.Extensions.Configuration;

namespace JsonReader.Fetchers
{

	static public class FetchEvents 
	{
		class Interval {
			public System.DateTime startTime;
			public System.DateTime endTime;
		}

		public static IEnumerable<Job> ProduceEvents(IConfigurationRoot root, System.Func<string, string> loadFile) {
			var fetchUsageEvents = loadFile("FetchUsageEvents.sql");

			var dates = new List<System.DateTime> {new System.DateTime(2018, 01, 15), new System.DateTime(2018, 01, 17), new System.DateTime(2018, 01, 19)};
			
			var intervals = dates.Aggregate(new List<Interval>(), (x, y) => {
					if (x.Count > 0)
						x.Last().endTime = y;
					x.Add(new Interval {startTime = y});
					return x;
				}).SkipLast(1);
			
			foreach (var interval in intervals) {
				yield return new Job {Query = fetchUsageEvents, FilePath = $"UsageEvents_{interval.startTime.ToString("yyyy-MM-dd")}.json", Params = new List<SqlParameter> {
						new SqlParameter("@startDate", System.Data.SqlDbType.Date) {Value = interval.startTime},
						new SqlParameter("@endDate", System.Data.SqlDbType.Date) {Value = interval.endTime}
					}};
			}
		}
	}
}