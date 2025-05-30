using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.Request
{
    public class LocationUpdateRequest
    {
		public int LocationId { get; set; }

		public string LocationName { get; set; } = null!;
	}
}
