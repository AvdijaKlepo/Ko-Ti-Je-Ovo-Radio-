using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.Request
{
    public class CompanyJobAssignmentInsertRequest
    {
		public int? CompanyEmployeeId { get; set; }

		public int? JobId { get; set; }

		public DateTime AssignedAt { get; set; }
		public bool IsFinished { get; set; }


	}
}
