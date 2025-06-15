using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class CompanyEmployee
{
    public int UserId { get; set; }

    public int CompanyId { get; set; }

    public bool IsDeleted { get; set; }

    public bool IsApplicant { get; set; }

    public virtual Company Company { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
