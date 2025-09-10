using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class OrderItem
{
    public int OrderItemsId { get; set; }

    public int OrderId { get; set; }

    public int ProductId { get; set; }
    public decimal ProductPrice { get; set; }

    public int Quantity { get; set; }

    public int? StoreId { get; set; }
    public decimal UnitPrice { get; set; }

    public virtual Order Order { get; set; } = null!;

    public virtual Product Product { get; set; } = null!;

    public virtual Store? Store { get; set; }
}
