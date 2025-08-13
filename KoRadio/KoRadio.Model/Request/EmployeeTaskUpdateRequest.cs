using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.Request
{
	public class EmployeeTaskUpdateRequest
	{


		public string Task { get; set; } = null!;

		public bool IsFinished { get; set; }

		public int? CompanyEmployeeId { get; set; }
		public DateTime CreatedAt { get; set; }
		public int JobId { get; set; }

		public int CompanyId { get; set; }



	}
}
