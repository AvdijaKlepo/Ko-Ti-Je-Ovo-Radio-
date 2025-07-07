using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.Request
{
    public class TenderInsertRequest
    {
		public DateTime JobDate { get; set; }

		public string JobDescription { get; set; } = null!;

		public byte[]? Image { get; set; }

		public bool IsFinalized { get; set; }

		public int? UserId { get; set; }

		public int? FreelancerId { get; set; }

		public int? CompanyId { get; set; }

		public bool IsFreelancer { get; set; }
		public ICollection<int> ServiceId { get; set; } = new List<int>();

	}
}
