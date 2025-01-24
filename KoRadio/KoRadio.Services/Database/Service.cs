using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Service
{
    public int ServiceId { get; set; }

    public string? ServiceName { get; set; }

    public int? FreelancerId { get; set; }

    public int? CompanyId { get; set; }

    public virtual Company? Company { get; set; }

    public virtual Freelancer? Freelancer { get; set; }
}
