﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.Request
{
    public class CompanyRoleUpdateRequest
    {
		public int? CompanyId { get; set; }

		public string? RoleName { get; set; }
	}
}
