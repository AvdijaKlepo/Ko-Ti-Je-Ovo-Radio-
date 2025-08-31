using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Data;
using System.Text;
using System.Text.Json.Serialization;

namespace KoRadio.Model.Request
{
	public class FreelancerUpdateRequest
	{

		public int FreelancerId { get; set; }

		public string? Bio { get; set; }

		public decimal? Rating { get; set; } = 0;

	

		public int? ExperianceYears { get; set; }



		public List<DayOfWeek>? WorkingDays { get; set; }

		public TimeOnly? StartTime { get; set; }

		public TimeOnly? EndTime { get; set; }

		public ICollection<int>? ServiceId { get; set; } = new List<int>();
		public List<int>? Roles { get; set; }
		public bool? IsApplicant { get; set; }
		public bool? isDeleted { get; set; }





	}
}
