using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model
{
    public class Store
    {
		public int StoreId { get; set; }

		public string StoreName { get; set; } = null!;

		public int UserId { get; set; }

		public string Description { get; set; } = null!;
		public byte[]? Image { get; set; }
		public byte[]? BusinessCertificate { get; set; }
		public decimal Rating { get; set; }
		public List<DayOfWeek> WorkingDays { get; set; }

		public TimeOnly StartTime { get; set; }

		public TimeOnly EndTime { get; set; }
		public int? TotalRatings { get; set; }

		public double? RatingSum { get; set; }
		[NotMapped]
		public double? AverageRating => TotalRatings == 0 ? 0 : RatingSum / TotalRatings;
		public bool IsApplicant { get; set; }
		public bool IsDeleted { get; set; }
		public string? Address { get; set; }
		public byte[]? StoreCatalogue { get; set; }
		public DateTime? StoreCataloguePublish { get; set; }
		public virtual ICollection<Product> Products { get; set; } = new List<Product>();
		public virtual Location Location { get; set; } = null!;

		public virtual User User { get; set; } = null!;
	}
}
