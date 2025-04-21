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
		Sunday = 1 << (int)DayOfWeek.Sunday,     
		Monday = 1 << (int)DayOfWeek.Monday,     
		Tuesday = 1 << (int)DayOfWeek.Tuesday,   
		Wednesday = 1 << (int)DayOfWeek.Wednesday, 
		Thursday = 1 << (int)DayOfWeek.Thursday, 
		Friday = 1 << (int)DayOfWeek.Friday,     
		Saturday = 1 << (int)DayOfWeek.Saturday  
	}
}
