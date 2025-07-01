using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.SearchObject
{
    public class JobSearchObject: BaseSearchObject
	{
        public int? JobId { get; set; }
        public int? FreelancerId { get; set; }
        public int? CompanyId { get; set; }
        public int? UserId { get; set; }
        public DateTime? JobDate  { get; set; }
        public string? JobStatus { get; set; }

    }
}
