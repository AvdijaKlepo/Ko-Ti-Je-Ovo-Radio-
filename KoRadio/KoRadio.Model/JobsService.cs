using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model
{
    public class JobsService
    {
		public int? JobId { get; set; }

		public int? ServiceId { get; set; }

		public DateTime? CreatedAt { get; set; }

		public bool? IsDeleted { get; set; }

		
 
		public virtual Service? Service { get; set; }
	}
}
