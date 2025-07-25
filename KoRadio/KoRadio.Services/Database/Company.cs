﻿using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Company
{
    public int CompanyId { get; set; }

    public string Bio { get; set; } = null!;

    public decimal? Rating { get; set; }

    public string PhoneNumber { get; set; } = null!;

    public int ExperianceYears { get; set; }

    public byte[]? Image { get; set; }

    public int WorkingDays { get; set; }

    public TimeOnly StartTime { get; set; }

    public TimeOnly EndTime { get; set; }

    public int LocationId { get; set; }

    public bool IsDeleted { get; set; }

    public bool IsApplicant { get; set; }

    public string CompanyName { get; set; } = null!;

    public string Email { get; set; } = null!;

    public int TotalRatings { get; set; }

    public decimal RatingSum { get; set; }

    public virtual ICollection<CompanyEmployee> CompanyEmployees { get; set; } = new List<CompanyEmployee>();

    public virtual ICollection<CompanyRole> CompanyRoles { get; set; } = new List<CompanyRole>();

    public virtual ICollection<CompanyService> CompanyServices { get; set; } = new List<CompanyService>();

    public virtual ICollection<Job> Jobs { get; set; } = new List<Job>();

    public virtual Location Location { get; set; } = null!;

    public virtual ICollection<Message> Messages { get; set; } = new List<Message>();

    public virtual ICollection<TenderBid> TenderBids { get; set; } = new List<TenderBid>();

    public virtual ICollection<Tender> Tenders { get; set; } = new List<Tender>();

    public virtual ICollection<UserRating> UserRatings { get; set; } = new List<UserRating>();
}
