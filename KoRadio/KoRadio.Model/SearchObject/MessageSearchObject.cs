using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.SearchObject
{
    public class MessageSearchObject: BaseSearchObject
	{
        public int? UserId { get; set; }
        public bool? IsOpened { get; set; }
    }
}
