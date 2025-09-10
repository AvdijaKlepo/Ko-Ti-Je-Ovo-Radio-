using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.SearchObject
{
    public class ProductSearchObject : BaseSearchObject
	{
        public string? Name { get; set; }
        public bool? IsDeleted { get; set; }
        public int? StoreId { get; set; }
        public int? ServiceId { get; set; }
        public bool? OutOfStock { get; set; }
        public bool? OnSale { get; set; }

	}
}
