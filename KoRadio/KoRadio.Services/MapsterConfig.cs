using KoRadio.Model;
using KoRadio.Model.Enums;
using KoRadio.Model.Request;
using KoRadio.Services.Database;
using Mapster;

public class MapsterConfig
{
	public static void RegisterMappings()
	{
	
		TypeAdapterConfig<FreelancerInsertRequest, KoRadio.Services.Database.Freelancer>
			.NewConfig()
			.Ignore(dest => dest.WorkingDays);

		TypeAdapterConfig<FreelancerUpdateRequest, KoRadio.Services.Database.Freelancer>
			.NewConfig()
			.Ignore(dest => dest.WorkingDays);

	
		TypeAdapterConfig<KoRadio.Services.Database.Freelancer, KoRadio.Model.Freelancer>
			.NewConfig()
			.Map(dest => dest.WorkingDays,
				 src => Enum.GetValues<DayOfWeek>()
					 .Where(day => ((WorkingDaysFlags)src.WorkingDays).HasFlag((WorkingDaysFlags)(1 << (int)day)))
					 .ToList());
	}
}
