using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.SearchObject
{
	public class EmployeeTaskSearchObject:BaseSearchObject
	{
		public int? CompanyId { get; set; }
		public int? JobId { get; set; }
		public int? CompanyEmployeeId { get; set; }
	}
}
