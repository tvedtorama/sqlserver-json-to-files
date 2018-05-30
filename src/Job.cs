using System.Collections.Generic;

namespace JsonReader
{
    public class Job {
        public string Query;
        public string FilePath;
        public IList<System.Data.SqlClient.SqlParameter> Params = new List<System.Data.SqlClient.SqlParameter>();
    }
}
