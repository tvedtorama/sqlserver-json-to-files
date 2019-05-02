
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

		public class FetchEventsConfig {
			public System.DateTime eventStartDate {get; set;}
			public int eventIntervalHours {get; set;}
		}

		public static IEnumerable<Job> ProduceEvents(FetchEventsConfig config, System.Func<string, string> loadFile, System.DateTime endDateInput) {
			var fetchUsageEvents = loadFile("FetchUsageEvents.sql");
			var fetchEmptyingEvents = loadFile("FetchEmptyingEvents.sql");

			var (startDate, intervalHours) = (config.eventStartDate.Date, config.eventIntervalHours);

			var intervalCount = (int)System.Math.Ceiling((endDateInput - startDate).TotalHours / (double)intervalHours);

			var dates = System.Linq.Enumerable.Range(0, intervalCount).Select(i => startDate + System.TimeSpan.FromHours(i * intervalHours)); // new List<System.DateTime> {new System.DateTime(2018, 01, 15), new System.DateTime(2018, 01, 17), new System.DateTime(2018, 01, 19)};
			
			var intervals = dates.Aggregate(new List<Interval>(), (x, y) => {
					if (x.Count > 0)
						x.Last().endTime = y;
					x.Add(new Interval {startTime = y});
					return x;
				}).SkipLast(1);
			
			foreach (var interval in intervals) {
				System.Func<IList<SqlParameter>> paramList = () => new List<SqlParameter> {
						new SqlParameter("@startDate", System.Data.SqlDbType.DateTime) {Value = interval.startTime},
						new SqlParameter("@endDate", System.Data.SqlDbType.DateTime) {Value = interval.endTime}
					};
				var filenamePostfix = interval.startTime.ToString("yyyy-MM-dd");
				yield return new Job {Query = fetchUsageEvents, FilePath = $"UsageEvents_{filenamePostfix}.json", Params = paramList()};
				yield return new Job {Query = fetchEmptyingEvents, FilePath = $"EmptyingEvents_{filenamePostfix}.json", Params = paramList()};
			}
		}
	}
}