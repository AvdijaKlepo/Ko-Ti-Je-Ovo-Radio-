using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.DTOs
{
    public class StoresDTO
    {
		public int StoreId { get; set; }

		public string StoreName { get; set; } = null!;

		public int UserId { get; set; }

		public string Description { get; set; } = null!;
		public bool IsApplicant { get; set; }
		public bool IsDeleted { get; set; }

		public virtual ICollection<Product> Products { get; set; } = new List<Product>();
		public virtual Location Location { get; set; } = null!;
	}
}
