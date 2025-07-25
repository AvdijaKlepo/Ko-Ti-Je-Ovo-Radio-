﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.Request
{
    public class TenderBidUpdateRequest
    {
		public int TenderId { get; set; }

		public int? FreelancerId { get; set; }

		public int? CompanyId { get; set; }

		public decimal BidAmount { get; set; }

		public string? BidDescription { get; set; }

		public DateTime DateFinished { get; set; }

		public DateTime CreatedAt { get; set; }

	
	}
}
