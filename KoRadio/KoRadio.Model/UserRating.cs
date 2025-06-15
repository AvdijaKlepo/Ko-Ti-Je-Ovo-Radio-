using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model
{
    public class UserRating
    {
		public int? UserId { get; set; }

		public int? FreelancerId { get; set; }

		public decimal Rating { get; set; }

		public int? JobId { get; set; }

		public virtual Freelancer? Freelancer { get; set; }

		public virtual Job? Job { get; set; }

		public virtual User? User { get; set; }
	}
}
