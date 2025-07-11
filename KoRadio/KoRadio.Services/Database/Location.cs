﻿using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Location
{
    public int LocationId { get; set; }

    public string LocationName { get; set; } = null!;

    public bool IsDeleted { get; set; }

    public virtual ICollection<Company> Companies { get; set; } = new List<Company>();

    public virtual ICollection<Store> Stores { get; set; } = new List<Store>();

    public virtual ICollection<User> Users { get; set; } = new List<User>();
}
