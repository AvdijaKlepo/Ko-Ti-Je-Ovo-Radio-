using System;
using System.Collections.Generic;
using System.Text;

namespace KoRadio.Model.SearchObject
{
	public class ServiceSearchObject:BaseSearchObject
	{
		public string? ServiceName { get; set; }
		public bool? GetServiceByFreelancer { get; set; }
		public int? FreelancerId { get; set; }
		public bool? ReturnCount { get; set; }
	}
}
