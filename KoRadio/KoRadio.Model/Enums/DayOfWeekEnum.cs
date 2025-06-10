using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Model.Enums
{
	[Flags]
	public enum WorkingDaysFlags
	{
		None = 0,
		Nedjelja = 1 << (int)DayOfWeek.Sunday,     
		Ponedjeljak = 1 << (int)DayOfWeek.Monday,     
		Utorak = 1 << (int)DayOfWeek.Tuesday,   
		Srijeda = 1 << (int)DayOfWeek.Wednesday, 
		Četvrtak = 1 << (int)DayOfWeek.Thursday, 
		Petak = 1 << (int)DayOfWeek.Friday,     
		Subota = 1 << (int)DayOfWeek.Saturday  
	}
}
