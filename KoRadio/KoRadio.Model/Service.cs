using System;
using System.Collections.Generic;

namespace KoRadio.Model
{




    public  class Service
    {
		public int ServiceId { get; set; }

		public string ServiceName { get; set; } = null!;

		public byte[] Image { get; set; } = null!;

		public bool IsDeleted { get; set; }
		public int FreelancerCount { get; set; }
		public int CompanyCount { get; set; }

	}
}
