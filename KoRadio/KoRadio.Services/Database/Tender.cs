using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Tender
{
    public int TenderId { get; set; }

    public DateTime JobDate { get; set; }

    public string JobDescription { get; set; } = null!;

    public byte[]? Image { get; set; }

    public bool IsFinalized { get; set; }

    public int? UserId { get; set; }

    public int? FreelancerId { get; set; }

    public int? CompanyId { get; set; }

    public bool IsFreelancer { get; set; }

    public virtual Company? Company { get; set; }

    public virtual Freelancer? Freelancer { get; set; }

    public virtual ICollection<TenderService> TenderServices { get; set; } = new List<TenderService>();

    public virtual User? User { get; set; }
}
