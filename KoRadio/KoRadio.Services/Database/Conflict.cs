using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Conflict
{
    public int ConflictId { get; set; }

    public int JobId { get; set; }

    public string ConflictReason { get; set; } = null!;

    public DateTime? CreatedAt { get; set; }

    public virtual Job Job { get; set; } = null!;
}
