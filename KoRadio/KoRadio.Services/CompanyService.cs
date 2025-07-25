﻿using KoRadio.Model;
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

		public override IQueryable<Database.Company> AddFilter(CompanySearchObject search, IQueryable<Database.Company> query)
		{
			query = query.Include(x => x.CompanyServices).ThenInclude(x => x.Service);
			query = query.Include(x => x.CompanyEmployees).ThenInclude(x=>x.User);
			query = query.Include(x => x.Location);

			if(search.CompanyId!=null)
			{
				query = query.Where(x => x.CompanyId == search.CompanyId);
			}
			if (!string.IsNullOrWhiteSpace(search?.CompanyName))
			{
				query = query.Where(x => x.CompanyName.StartsWith(search.CompanyName));
			}
			if (search.LocationId!=null)
			{
				query = query.Where(x => x.LocationId == search.LocationId.Value);
			}
			if (search.ServiceId != null)
			{
				query = query.Where(x => x.CompanyServices.Any(x => x.ServiceId == search.ServiceId));
			}

			if (search.IsApplicant==true)
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

	

		public override async Task BeforeInsertAsync(CompanyInsertRequest request, Database.Company entity, CancellationToken cancellationToken = default)
		{
			bool wasApplicant = entity.IsApplicant;

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
			await base.BeforeInsertAsync(request, entity, cancellationToken);
		}

		public override Task BeforeUpdateAsync(CompanyUpdateRequest request, Database.Company entity, CancellationToken cancellationToken = default)
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

			//if (entity.IsApplicant == true && request.IsApplicant == false)
			//{
			//	var companyAdminIds = _context.CompanyEmployees
			//		.Where(x => x.CompanyId == entity.CompanyId)
			//		.Select(x => x.UserId)
			//		.ToList();

			//	if (companyAdminIds.Any() && request.Roles != null && request.Roles.Any())
			//	{
			//		var existingRoles = _context.UserRoles
			//			.Where(ur => companyAdminIds.Contains(ur.UserId))
			//			.ToList();

			//		_context.UserRoles.RemoveRange(existingRoles);

			//		foreach (var userId in companyAdminIds)
			//		{
			//			foreach (var roleId in request.Roles)
			//			{
			//				_context.UserRoles.Add(new Database.UserRole
			//				{
			//					UserId = userId,
			//					RoleId = roleId,
			//					ChangedAt = DateTime.UtcNow,
			//					CreatedAt = DateTime.UtcNow
			//				});
			//			}
			//		}
			//	}

			//	_context.SaveChanges();
			//}
			if (request.Rating.HasValue && request.Rating.Value > 0)
			{
				entity.RatingSum += request.Rating.Value;
				entity.TotalRatings += 1;

				entity.Rating = entity.RatingSum / entity.TotalRatings;
			}




			return base.BeforeUpdateAsync(request, entity, cancellationToken);
		}

		public override Task AfterInsertAsync(CompanyInsertRequest request, Database.Company entity, CancellationToken cancellationToken = default)
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


		public override async Task BeforeGetAsync(Model.Company request, Database.Company entity)
		{



			var flags = (WorkingDaysFlags)entity.WorkingDays;

			request.WorkingDays = Enum.GetValues<WorkingDaysFlags>()
				.Where(flag => flag != WorkingDaysFlags.None && flags.HasFlag(flag))
				.Select(flag => (DayOfWeek)(int)Math.Log2((int)flag))
				.ToList();
			await base.BeforeGetAsync(request, entity);
		}
		

	}
}
