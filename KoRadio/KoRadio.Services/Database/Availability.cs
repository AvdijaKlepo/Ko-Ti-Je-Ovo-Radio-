using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Availability
{
    public int AvailabilityId { get; set; }

    public int FreelancerId { get; set; }

    public byte DayOfWeek { get; set; }

    public TimeOnly StartTime { get; set; }

    public TimeOnly EndTime { get; set; }

    public virtual Freelancer Freelancer { get; set; } = null!;
}
