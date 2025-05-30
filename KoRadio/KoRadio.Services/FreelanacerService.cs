using KoRadio.Model;
using KoRadio.Model.Enums;
using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using Mapster;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services
{
    public class FreelanacerService:BaseCRUDService<Model.Freelancer, FreelancerSearchObject, Database.Freelancer, FreelancerInsertRequest, FreelancerUpdateRequest>,IFreelanceService
    {
        public FreelanacerService(KoTiJeOvoRadioContext context, IMapper mapper) : base(context, mapper)
		{

			
		}
		public override IQueryable<Database.Freelancer> AddFilter(FreelancerSearchObject searchObject, IQueryable<Database.Freelancer> query)
		{
			query = base.AddFilter(searchObject, query);
		
			query = query.Include(x => x.User);
			query = query.Include(x => x.User.Location);
			if (!string.IsNullOrWhiteSpace(searchObject?.FirstNameGTE))
			{
				query = query.Where(x => x.User.FirstName.StartsWith(searchObject.FirstNameGTE));
			}

			if (!string.IsNullOrWhiteSpace(searchObject?.LastNameGTE))
			{
				query = query.Where(x => x.User.LastName.StartsWith(searchObject.LastNameGTE));
			}

			if (searchObject?.ExperianceYears !=null)
			{
				query = query.Where(x => x.ExperianceYears == searchObject.ExperianceYears);
			}
			if (searchObject.IsServiceIncluded == true)
			{
				query = query.Include(x => x.FreelancerServices).ThenInclude(x => x.Service);
			}
			if (searchObject.ServiceId!=null)
			{
				query = query.Where(x => x.FreelancerServices.Any(x => x.ServiceId == searchObject.ServiceId));
			}
			if (searchObject.LocationId!=null)
			{
				query = query.Where(x => x.User.Location.LocationId == searchObject.LocationId);

			}
		
			


			return query;
		}

	
		public override void BeforeInsert(FreelancerInsertRequest request, Database.Freelancer entity)
		{
				
			base.BeforeInsert(request, entity);
		

			if (request.ServiceId != null && request.ServiceId.Any())
			{

				var services = _context.Services
					.Where(s => request.ServiceId.Contains(s.ServiceId))
					.ToList();


				entity.FreelancerServices = services.Select(service => new Database.FreelancerService
				{
					ServiceId = service.ServiceId,
					Freelancer = entity
				}).ToList();
			}
		
			if (request.WorkingDays != null)
			{
				var workingDaysEnum = request.WorkingDays
					.Aggregate(WorkingDaysFlags.None, (acc, day) => acc | (WorkingDaysFlags)(1 << (int)day));

				entity.WorkingDays = (int)workingDaysEnum;

			}
			if (request.Roles != null && request.Roles.Any())
			{
				foreach (var roleId in request.Roles)
				{
					_context.UserRoles.Add(new Database.UserRole
					{
						UserId = entity.UserId,
						RoleId = roleId,
						ChangedAt = DateTime.UtcNow
					});
				}
				_context.SaveChanges();
			}

		}
		

		public override void BeforeUpdate(FreelancerUpdateRequest request, Database.Freelancer entity)
		{
			base.BeforeUpdate(request, entity);
			if (request.ServiceId != null && request.ServiceId.Any())
			{
				
				var services = _context.Services
					.Where(s => request.ServiceId.Contains(s.ServiceId))
					.ToList();

				
				entity.FreelancerServices = services.Select(service => new Database.FreelancerService
				{
					ServiceId = service.ServiceId,
					Freelancer = entity
				}).ToList();
			}
		}

		public override void BeforeGet(Model.Freelancer request, Database.Freelancer entity)
		{
			base.BeforeGet(request, entity);
			if (entity.WorkingDays.HasValue)
			{
				var flags = (WorkingDaysFlags)entity.WorkingDays.Value;
				request.WorkingDays = Enum.GetValues<DayOfWeek>()
					.Where(day => flags.HasFlag((WorkingDaysFlags)(1 << (int)day)))
					.ToList();
			}
			else
			{
				request.WorkingDays = new List<DayOfWeek>();
			}
		}
	}



	
}
