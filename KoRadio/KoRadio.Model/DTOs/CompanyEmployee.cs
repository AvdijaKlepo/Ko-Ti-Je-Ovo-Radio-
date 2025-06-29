using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.DTOs
{
    public class CompanyEmployee
	{
		public int CompanyEmployeeId { get; set; }
		public int UserId { get; set; }

		public int CompanyId { get; set; }

		public bool IsDeleted { get; set; }

		public bool IsApplicant { get; set; }

		public int? CompanyRoleId { get; set; }

		public DateTime DateJoined { get; set; }
		public string CompanyName { get; set; }



		//	public virtual Company Company { get; set; } = null!;

		//	public virtual ICollection<CompanyJobAssignment> CompanyJobAssignments { get; set; } = new List<CompanyJobAssignment>();

		public virtual CompanyRole? CompanyRole { get; set; }
	




	}
}
