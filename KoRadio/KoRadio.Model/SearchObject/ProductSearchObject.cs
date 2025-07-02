using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.SearchObject
{
    public class ProductSearchObject : BaseSearchObject
	{
        public bool? IsDeleted { get; set; }
        public int? StoreId { get; set; }
        public int? ServiceId { get; set; }
    }
}
