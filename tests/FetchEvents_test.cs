using System.Linq;
using JsonReader.Fetchers;
using Xunit;

namespace tests
{
    public class FetchEventsTest
    {
        [Fact]
        public void Should_generate_intervals()
        {
            var items = FetchEvents.ProduceEvents(null, file => $"SOME QUERY FROM {file}").ToList();
            Assert.Equal(2, items.Count);
            Assert.Equal(2, items[0].Params.Count);
            Assert.Equal(new System.DateTime(2018, 01, 15), items[0].Params[0].Value);
            Assert.Equal(new System.DateTime(2018, 01, 17), items[0].Params[1].Value);
            Assert.Equal("SOME QUERY FROM FetchUsageEvents.sql", items[0].Query);
            Assert.Equal("UsageEvents_2018-01-15.json", items[0].FilePath);
            Assert.Equal(new System.DateTime(2018, 01, 17), items[1].Params[0].Value);
            Assert.Equal(new System.DateTime(2018, 01, 19), items[1].Params[1].Value);
        }
    }
}
