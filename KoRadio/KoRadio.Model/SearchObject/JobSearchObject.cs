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
        public bool? IsTenderFinalized { get; set; }
		public bool? IsFreelancer { get; set; }
        public bool? IsDesc { get; set; }
        public bool? IsDeleted { get; set; }
        public bool? IsDeletedWorker { get; set; }
        public int? CompanyEmployeeId { get; set; }
        public DateTime? DateRange { get; set; }
        public int? JobService { get; set; }
        public string? ClientName { get; set; }
        public string? EmployeeName { get; set; }
        public int? Location { get; set; }


    }
}
