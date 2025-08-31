using System;
using System.Collections.Generic;
using System.Text;

namespace KoRadio.Model.SearchObject
{
	public class UserSearchObject:BaseSearchObject

	{
		public int? UserId { get; set; }
		public string? FirstNameGTE { get; set; }
		public string? LastNameGTE { get; set; }
		public string? Email { get; set; }
		public bool? IsUserRolesIncluded { get; set; }

		public bool? IsFreelancerIncluded { get; set; }
		public bool? IsEmployeeIncluded { get; set; }

		public string? OrderBy { get; set; }
		public bool isDeleted { get; set; }


	}
}
