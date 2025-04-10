using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class FreelancerService
{
    public int FreelancerId { get; set; }

    public int ServiceId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public bool? IsDeleted { get; set; }

    public virtual Freelancer Freelancer { get; set; } = null!;

    public virtual Service Service { get; set; } = null!;
}
