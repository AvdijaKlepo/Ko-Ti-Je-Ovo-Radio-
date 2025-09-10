using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.Request
{
    public class ProductUpdateRequest
    {
		public string? ProductName { get; set; } = null!;

		public string? ProductDescription { get; set; } = null!;

		public decimal? Price { get; set; }
		public int? StockQuantity { get; set; } = 0;
		public bool IsOutOfStock { get; set; }

		public bool? IsOnSale { get; set; }
		public decimal? SalePrice { get; set; }
		public DateTime? SaleExpires { get; set; }
		

	
		public byte[]? Image { get; set; }
		public ICollection<int>? ServiceId { get; set; } = new List<int>();
		public bool? IsDeleted { get; set; }
	}
}
