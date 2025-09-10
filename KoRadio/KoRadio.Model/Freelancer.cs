using KoRadio.Model.DTOs;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;


namespace KoRadio.Model
{

    public  class Freelancer
    {
		public int FreelancerId { get; set; }

		public string Bio { get; set; } = null!;

		public decimal Rating { get; set; }

		public int ExperianceYears { get; set; }

		public List<DayOfWeek> WorkingDays { get; set; }

		public TimeOnly StartTime { get; set; }

		public TimeOnly EndTime { get; set; }

		public bool IsDeleted { get; set; }
		public bool IsApplicant { get; set; }

		public int? TotalRatings { get; set; }

		public double? RatingSum { get; set; }
		[NotMapped]
		public double? AverageRating => TotalRatings == 0 ? 0 : RatingSum / TotalRatings;

		public byte[]? CV { get; set; }


		public virtual User FreelancerNavigation { get; set; } = null!;

		public virtual ICollection<FreelancerService> FreelancerServices { get; set; } = new List<FreelancerService>();

		
	}
}
