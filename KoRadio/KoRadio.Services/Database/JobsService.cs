using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class JobsService
{
    public int JobId { get; set; }

    public int ServiceId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public bool? IsDeleted { get; set; }

    public virtual Job Job { get; set; } = null!;

    public virtual Service Service { get; set; } = null!;
}
