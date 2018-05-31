using System.Linq;
using JsonReader.Fetchers;
using Xunit;

namespace tests
{
    public class FetchEventsTest
    {
        [Fact]
        public void Should_produce_intervals_of_given_length_up_to_what_is_assumed_to_be_today()
        {
            var items = FetchEvents.ProduceEvents(new FetchEvents.FetchEventsConfig {
                    eventIntervalHours = 48,
                    eventStartDate = new System.DateTime(2018, 01, 15)
                }, 
                file => $"SOME QUERY FROM {file}",
                new System.DateTime(2018, 01, 22)).ToList();
            Assert.Equal(6, items.Count);
            Assert.Equal(2, items[0].Params.Count);
            Assert.Equal(new System.DateTime(2018, 01, 15), items[0].Params[0].Value);
            Assert.Equal(new System.DateTime(2018, 01, 17), items[0].Params[1].Value);
            Assert.Equal("SOME QUERY FROM FetchUsageEvents.sql", items[0].Query);
            Assert.Equal("UsageEvents_2018-01-15.json", items[0].FilePath);
            Assert.Equal("EmptyingEvents_2018-01-15.json", items[0].FilePath);
            Assert.Equal(new System.DateTime(2018, 01, 19), items[5].Params[0].Value);
            Assert.Equal(new System.DateTime(2018, 01, 21), items[5].Params[1].Value);
        }

    }
}
