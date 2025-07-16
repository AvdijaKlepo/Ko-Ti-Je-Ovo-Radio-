using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.Request
{
    public class MessageInsertRequest
    {
		

		public string? Message1 { get; set; }

		public int? UserId { get; set; }
		public bool IsOpened { get; set; }


	}
}
