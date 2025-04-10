using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Service
{
    public int ServiceId { get; set; }

    public string? ServiceName { get; set; }

    public byte[]? Image { get; set; }

    public byte[]? ImageThumb { get; set; }

    public virtual ICollection<CompanyService> CompanyServices { get; set; } = new List<CompanyService>();

    public virtual ICollection<FreelancerService> FreelancerServices { get; set; } = new List<FreelancerService>();
}
