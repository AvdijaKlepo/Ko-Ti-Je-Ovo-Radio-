using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class CompanyEmployee
{
    public int CompanyEmployeeId { get; set; }

    public int? UserId { get; set; }

    public virtual User? User { get; set; }
}
