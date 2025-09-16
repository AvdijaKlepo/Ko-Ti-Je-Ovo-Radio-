using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class CompanyJobAssignment
{
    public int CompanyJobId { get; set; }

    public int? CompanyEmployeeId { get; set; }

    public int? JobId { get; set; }

    public DateTime AssignedAt { get; set; }

    public bool IsFinished { get; set; }
    public bool IsCancelled { get; set; }

	public virtual CompanyEmployee? CompanyEmployee { get; set; }

    public virtual Job? Job { get; set; }
}
