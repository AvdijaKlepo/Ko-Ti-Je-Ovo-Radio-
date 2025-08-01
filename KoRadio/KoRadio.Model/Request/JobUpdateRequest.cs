using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.Request
{
    public class JobUpdateRequest
    {
		public int? UserId { get; set; }

		public int? FreelancerId { get; set; }
		public int? CompanyId { get; set; }

		public string JobTitle { get; set; }
		public bool IsTenderFinalized { get; set; }
		public bool IsInvoiced { get; set; }

		public bool IsRated { get; set; }

		public TimeOnly? StartEstimate { get; set; }

		public TimeOnly? EndEstimate { get; set; }

		public decimal? PayEstimate { get; set; }

		public decimal? PayInvoice { get; set; }

		public DateTime JobDate { get; set; }

		public DateTime? DateFinished { get; set; }

		public string? JobDescription { get; set; }

		public byte[]? Image { get; set; }
		public string JobStatus { get; set; } = null!;

		public ICollection<int> ServiceId { get; set; } = new List<int>();
		public bool IsDeleted { get; set; }
		public bool IsDeletedWorker { get; set; }

		public bool IsEdited { get; set; }
		public bool IsApproved { get; set; }
		public string? RescheduleNote { get; set; }
	}
}
