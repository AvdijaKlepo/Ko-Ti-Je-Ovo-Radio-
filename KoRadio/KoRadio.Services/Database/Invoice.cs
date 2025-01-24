using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Invoice
{
    public int InvoiceId { get; set; }

    public int UserId { get; set; }

    public int FreelancerId { get; set; }

    public int? CompanyId { get; set; }

    public decimal Amount { get; set; }

    public int StatusId { get; set; }

    public DateTime? IssuedAt { get; set; }

    public virtual Company? Company { get; set; }

    public virtual Freelancer Freelancer { get; set; } = null!;

    public virtual ICollection<Job> Jobs { get; set; } = new List<Job>();

    public virtual JobStatus Status { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
