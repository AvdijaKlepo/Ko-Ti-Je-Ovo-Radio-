using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.SearchObject
{
    public class StoreSearchObject: BaseSearchObject
	{
        public string? Name { get; set; }
        public string? OwnerName { get; set; }
        public bool? IsApplicant { get; set; }
        public bool? IsDeleted { get; set; }
        public int? LocationId { get; set; }
        public int? StoreId { get; set; }
    }
}
