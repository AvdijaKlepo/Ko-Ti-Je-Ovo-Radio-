using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Freelancer
{
    public int FreelancerId { get; set; }

    public int? UserId { get; set; }

    public string? Bio { get; set; }

    public decimal? Rating { get; set; }

    public decimal? HourlyRate { get; set; }

    public string? Availability { get; set; }

    public int? ExperianceYears { get; set; }

    public string? Location { get; set; }

    public int? WorkingDays { get; set; }

    public TimeOnly? StartTime { get; set; }

    public TimeOnly? EndTime { get; set; }

    public virtual ICollection<FreelancerService> FreelancerServices { get; set; } = new List<FreelancerService>();

    public virtual User? User { get; set; }
}
