using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.Request
{
    public class TenderBidInsertRequest
    {
	

		public int? FreelancerId { get; set; }

		public int? CompanyId { get; set; }

		public decimal BidAmount { get; set; }

		public string? BidDescription { get; set; }

		public DateTime? DateFinished { get; set; }

		public DateTime CreatedAt { get; set; }

		public int JobId { get; set; }

		public TimeOnly? StartEstimate { get; set; }

		public TimeOnly? EndEstimate { get; set; }






	}
}
