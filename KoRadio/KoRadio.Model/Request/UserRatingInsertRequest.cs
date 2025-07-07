using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.Request
{
    public class UserRatingInsertRequest
    {
		public int? UserId { get; set; }

		public int? FreelancerId { get; set; }
		public int? CompanyId { get; set; }

		public decimal Rating { get; set; }

		public int? JobId { get; set; }
	}
}
