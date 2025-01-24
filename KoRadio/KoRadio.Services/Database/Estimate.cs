using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Estimate
{
    public int EstimateId { get; set; }

    public int UserId { get; set; }

    public int FreelancerId { get; set; }

    public int? CompanyId { get; set; }

    public string Description { get; set; } = null!;

    public decimal EstimatedCost { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual Company? Company { get; set; }

    public virtual Freelancer Freelancer { get; set; } = null!;

    public virtual ICollection<Job> Jobs { get; set; } = new List<Job>();

    public virtual User User { get; set; } = null!;
}
