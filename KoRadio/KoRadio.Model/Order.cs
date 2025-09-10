using KoRadio.Model.DTOs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model
{
    public class Order
    {
		public int OrderId { get; set; }

		public int OrderNumber { get; set; }

		public int UserId { get; set; }
		public bool IsCancelled { get; set; }
		public decimal ProductPrice { get; set; }

		public bool IsShipped { get; set; }
		public decimal Price { get; set; }

		public DateTime CreatedAt { get; set; }

		public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();

		public virtual UserDTO User { get; set; } = null!;
	}
}
