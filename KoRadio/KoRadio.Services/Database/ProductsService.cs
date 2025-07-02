using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class ProductsService
{
    public int ProductId { get; set; }

    public int ServiceId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual Product Product { get; set; } = null!;

    public virtual Service Service { get; set; } = null!;
}
