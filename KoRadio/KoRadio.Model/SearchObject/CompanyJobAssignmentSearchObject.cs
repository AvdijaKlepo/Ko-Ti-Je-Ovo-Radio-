using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.SearchObject
{
    public class CompanyJobAssignmentSearchObject: BaseSearchObject
	{
        public int? JobId { get; set; }
		public bool? IsFinished { get; set; }
		public bool? IsCancelled { get; set; }
		public int? CompanyId { get; set; }
		public int? CompanyEmployeeId { get; set; }
		public DateTime? DateRange { get; set; }

		public DateTime? JobDate { get; set; }
		public DateTime? DateFinished { get; set; }
	}
}
