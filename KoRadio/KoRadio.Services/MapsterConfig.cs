using KoRadio.Model;
using KoRadio.Model.Request;
using KoRadio.Services.Database;
using Mapster;

public class MapsterConfig
{
    public static void RegisterMappings()
    {
		TypeAdapterConfig<FreelancerInsertRequest, KoRadio.Services.Database.Freelancer>.NewConfig()
	.Ignore(dest => dest.WorkingDays);  // Map manually in BeforeInsert

		TypeAdapterConfig<KoRadio.Services.Database.Freelancer, KoRadio.Model.Freelancer>.NewConfig()
			.Ignore(dest => dest.WorkingDays);
	}
}
