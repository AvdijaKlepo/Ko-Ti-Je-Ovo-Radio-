using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace KoRadio.Model.DTOs
{
	public class UserDTO
	{
		public int UserId { get; set; }
		public string FirstName { get; set; } = null!;

		public string LastName { get; set; } = null!;

		public string Email { get; set; } = null!;
		public virtual ICollection<Model.UserRole> UserRoles { get; set; } = new List<Model.UserRole>();

		public byte[]? Image { get; set; }
		public string PhoneNumber { get; set; } = null!;

		public bool IsDeleted { get; set; } = false;

		public DateTime CreatedAt { get; set; }


		public virtual Location Location { get; set; } = null!;
		public string Address { get; set; } = null!;



		//	public Location  Location { get; set; }

	}
}
