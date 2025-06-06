using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class CompanyService
{
    public int CompanyId { get; set; }

    public int ServiceId { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual Company Company { get; set; } = null!;

    public virtual Service Service { get; set; } = null!;
}
