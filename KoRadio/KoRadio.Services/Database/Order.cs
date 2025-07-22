using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Order
{
    public int OrderId { get; set; }

    public int OrderNumber { get; set; }

    public int UserId { get; set; }

    public bool IsCancelled { get; set; }

    public bool IsShipped { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();

    public virtual User User { get; set; } = null!;
}
