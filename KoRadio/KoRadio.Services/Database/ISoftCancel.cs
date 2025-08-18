using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Database
{
	internal interface ISoftCancel
	{
		public bool IsCancelled { get; set; }







		public void Undo()
		{
			IsCancelled = false;

		}
	}
}
