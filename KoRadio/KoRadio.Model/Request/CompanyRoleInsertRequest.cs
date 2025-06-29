using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.Request
{
    public class CompanyRoleInsertRequest
    {
		public int? CompanyId { get; set; }

		public string? RoleName { get; set; }
	}
}
