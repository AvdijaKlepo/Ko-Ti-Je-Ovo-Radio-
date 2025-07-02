using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.Request
{
    public class StoreUpdateRequest
    {
		

		public string StoreName { get; set; } = null!;

		public int UserId { get; set; }

		public string Description { get; set; } = null!;
		public byte[]? Image { get; set; }
		public bool IsApplicant { get; set; }
		public bool IsDeleted { get; set; }
		public List<int> Roles { get; set; }
		public int LocationId { get; set; }
	}
}
