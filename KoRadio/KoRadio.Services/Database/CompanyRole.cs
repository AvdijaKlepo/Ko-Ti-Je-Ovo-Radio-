using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class CompanyRole
{
    public int CompanyRoleId { get; set; }

    public int? CompanyId { get; set; }

    public string? RoleName { get; set; }

    public virtual Company? Company { get; set; }

    public virtual ICollection<CompanyEmployee> CompanyEmployees { get; set; } = new List<CompanyEmployee>();
}
