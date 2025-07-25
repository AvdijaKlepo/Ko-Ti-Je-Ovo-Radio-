﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.Request
{
    public class ProductInsertRequest
    {
	

		public string ProductName { get; set; } = null!;

		public string ProductDescription { get; set; } = null!;

		public decimal Price { get; set; }

		public int StoreId { get; set; }
		public byte[]? Image { get; set; }

		public ICollection<int> ServiceId { get; set; } = new List<int>();
	




	}
}
