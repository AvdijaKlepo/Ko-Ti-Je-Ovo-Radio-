using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Freelancer:ISoftDelete,IApplicantDelete
{
    public int FreelancerId { get; set; }

    public string Bio { get; set; } = null!;

    public decimal Rating { get; set; }

    public int ExperianceYears { get; set; }

    public int WorkingDays { get; set; }

    public TimeOnly StartTime { get; set; }

    public TimeOnly EndTime { get; set; }

    public bool IsDeleted { get; set; }

    public bool IsApplicant { get; set; }

    public int? TotalRatings { get; set; }

    public double? RatingSum { get; set; }

    public virtual User FreelancerNavigation { get; set; } = null!;

    public virtual ICollection<FreelancerService> FreelancerServices { get; set; } = new List<FreelancerService>();

    public virtual ICollection<Job> Jobs { get; set; } = new List<Job>();

    public virtual ICollection<TenderBid> TenderBids { get; set; } = new List<TenderBid>();

    public virtual ICollection<Tender> Tenders { get; set; } = new List<Tender>();

    public virtual ICollection<UserRating> UserRatings { get; set; } = new List<UserRating>();
}
