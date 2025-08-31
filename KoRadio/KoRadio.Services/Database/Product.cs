using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Product:ISoftDelete
{
    public int ProductId { get; set; }

    public string ProductName { get; set; } = null!;

    public string ProductDescription { get; set; } = null!;

    public decimal Price { get; set; }

    public int StoreId { get; set; }
    public int StockQuantity { get; set; } = 0;
    public bool IsOnSale { get; set; }
    public decimal? SalePrice { get; set; }



    public bool IsDeleted { get; set; }

    public byte[]? Image { get; set; }

    public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();

    public virtual ICollection<ProductsService> ProductsServices { get; set; } = new List<ProductsService>();

    public virtual Store Store { get; set; } = null!;
}
