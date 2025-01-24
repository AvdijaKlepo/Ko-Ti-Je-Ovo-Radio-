using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class CompanyWorker
{
    public int CompanyWorkersId { get; set; }

    public int WorkerId { get; set; }

    public int CompanyId { get; set; }

    public virtual Company Company { get; set; } = null!;

    public virtual Worker Worker { get; set; } = null!;
}
