using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class User
{
    public int UserId { get; set; }

    public string? FirstName { get; set; }

    public string? LastName { get; set; }

    public string? Email { get; set; }

    public string? PasswordHash { get; set; }

    public string? PasswordSalt { get; set; }

    public DateTime? CreatedAt { get; set; }

    public byte[]? Image { get; set; }

    public virtual ICollection<CompanyEmployee> CompanyEmployees { get; set; } = new List<CompanyEmployee>();

    public virtual ICollection<Freelancer> Freelancers { get; set; } = new List<Freelancer>();
    public virtual ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();

}
