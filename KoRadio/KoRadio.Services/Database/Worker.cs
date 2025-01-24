using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Worker
{
    public int WorkerId { get; set; }

    public int UserId { get; set; }

    public decimal? Rating { get; set; }

    public virtual ICollection<CompanyWorker> CompanyWorkers { get; set; } = new List<CompanyWorker>();

    public virtual Freelancer? Freelancer { get; set; }

    public virtual User User { get; set; } = null!;
}
