using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace KoRadio.Model
{
	public class UserRolesModel
	{
		public int UserRolesId { get; set; }

		public int? UserId { get; set; }

		public int? RoleId { get; set; }

		public DateTime? ChangedAt { get; set; }

		public virtual RolesModel? Role { get; set; }

	}
}
