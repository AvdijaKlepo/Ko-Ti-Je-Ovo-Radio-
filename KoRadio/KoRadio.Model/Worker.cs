using System;
using System.Collections.Generic;
using System.Text;

namespace KoRadio.Model
{
	public class Worker
	{
		public int WorkerId { get; set; }

		public int UserId { get; set; }

		public string? Bio { get; set; }

		public decimal? Rating { get; set; }
		public User User { get; set; }

	}
}
