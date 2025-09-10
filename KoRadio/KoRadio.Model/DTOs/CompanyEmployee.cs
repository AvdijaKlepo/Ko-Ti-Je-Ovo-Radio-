using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.DTOs
{
	public class CompanyEmployeeDto
	{
		public int CompanyEmployeeId { get; set; }
		public int UserId { get; set; }
		public int CompanyId { get; set; }
		public bool IsApplicant { get; set; }
		public bool IsDeleted { get; set; }
		public bool IsOwner { get; set; }
		public int? CompanyRoleId { get; set; }
		public DateTime DateJoined { get; set; }
		public string CompanyName { get; set; } = null!;
		public string? CompanyRoleName { get; set; }
		public CompanyDto? Company { get; set; }
		public UserManualDto User { get; set; } = null!;
	}

	public class UserManualDto
	{
		public int UserId { get; set; }
		public string FirstName { get; set; } = null!;
		public string LastName { get; set; } = null!;
		public string Email { get; set; } = null!;
		public string PhoneNumber { get; set; } = null!;
	}
	public class CompanyDto
	{
		public bool IsDeleted { get; set; }
	
	}

}
