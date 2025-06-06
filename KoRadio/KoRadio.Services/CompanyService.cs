using KoRadio.Model.Enums;
using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services
{
    public class CompanyService: BaseCRUDServiceAsync<Model.Company, CompanySearchObject,Database.Company, CompanyInsertRequest, CompanyUpdateRequest>, ICompanyService
	{
         public CompanyService(KoTiJeOvoRadioContext context, IMapper mapper) : base(context, mapper)
		{

		}

		public override IQueryable<Company> AddFilter(CompanySearchObject search, IQueryable<Company> query)
		{
			return base.AddFilter(search, query);
		}

		public override async Task BeforeInsertAsync(CompanyInsertRequest request, Company entity, CancellationToken cancellationToken = default)
		{
			if (request.ServiceId != null && request.ServiceId.Any())
			{

				var services = _context.Services
					.Where(s => request.ServiceId.Contains(s.ServiceId))
					.ToList();


				entity.CompanyServices = services.Select(service => new Database.CompanyService
				{
					ServiceId = service.ServiceId,
					Company = entity
				}).ToList();
			}

			if (request.WorkingDays != null)
			{
				var workingDaysEnum = request.WorkingDays
					.Aggregate(WorkingDaysFlags.None, (acc, day) => acc | (WorkingDaysFlags)(1 << (int)day));

				entity.WorkingDays = (int)workingDaysEnum;

			}
			await base.BeforeInsertAsync(request, entity, cancellationToken);
		}


		public override async Task BeforeGetAsync(Model.Company request, Company entity)
		{
			var flags = (WorkingDaysFlags)entity.WorkingDays;
			request.WorkingDays = Enum.GetValues<DayOfWeek>()
				.Where(day => flags.HasFlag((WorkingDaysFlags)(1 << (int)day)))
				.ToList();
			await base.BeforeGetAsync(request, entity);
		}
		

	}
}
