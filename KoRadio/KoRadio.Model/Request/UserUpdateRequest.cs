using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace KoRadio.Model.Request
{
	public class UserInsertRequest
	{

		public string? FirstName { get; set; }

		public string? LastName { get; set; }

		public string? Email { get; set; }

		public string? Password { get; set; }

		public string? ConfirmPassword { get; set; }

		public byte[]? Image { get; set; }

		public List<int> Roles { get; set; }
		public int LocationId { get; set; }







	}
}
