using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model
{
    public class CompanyEmployee
    {
		public int UserId { get; set; }

		public int CompanyId { get; set; }

		public bool IsDeleted { get; set; }

		public bool IsApplicant { get; set; }

	

		public virtual User User { get; set; } = null!;
	}
}
