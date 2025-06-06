using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Freelancer
{
    public int FreelancerId { get; set; }

    public string Bio { get; set; } = null!;

    public decimal Rating { get; set; }

    public int ExperianceYears { get; set; }

    public int WorkingDays { get; set; }

    public TimeOnly StartTime { get; set; }

    public TimeOnly EndTime { get; set; }

    public bool IsDeleted { get; set; }

    public virtual User FreelancerNavigation { get; set; } = null!;

    public virtual ICollection<FreelancerService> FreelancerServices { get; set; } = new List<FreelancerService>();

    public virtual ICollection<Job> Jobs { get; set; } = new List<Job>();
}
