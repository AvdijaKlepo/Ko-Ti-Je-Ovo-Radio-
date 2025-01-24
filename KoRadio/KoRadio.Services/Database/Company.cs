using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Company
{
    public int CompanyId { get; set; }

    public string? CompanyName { get; set; }

    public string? Bio { get; set; }

    public virtual ICollection<CompanyWorker> CompanyWorkers { get; set; } = new List<CompanyWorker>();

    public virtual ICollection<Estimate> Estimates { get; set; } = new List<Estimate>();

    public virtual ICollection<Invoice> Invoices { get; set; } = new List<Invoice>();

    public virtual ICollection<JobAvailability> JobAvailabilities { get; set; } = new List<JobAvailability>();

    public virtual ICollection<Job> Jobs { get; set; } = new List<Job>();

    public virtual ICollection<Service> Services { get; set; } = new List<Service>();

    public virtual ICollection<User> Users { get; set; } = new List<User>();
}
