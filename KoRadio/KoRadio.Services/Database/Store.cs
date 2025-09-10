using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Store:ISoftDelete,IApplicantDelete
{
    public int StoreId { get; set; }

    public string StoreName { get; set; } = null!;

    public int UserId { get; set; }

    public string Description { get; set; } = null!;

    public bool IsApplicant { get; set; }

    public bool IsDeleted { get; set; }

    public int LocationId { get; set; }

    public byte[]? Image { get; set; }

    public byte[]? BusinessCertificate { get; set; }
	public int WorkingDays { get; set; }

	public TimeOnly StartTime { get; set; }

	public TimeOnly EndTime { get; set; }
	public decimal Rating { get; set; }
	public int? TotalRatings { get; set; }

	public double? RatingSum { get; set; }

	public string Address { get; set; }
    public byte[]? StoreCatalogue { get; set; }
    public DateTime? StoreCataloguePublish { get; set; }


    public virtual Location Location { get; set; } = null!;

    public virtual ICollection<Message> Messages { get; set; } = new List<Message>();

    public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();

    public virtual ICollection<Product> Products { get; set; } = new List<Product>();

    public virtual User User { get; set; } = null!;
}
