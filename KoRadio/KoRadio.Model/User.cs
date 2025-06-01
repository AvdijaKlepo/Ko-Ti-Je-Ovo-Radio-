using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace KoRadio.Model
{
	public  class User
	{
		public int UserId { get; set; }
		public string? FirstName { get; set; }

		public string? LastName { get; set; }

		public string? Email { get; set; }
		public virtual ICollection<Model.UserRole> UserRoles { get; set; } = new List<Model.UserRole>();

		public byte[]? Image { get; set; }
		public Freelancer? Freelancer { get; set; }

		public Location? Location { get; set; }
		





	}

	public class LocationResponse
	{
		public int LocationId { get; set; }
		public string? LocationName { get; set; }
	}
}
