using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.SearchObject
{
    public class CompanySearchObject:BaseSearchObject
    {
        public int? CompanyId { get; set; }
        public bool? IsApplicant { get; set; }
        public bool? IsDeleted { get; set; }
    }
}
