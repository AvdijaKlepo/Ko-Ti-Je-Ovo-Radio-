using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class JobStatus
{
    public int StatusId { get; set; }

    public string StatusName { get; set; } = null!;

    public virtual ICollection<Invoice> Invoices { get; set; } = new List<Invoice>();

    public virtual ICollection<Job> Jobs { get; set; } = new List<Job>();
}
