using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Extensions.Configuration;

namespace JsonReader
{
    public class Job {
        public string Query;
        public string FilePath;
    }

    static class Source {
        public static IEnumerable<Job> getItems() {
            yield return new Job {FilePath = "hei.json", Query = "select * from KundeEnhetTjeneste where IDKundeEnhet=4019 FOR JSON AUTO"};
            yield return new Job {FilePath = "hei2.json", Query = "select * from KundeEnhetTjeneste where IDKundeEnhet=4010 FOR JSON AUTO"};
            yield return new Job {FilePath = "hei3.json", Query = "select * from KundeEnhetTjeneste where IDKundeEnhet=4011 FOR JSON AUTO"};
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

            var connectionString = configuration.GetConnectionString("Main");

            var conn = QueryExecuter.OpenConnection(connectionString);

            foreach (var x in Source.getItems().
					AsParallel().
					WithMergeOptions(ParallelMergeOptions.NotBuffered).
					WithExecutionMode(ParallelExecutionMode.ForceParallelism).
					WithDegreeOfParallelism(2).Select(x => {
						System.Console.WriteLine("Executing: " + x.Query);
                        return new {Job = x, Result = QueryExecuter.Execute((cmd) => new System.Data.SqlClient.SqlCommand(cmd, conn), x.Query)};
                    })) {
				System.Console.WriteLine("Done with this: " + x.Job.FilePath + "  " + x.Result.Substring(0, 60));
				System.IO.File.WriteAllText(System.IO.Path.Combine("data", x.Job.FilePath), x.Result);
            }

            Console.WriteLine("Hello World!");
        }
    }
}
