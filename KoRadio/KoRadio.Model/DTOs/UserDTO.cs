using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace KoRadio.Model.DTOs
{
	public class UserDTO
	{
		public int UserId { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public string Email { get; set; }
		public string LocationName { get; set; }
		public List<string> Roles { get; set; }
	}
}
