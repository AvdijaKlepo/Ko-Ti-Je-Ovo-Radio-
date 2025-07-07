using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Service
{
    public int ServiceId { get; set; }

    public string ServiceName { get; set; } = null!;

    public byte[] Image { get; set; } = null!;

    public bool IsDeleted { get; set; }

    public virtual ICollection<CompanyService> CompanyServices { get; set; } = new List<CompanyService>();

    public virtual ICollection<FreelancerService> FreelancerServices { get; set; } = new List<FreelancerService>();

    public virtual ICollection<JobsService> JobsServices { get; set; } = new List<JobsService>();

    public virtual ICollection<ProductsService> ProductsServices { get; set; } = new List<ProductsService>();

    public virtual ICollection<TenderService> TenderServices { get; set; } = new List<TenderService>();
}
