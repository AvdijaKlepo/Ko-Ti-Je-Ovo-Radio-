using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class Job
{
    public int JobId { get; set; }

    public int UserId { get; set; }

    public TimeOnly? StartEstimate { get; set; }

    public TimeOnly? EndEstimate { get; set; }

    public decimal? PayEstimate { get; set; }

    public decimal? PayInvoice { get; set; }

    public DateTime JobDate { get; set; }

    public string JobDescription { get; set; } = null!;

    public byte[]? Image { get; set; }

    public string JobStatus { get; set; } = null!;

    public bool IsDeleted { get; set; }

    public int? FreelancerId { get; set; }

    public int? CompanyId { get; set; }

    public DateTime? DateFinished { get; set; }

    public string JobTitle { get; set; } = null!;

    public bool IsTenderFinalized { get; set; }

    public bool IsFreelancer { get; set; }

    public bool IsInvoiced { get; set; }

    public bool IsRated { get; set; }

    public bool IsDeletedWorker { get; set; }

    public bool IsEdited { get; set; }

    public bool IsApproved { get; set; }

    public string? RescheduleNote { get; set; }

    public virtual Company? Company { get; set; }

    public virtual ICollection<CompanyJobAssignment> CompanyJobAssignments { get; set; } = new List<CompanyJobAssignment>();

    public virtual Freelancer? Freelancer { get; set; }

    public virtual ICollection<JobsService> JobsServices { get; set; } = new List<JobsService>();

    public virtual ICollection<TenderBid> TenderBids { get; set; } = new List<TenderBid>();

    public virtual User User { get; set; } = null!;

    public virtual ICollection<UserRating> UserRatings { get; set; } = new List<UserRating>();
}
