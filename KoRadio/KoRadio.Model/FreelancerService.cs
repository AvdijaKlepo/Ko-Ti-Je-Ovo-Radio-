using System;
using System.Collections.Generic;


namespace KoRadio.Model
{

    public  class FreelancerService
    {
		public int FreelancerId { get; set; }

		public int ServiceId { get; set; }

		public DateTime? CreatedAt { get; set; }

		public bool? IsDeleted { get; set; }

	

		public virtual Service? Service { get; set; } = null!;
	}
}
