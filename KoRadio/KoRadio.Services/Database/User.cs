using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class User
{
    public int UserId { get; set; }

    public string FirstName { get; set; } = null!;

    public string LastName { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string PasswordHash { get; set; } = null!;

    public string PasswordSalt { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public byte[]? Image { get; set; }

    public int LocationId { get; set; }

    public bool IsDeleted { get; set; }

    public string PhoneNumber { get; set; } = null!;

    public string Address { get; set; } = null!;

    public virtual ICollection<CompanyEmployee> CompanyEmployees { get; set; } = new List<CompanyEmployee>();

    public virtual Freelancer? Freelancer { get; set; }

    public virtual ICollection<Job> Jobs { get; set; } = new List<Job>();

    public virtual Location Location { get; set; } = null!;

    public virtual ICollection<Message> Messages { get; set; } = new List<Message>();

    public virtual ICollection<Order> Orders { get; set; } = new List<Order>();

    public virtual ICollection<Store> Stores { get; set; } = new List<Store>();

    public virtual ICollection<UserRating> UserRatings { get; set; } = new List<UserRating>();

    public virtual ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
}
