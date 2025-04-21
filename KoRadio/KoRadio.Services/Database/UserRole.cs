using System;
using System.Collections.Generic;

namespace KoRadio.Services.Database;

public partial class UserRole
{
    public int UserRolesId { get; set; }

    public int? UserId { get; set; }

    public int? RoleId { get; set; }

    public DateTime? ChangedAt { get; set; }
    public User User { get; set; }
    public Role Role { get; set; }
}
