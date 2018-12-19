using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Extensions.Configuration;

namespace JsonReader
{
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
            System.Func<string, string> readFile = f => System.IO.File.ReadAllText(f);
            var queries = new List<IEnumerable<Job>>{
                    Fetchers.FetchIdentities.ProduceIdentities(readFile),
                    Fetchers.FetchCustomers.ProduceCustomers(readFile),
                    // Fetchers.FetchContainers.ProduceContainers(readFile),
                    Fetchers.FetchPoints.ProducePoints(readFile),
                    Fetchers.FetchAllocations.ProduceAllocations(readFile),
                    Fetchers.FetchEvents.ProduceEvents(fetcherConfig, readFile, DateTime.Now.Date),
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
