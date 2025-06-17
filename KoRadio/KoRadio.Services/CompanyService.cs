using KoRadio.Model.Enums;
using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
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
			query = query.Include(x => x.CompanyServices).ThenInclude(x => x.Service);
			query = query.Include(x => x.CompanyEmployees).ThenInclude(x=>x.User);
			query = query.Include(x => x.Location);

			if(search.IsApplicant==true)
			{
				query = query.Where(x => x.IsApplicant == true);
			}
			else
			{
				query = query.Where(x => x.IsApplicant == false);
			}
			if (search.IsDeleted == true)
			{
				query = query.Where(x => x.IsDeleted == true);
			}
			else
			{
				query = query.Where(x => x.IsDeleted == false);
			}
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
					Company = entity,
					CreatedAt = DateTime.UtcNow
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

		public override Task BeforeUpdateAsync(CompanyUpdateRequest request, Company entity, CancellationToken cancellationToken = default)
		{
			if (request.ServiceId != null && request.ServiceId.Any())
			{

				var existingServices = _context.CompanyServices
					.Where(fs => fs.CompanyId == entity.CompanyId);

				_context.CompanyServices.RemoveRange(existingServices);

				var services = _context.Services
					.Where(s => request.ServiceId.Contains(s.ServiceId))
					.ToList();

				entity.CompanyServices = services.Select(service => new Database.CompanyService
				{
					ServiceId = service.ServiceId,
					CompanyId = entity.CompanyId,
					CreatedAt = DateTime.UtcNow,
				}).ToList();
			}

			if (request.WorkingDays != null && request.WorkingDays.All(d => Enum.IsDefined(typeof(DayOfWeek), d)))
			{



				var workingDaysEnum = request.WorkingDays
					.Aggregate(WorkingDaysFlags.None, (acc, day) => acc | (WorkingDaysFlags)(1 << (int)day));
				entity.WorkingDays = (int)workingDaysEnum;
			}
			else
			{
				entity.WorkingDays = (int)WorkingDaysFlags.None;
			}
			return base.BeforeUpdateAsync(request, entity, cancellationToken);
		}

		public override Task AfterInsertAsync(CompanyInsertRequest request, Company entity, CancellationToken cancellationToken = default)
		{
			if (request.Employee != null && request.Employee.Any())
			{
				foreach (var userId in request.Employee)
				{
					_context.CompanyEmployees.Add(new Database.CompanyEmployee
					{
						CompanyId = entity.CompanyId,
						UserId = userId,
						IsDeleted = false,
						IsApplicant=false,
						DateJoined = DateTime.UtcNow,
						

					});
				}
				_context.SaveChanges();
			}
			return base.AfterInsertAsync(request, entity, cancellationToken);
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
