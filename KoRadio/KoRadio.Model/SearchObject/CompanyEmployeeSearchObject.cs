﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.SearchObject
{
    public class CompanyEmployeeSearchObject: BaseSearchObject
	{
        public int? CompanyId { get; set; }
        public int? UserId { get; set; }
        public bool? IsApplicant { get; set; }
        public bool? IsDeleted { get; set; }
    }
}
