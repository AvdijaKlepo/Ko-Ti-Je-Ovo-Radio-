using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model
{
    public class Product
    {
		public int ProductId { get; set; }

		public string ProductName { get; set; } = null!;

		public string ProductDescription { get; set; } = null!;

		public decimal Price { get; set; }

		public int StoreId { get; set; }


		public bool IsDeleted { get; set; }
		public byte[]? Image { get; set; }

		
		public virtual ICollection<ProductsService> ProductsServices { get; set; } = new List<ProductsService>();

	
	}
}
