using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.Request
{
    public class OrderInsertRequest
    {
		public int OrderNumber { get; set; }

		public int UserId { get; set; }
	

		public List<OrderItemInsertRequest> OrderItems { get; set; }
	}

	public class OrderItemInsertRequest
	{
		

	

		public int ProductId { get; set; }

		public int Quantity { get; set; }
		public int StoreId { get; set; }

	
	}
}
