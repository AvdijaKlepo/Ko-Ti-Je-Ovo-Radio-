using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.SearchObject
{
    public class OrderSearchObject : BaseSearchObject
	{
        public int? UserId { get; set; }
        public int? StoreId { get; set; }
        public string? Name { get; set; }
        public bool? IsShipped { get; set; }
        public bool? IsCancelled { get; set; }
	}
}
