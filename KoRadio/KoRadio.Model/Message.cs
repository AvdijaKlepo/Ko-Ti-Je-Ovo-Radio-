using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model
{
    public class Message
    {
		public int MessageId { get; set; }

		public string? Message1 { get; set; }

		public int? UserId { get; set; }

		public bool IsOpened { get; set; }

		public virtual User? User { get; set; }
	}
}
