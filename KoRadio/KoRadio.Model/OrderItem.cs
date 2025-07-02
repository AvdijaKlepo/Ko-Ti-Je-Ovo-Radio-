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

		public virtual Order Order { get; set; } = null!;

		public virtual Product Product { get; set; } = null!;
	}
}
