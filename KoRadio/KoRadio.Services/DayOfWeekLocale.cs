using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace KoRadio.Services
{
	public class DayOfWeekLocale:JsonConverter<DayOfWeek>
	{
		public override DayOfWeek Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
		=> throw new NotImplementedException(); // only needed for serialization

		public override void Write(Utf8JsonWriter writer, DayOfWeek value, JsonSerializerOptions options)
		{
			var str = value switch
			{
				DayOfWeek.Sunday => "Nedjelja",
				DayOfWeek.Monday => "Ponedjeljak",
				DayOfWeek.Tuesday => "Utorak",
				DayOfWeek.Wednesday => "Srijeda",
				DayOfWeek.Thursday => "Četvrtak",
				DayOfWeek.Friday => "Petak",
				DayOfWeek.Saturday => "Subota",
				_ => value.ToString()
			};
			writer.WriteStringValue(str);
		}
	}
}
