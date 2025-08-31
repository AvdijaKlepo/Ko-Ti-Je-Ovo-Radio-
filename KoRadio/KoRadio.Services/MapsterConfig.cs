using KoRadio.Model;
using KoRadio.Model.Enums;
using KoRadio.Model.Request;
using KoRadio.Services.Database;
using Mapster;
using static Org.BouncyCastle.Math.EC.ECCurve;

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


		TypeAdapterConfig<CompanyInsertRequest, KoRadio.Services.Database.Company>
			.NewConfig()
			.Ignore(dest => dest.WorkingDays);

		TypeAdapterConfig<CompanyUpdateRequest, KoRadio.Services.Database.Company>
			.NewConfig()
			.Ignore(dest => dest.WorkingDays);


		TypeAdapterConfig<KoRadio.Services.Database.Company, KoRadio.Model.Company>
			.NewConfig()
			.Map(dest => dest.WorkingDays,
				 src => Enum.GetValues<DayOfWeek>()
					 .Where(day => ((WorkingDaysFlags)src.WorkingDays).HasFlag((WorkingDaysFlags)(1 << (int)day)))
					 .ToList());

		TypeAdapterConfig<StoreInsertRequest, KoRadio.Services.Database.Store>
			.NewConfig()
			.Ignore(dest => dest.WorkingDays);

		TypeAdapterConfig<StoreUpdateRequest, KoRadio.Services.Database.Store>
			.NewConfig()
			.Ignore(dest => dest.WorkingDays);


		TypeAdapterConfig<KoRadio.Services.Database.Store, KoRadio.Model.Store>
			.NewConfig()
			.Map(dest => dest.WorkingDays,
				 src => Enum.GetValues<DayOfWeek>()
					 .Where(day => ((WorkingDaysFlags)src.WorkingDays).HasFlag((WorkingDaysFlags)(1 << (int)day)))
					 .ToList());



		//	TypeAdapterConfig<KoRadio.Services.Database.User, KoRadio.Model.User>
		//.NewConfig()
		//.Map(dest => dest.CompanyEmployees,
		//	 src => src.CompanyEmployees.Adapt<List<KoRadio.Model.DTOs.CompanyEmployeeDto>>());

		//		TypeAdapterConfig<KoRadio.Services.Database.CompanyEmployee, KoRadio.Model.CompanyEmployee>
		//	.NewConfig();


		TypeAdapterConfig<KoRadio.Services.Database.CompanyEmployee, KoRadio.Model.DTOs.CompanyEmployeeDto>
			.NewConfig()
			.Map(dest => dest.CompanyName, src => src.Company.CompanyName);

		TypeAdapterConfig<KoRadio.Services.Database.Service, KoRadio.Model.Service>.NewConfig()
	.Map(dest => dest.FreelancerCount, src => src.FreelancerCount)
	.Map(dest => dest.CompanyCount, src => src.CompanyCount);















	}
}
