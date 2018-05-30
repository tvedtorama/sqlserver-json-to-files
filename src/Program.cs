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
            yield return new Job {FilePath = "data/hei.json", Query = "select * from KundeEnhetTjeneste where IDKundeEnhet=4019 FOR JSON AUTO"};
            yield return new Job {FilePath = "data/hei2.json", Query = "select * from KundeEnhetTjeneste where IDKundeEnhet=4010 FOR JSON AUTO"};
            yield return new Job {FilePath = "data/hei3.json", Query = "select * from KundeEnhetTjeneste where IDKundeEnhet=4011 FOR JSON AUTO"};
            yield return new Job {FilePath = "data/hei4.json", Query = "select * from KundeEnhetTjeneste where IDKundeEnhet=4012 FOR JSON AUTO"};
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
                        return new {Job = x, result = QueryExecuter.Execute((cmd) => new System.Data.SqlClient.SqlCommand(cmd, conn), x.Query)};
                    })) {
                System.Console.WriteLine("Done with this: " + x.Job.FilePath + "  " + x.result.Substring(0, 20));
            }

            Console.WriteLine("Hello World!");
        }
    }
}
