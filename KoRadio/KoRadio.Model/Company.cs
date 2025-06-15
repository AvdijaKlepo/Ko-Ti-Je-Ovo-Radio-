using System;
using System.Collections.Generic;

namespace KoRadio.Model
{



    public partial class Company
    {
		public int CompanyId { get; set; }
		public string CompanyName { get; set; } = null!;
		public string Email { get; set; } = null!;

		public string Bio { get; set; } = null!;

		public decimal? Rating { get; set; }

		public string PhoneNumber { get; set; } = null!;

		public int ExperianceYears { get; set; }

		public byte[] Image { get; set; } = null!;

		public List<DayOfWeek> WorkingDays { get; set; }

		public TimeOnly StartTime { get; set; }

		public TimeOnly EndTime { get; set; }

		public int LocationId { get; set; }

		public bool IsDeleted { get; set; }
		public bool IsApplicant { get; set; }


		public virtual ICollection<CompanyService> CompanyServices { get; set; } = new List<CompanyService>();
		public virtual ICollection<CompanyEmployee> CompanyEmployees { get; set; } = new List<CompanyEmployee>();

		public virtual Location Location { get; set; } = null!;
	}
}
