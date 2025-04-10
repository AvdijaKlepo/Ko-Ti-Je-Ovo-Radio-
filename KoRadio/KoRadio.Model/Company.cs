using System;
using System.Collections.Generic;

namespace KoRadio.Model
{



    public partial class Company
    {
        public int CompanyId { get; set; }

        public string? Bio { get; set; }

        public decimal? Rating { get; set; }

        public string? Location { get; set; }

        public string? PhoneNumber { get; set; }

        public int? ExperianceYears { get; set; }

        public string? Availability { get; set; }

        public virtual ICollection<Service> Services { get; set; } = new List<Service>();
    }
}
