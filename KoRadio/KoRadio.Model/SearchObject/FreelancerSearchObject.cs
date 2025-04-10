using System;
using System.Collections.Generic;
using System.Text;

namespace KoRadio.Model.SearchObject
{
	public class FreelancerSearchObject:BaseSearchObject
	{
		public string? FirstNameGTE { get; set; }
		public string? LastNameGTE { get; set; }
		public string? Location { get; set; }
		public int? ExperianceYears { get; set; }
		public int? ServiceId { get; set; }


		public bool? IsServiceIncluded { get; set; }
	


	}
}
