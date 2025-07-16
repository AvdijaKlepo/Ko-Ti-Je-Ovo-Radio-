using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Message
{
    public int MessageId { get; set; }

    public string? Message1 { get; set; }

    public int? UserId { get; set; }

    public bool IsOpened { get; set; }

    public virtual User? User { get; set; }
}
