using KoRadio.Model.DTOs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model
{
    public class TenderBid
    {
		public int TenderBidId { get; set; }

		public int? FreelancerId { get; set; }

		public int? CompanyId { get; set; }

		public decimal BidAmount { get; set; }

		public string? BidDescription { get; set; }

		public DateTime? DateFinished { get; set; }

		public DateTime CreatedAt { get; set; }

		public int JobId { get; set; }

		public TimeOnly? StartEstimate { get; set; }

		public TimeOnly? EndEstimate { get; set; }



		public virtual Company? Company { get; set; }

		public virtual Freelancer? Freelancer { get; set; }

		public virtual JobDTO Job { get; set; } = null!;


	}
}
