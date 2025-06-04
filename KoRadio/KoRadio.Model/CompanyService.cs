using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model
{
    public class CompanyService
    {
		public int CompanyId { get; set; }

		public int ServiceId { get; set; }

		public DateTime? CreatedAt { get; set; }

		public bool? IsDeleted { get; set; }

		public virtual Company Company { get; set; } = null!;

		public virtual Service Service { get; set; } = null!;
	}
}
