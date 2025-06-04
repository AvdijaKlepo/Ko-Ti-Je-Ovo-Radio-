using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.DTOs
{
    public class FreelancerDTO
    {

		public int FreelancerId { get; set; }

		public string? Bio { get; set; }

		public decimal? Rating { get; set; }

		public int? ExperianceYears { get; set; }


		public List<DayOfWeek>? WorkingDays { get; set; }

		public TimeOnly? StartTime { get; set; }

		public TimeOnly? EndTime { get; set; }


		public string? ServiceName { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public string Email { get; set; }
		public string LocationName { get; set; }

	}
}
