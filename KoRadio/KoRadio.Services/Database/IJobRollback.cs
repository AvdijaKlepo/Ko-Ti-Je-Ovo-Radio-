using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Database
{
    internal interface IJobRollback
    {
		public bool IsEdited { get; set; }

		public bool IsApproved { get; set; }
	}
}
