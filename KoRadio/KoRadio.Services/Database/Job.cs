using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Job
{
    public int JobId { get; set; }

    public int UserId { get; set; }

    public int? FreelancerId { get; set; }

    public int? CompanyId { get; set; }

    public int EstimateId { get; set; }

    public int? InvoiceId { get; set; }

    public int StatusId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual Company? Company { get; set; }

    public virtual ICollection<Conflict> Conflicts { get; set; } = new List<Conflict>();

    public virtual Estimate Estimate { get; set; } = null!;

    public virtual Freelancer? Freelancer { get; set; }

    public virtual Invoice? Invoice { get; set; }

    public virtual JobStatus Status { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
