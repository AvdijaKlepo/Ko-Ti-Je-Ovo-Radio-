using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace KoRadio.Model
{
	public class UserModel
	{
		public string? FirstName { get; set; }

		public string? LastName { get; set; }

		public string? Email { get; set; }
		public virtual ICollection<UserRolesModel> UserRolesModels { get; set; } = new List<UserRolesModel>();


	}
}
