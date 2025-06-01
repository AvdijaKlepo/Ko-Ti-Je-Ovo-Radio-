using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;


namespace KoRadio.Model
{

    public  class Freelancer
    {
        public int FreelancerId { get; set; }

        public int? UserId { get; set; }

        public string? Bio { get; set; }

        public decimal? Rating { get; set; }

        public int? ExperianceYears { get; set; }

    
		public List<DayOfWeek>? WorkingDays { get; set; } 

		public TimeOnly? StartTime { get; set; }

		public TimeOnly? EndTime { get; set; }


		public  ICollection<FreelancerService> FreelancerServices { get; set; } = new List<FreelancerService>();

  
        public User User { get; set; }
    }
}
