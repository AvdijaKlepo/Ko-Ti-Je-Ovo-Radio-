using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class EmployeeTask
{
    public int EmployeeTaskId { get; set; }

    public string Task { get; set; } = null!;

    public bool IsFinished { get; set; }

    public int? CompanyEmployeeId { get; set; }

    public DateTime CreatedAt { get; set; }

    public int JobId { get; set; }

    public int CompanyId { get; set; }

    public virtual Company Company { get; set; } = null!;

    public virtual CompanyEmployee? CompanyEmployee { get; set; }
   

    public virtual Job Job { get; set; } = null!;
}
