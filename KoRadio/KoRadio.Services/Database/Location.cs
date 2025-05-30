using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Location
{
    public int LocationId { get; set; }

    public string LocationName { get; set; } = null!;

    public virtual ICollection<User> Users { get; set; } = new List<User>();
}
