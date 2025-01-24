using System;
using System.Collections.Generic;
using System.Text;

namespace KoRadio.Model.SearchObject
{
	public class UserSearchObject
	{
		public string? FirstNameGTE { get; set; }
		public string? LastNameGTE { get; set; }
		public string? Email { get; set; }
		public bool? IsUserRolesIncluded { get; set; }


	}
}
