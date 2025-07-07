using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class TenderService
{
    public int TenderId { get; set; }

    public int ServiceId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual Service Service { get; set; } = null!;

    public virtual Tender Tender { get; set; } = null!;
}
