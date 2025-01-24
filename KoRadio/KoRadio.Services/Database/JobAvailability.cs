using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class JobAvailability
{
    public int JobAvailabilityId { get; set; }

    public int? FreelancerId { get; set; }

    public int? CompanyId { get; set; }

    public DateTime StartTime { get; set; }

    public DateTime EndTime { get; set; }

    public bool? IsAvailable { get; set; }

    public virtual Company? Company { get; set; }

    public virtual Freelancer? Freelancer { get; set; }
}
