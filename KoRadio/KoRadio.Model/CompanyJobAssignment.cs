﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model
{
    public class CompanyJobAssignment
    {
		

		public int? CompanyEmployeeId { get; set; }

		public int? JobId { get; set; }

		public DateTime AssignedAt { get; set; }

		public virtual CompanyEmployee? CompanyEmployee { get; set; }

		public virtual Job? Job { get; set; }
	}
}
