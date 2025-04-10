using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace KoRadio.Model.Request
{
	public class FreelancerUpdateRequest
	{

		public string? Bio { get; set; }
		public decimal? HourlyRate { get; set; }

		public string? Availability { get; set; }

		public string? Location { get; set; }

		public int? ExperianceYears { get; set; }

		public  ICollection<int> ServiceId { get; set; } = new List<int>();





	}
}
