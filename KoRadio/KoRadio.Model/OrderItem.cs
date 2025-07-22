using KoRadio.Model.DTOs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model
{
    public class OrderItem
    {
		public int OrderItemsId { get; set; }

		public int OrderId { get; set; }

		public int ProductId { get; set; }

		public int Quantity { get; set; }
		public int StoreId { get; set; }

	

		public virtual ProductDTO Product { get; set; } = null!;
		public virtual Store Store { get; set; }
	}
}
