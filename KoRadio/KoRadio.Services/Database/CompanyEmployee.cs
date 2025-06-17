using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class CompanyEmployee
{
    public int UserId { get; set; }

    public int CompanyId { get; set; }

    public bool IsDeleted { get; set; }

    public bool IsApplicant { get; set; }

    public int? CompanyRoleId { get; set; }

    public DateTime DateJoined { get; set; }

    public int CompanyEmployeeId { get; set; }

    public virtual Company Company { get; set; } = null!;

    public virtual ICollection<CompanyJobAssignment> CompanyJobAssignments { get; set; } = new List<CompanyJobAssignment>();

    public virtual CompanyRole? CompanyRole { get; set; }

    public virtual User User { get; set; } = null!;
}
