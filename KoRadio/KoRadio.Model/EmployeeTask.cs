using KoRadio.Model.DTOs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model
{
	public class EmployeeTask
	{
		public int EmployeeTaskId { get; set; }

		public string Task { get; set; } = null!;

		public bool IsFinished { get; set; }

		public int? CompanyEmployeeId { get; set; }
		public DateTime CreatedAt { get; set; }
		public int JobId { get; set; }

		public int CompanyId { get; set; }

		public virtual Company Company { get; set; } = null!;

		public virtual CompanyEmployeeDto? CompanyEmployee { get; set; }

		public virtual Job Job { get; set; } = null!;

	
	}
}
