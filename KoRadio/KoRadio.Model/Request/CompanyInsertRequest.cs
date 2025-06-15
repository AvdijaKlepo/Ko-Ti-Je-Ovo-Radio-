using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.Request
{
    public class CompanyInsertRequest
    {
	
		public string CompanyName { get; set; } = null!;
		public string Email { get; set; } = null!;

		public string? Bio { get; set; }

		public decimal? Rating { get; set; }

		public string? PhoneNumber { get; set; }

		public int? ExperianceYears { get; set; }

		public byte[]? Image { get; set; }

		public List<DayOfWeek>? WorkingDays { get; set; }


		public TimeOnly StartTime { get; set; }

		public TimeOnly EndTime { get; set; }

		public int? LocationId { get; set; }

		public ICollection<int> ServiceId { get; set; } = new List<int>();
		public bool? IsApplicant { get; set; }
		public bool? IsDeleted { get; set; }
		public List<int> Employee { get; set; }


	}
}
