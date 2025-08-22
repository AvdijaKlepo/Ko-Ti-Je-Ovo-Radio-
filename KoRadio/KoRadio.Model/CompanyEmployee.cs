using KoRadio.Model.DTOs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model
{
    public class CompanyEmployee
    {	
		public int CompanyEmployeeId { get; set; }
		public int UserId { get; set; }

		public int CompanyId { get; set; }

		public bool IsDeleted { get; set; }

		public bool IsApplicant { get; set; }
		public bool IsOwner { get; set; }

		public int? CompanyRoleId { get; set; }

		public DateTime DateJoined { get; set; }

	

		public string CompanyName { get; set; }

	//	public virtual ICollection<CompanyJobAssignment> CompanyJobAssignments { get; set; } = new List<CompanyJobAssignment>();

		public virtual string? CompanyRoleName { get; set; }

		public virtual UserDTO User { get; set; } = null!;
	}
	
}
