using System;
using System.Collections.Generic;
using System.Text;

namespace KoRadio.Model
{
	public class WorkerModel
	{
		public int WorkerId { get; set; }

		public int UserId { get; set; }

		public string? Bio { get; set; }

		public decimal? Rating { get; set; }
		public UserModel User { get; set; }

	}
}
