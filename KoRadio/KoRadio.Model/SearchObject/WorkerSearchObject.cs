using System;
using System.Collections.Generic;
using System.Text;

namespace KoRadio.Model.SearchObject
{
	public class WorkerSearchObject:BaseSearchObject
	{
		public string? FirstNameGTE { get; set; }
		public string? LastNameGTE { get; set; }
		public bool? isNameIncluded { get; set; }


	}
}
