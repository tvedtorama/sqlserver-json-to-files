using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Extensions.Configuration;

namespace JsonReader
{

    static class Source {
        public static IEnumerable<Job> getItems() {
            yield return new Job {FilePath = "hei4.json", Query = "select * from KundeEnhetTjeneste where IDKundeEnhet=4012 FOR JSON AUTO"};
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(System.IO.Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);

            var configuration = builder.Build();

            var fetcherConfig = configuration.GetSection("eventFetcher").Get<Fetchers.FetchEvents.FetchEventsConfig>();
            var connectionString = configuration.GetConnectionString("Main");

            var conn = QueryExecuter.OpenConnection(connectionString);
            var queries = new List<IEnumerable<Job>>{
                    Source.getItems(),
                    Fetchers.FetchEvents.ProduceEvents(fetcherConfig, f => System.IO.File.ReadAllText(f), DateTime.Now.Date)
                }.SelectMany(x => x);

            foreach (var x in queries.
					AsParallel().
					WithMergeOptions(ParallelMergeOptions.NotBuffered).
					WithExecutionMode(ParallelExecutionMode.ForceParallelism).
					WithDegreeOfParallelism(2).Select(x => {
						System.Console.WriteLine("Executing: " + x.FilePath);
                        return new {Job = x, Result = QueryExecuter.Execute((cmd) => new System.Data.SqlClient.SqlCommand(cmd, conn), x.Query, x.Params)};
                    })) {
				System.Console.WriteLine("Done with this: " + x.Job.FilePath + "  " + x.Result.Substring(0, System.Math.Min(x.Result.Length, 60)));
				System.IO.File.WriteAllText(System.IO.Path.Combine("data", x.Job.FilePath), x.Result);
            }

            Console.WriteLine("Hello World!");
        }
    }
}
