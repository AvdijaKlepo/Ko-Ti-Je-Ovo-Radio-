using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Job
{
    public int JobId { get; set; }

    public int? UserId { get; set; }

    public int? FreelancerId { get; set; }

    public TimeOnly StartEstimate { get; set; }

    public TimeOnly EndEstimate { get; set; }

    public decimal PayEstimate { get; set; }

    public decimal PayInvoice { get; set; }

    public DateTime JobDate { get; set; }

    public virtual Freelancer? Freelancer { get; set; }

    public virtual User? User { get; set; }
}
