using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class UserRating
{
    public int UserRatingId { get; set; }

    public int? UserId { get; set; }

    public int? FreelancerId { get; set; }

    public decimal Rating { get; set; }

    public int? JobId { get; set; }

    public int? CompanyId { get; set; }

    public virtual Company? Company { get; set; }

    public virtual Freelancer? Freelancer { get; set; }

    public virtual Job? Job { get; set; }

    public virtual User? User { get; set; }
}
