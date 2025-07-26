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
		public DateTime CreatedAt { get; set; }

		public int? UserId { get; set; }

		public bool IsOpened { get; set; }

		public int? CompanyId { get; set; }

		public int? StoreId { get; set; }

		public virtual Company? Company { get; set; }

		public virtual Store? Store { get; set; }

		public virtual User? User { get; set; }
	}
}
