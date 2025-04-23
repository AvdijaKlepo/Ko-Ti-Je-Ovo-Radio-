using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.Request
{
    public class JobInsertRequest
    {


		public int? UserId { get; set; }

		public int? FreelancerId { get; set; }

		public TimeOnly StartEstimate { get; set; }

		public TimeOnly EndEstimate { get; set; }

		public decimal PayEstimate { get; set; }

		public decimal PayInvoice { get; set; }

		public DateTime JobDate { get; set; }


	}
}
