using System;
using System.Collections.Generic;
using System.Linq;

namespace sqlserver_json_to_files
{
    public class Job {
        public string Query;
        public string FilePath;
    }

    static class Source {
        public static IEnumerable<Job> getItems() {
            yield return new Job {FilePath = "data/hei.json", Query = "jauda"};
            yield return new Job {FilePath = "data/hei2.json", Query = "jadda"};
            yield return new Job {FilePath = "data/hei.json", Query = "sann gaar no"};
            yield return new Job {FilePath = "data/hei2.json", Query = "dagan"};
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            foreach (var x in Source.getItems().
                    AsParallel().
                    WithMergeOptions(ParallelMergeOptions.NotBuffered).
                    WithExecutionMode(ParallelExecutionMode.ForceParallelism).
                    WithDegreeOfParallelism(2).Select(x => {
                        System.Console.WriteLine(x.Query);
                        System.Threading.Thread.Sleep(2000);
                        return x.Query;
                    })) {
                System.Console.WriteLine("Done with this: " + x);
            }

            Console.WriteLine("Hello World!");
        }
    }
}
