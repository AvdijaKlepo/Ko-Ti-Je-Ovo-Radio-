using System;
using System.Collections.Generic;


namespace KoRadio.Model
{

    public  class Availability
    {
		public int AvailabilityId { get; set; }

		public int FreelancerId { get; set; }

		public byte DayOfWeek { get; set; }

		public TimeOnly StartTime { get; set; }

		public TimeOnly EndTime { get; set; }

		public virtual Freelancer Freelancer { get; set; } = null!;
	}
}
