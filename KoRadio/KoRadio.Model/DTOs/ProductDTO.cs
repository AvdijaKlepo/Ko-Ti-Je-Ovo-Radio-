using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.DTOs
{
    public class ProductDTO
    {
		public int ProductId { get; set; }

		public string ProductName { get; set; } = null!;

		public string ProductDescription { get; set; } = null!;

		public decimal Price { get; set; }
		public bool? IsOnSale { get; set; }
		public decimal? SalePrice { get; set; }

		public int StoreId { get; set; }


		public bool IsDeleted { get; set; }
		public byte[]? Image { get; set; }

		
	}
}
