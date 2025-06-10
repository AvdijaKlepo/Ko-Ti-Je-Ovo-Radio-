using KoRadio.Model;
using KoRadio.Model.Enums;
using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using KoRadio.Services.SignalRService;
using Mapster;
using MapsterMapper;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services
{
	public class FreelanacerService : BaseCRUDServiceAsync<Model.Freelancer, FreelancerSearchObject, Database.Freelancer, FreelancerInsertRequest, FreelancerUpdateRequest>, IFreelanceService
	{
		private readonly IHubContext<SignalRHubService> _hubContext;
		private readonly IMessageService _messageService;
		public FreelanacerService(KoTiJeOvoRadioContext context, IMapper mapper, IHubContext<SignalRHubService> hubContext, IMessageService messageService) : base(context, mapper)
		{

			_hubContext = hubContext;
			_messageService = messageService;


		}
		public override IQueryable<Database.Freelancer> AddFilter(FreelancerSearchObject searchObject, IQueryable<Database.Freelancer> query)
		{
			query = base.AddFilter(searchObject, query);

			query = query.Include(x => x.FreelancerNavigation);
			query = query.Include(x => x.FreelancerNavigation.Location);
			query = query.Include(x => x.FreelancerServices).ThenInclude(x=>x.Service);
		//	query = query.Where(x => x.IsApplicant == false);


			if (!string.IsNullOrWhiteSpace(searchObject?.FirstNameGTE))
			{
				query = query.Where(x => x.FreelancerNavigation.FirstName.StartsWith(searchObject.FirstNameGTE));
			}

			if (!string.IsNullOrWhiteSpace(searchObject?.LastNameGTE))
			{
				query = query.Where(x => x.FreelancerNavigation.LastName.StartsWith(searchObject.LastNameGTE));
			}

			if (searchObject?.ExperianceYears != null)
			{
				query = query.Where(x => x.ExperianceYears == searchObject.ExperianceYears);
			}
			if (searchObject.IsServiceIncluded == true)
			{
				query = query.Include(x => x.FreelancerServices).ThenInclude(x => x.Service);
			}
			if (searchObject.ServiceId != null)
			{
				query = query.Where(x => x.FreelancerServices.Any(x => x.ServiceId == searchObject.ServiceId));
			}
			if (searchObject.LocationId != null)
			{
				query = query.Where(x => x.FreelancerNavigation.Location.LocationId == searchObject.LocationId);

			}
			if (searchObject.IsApplicant==true)
			{
				query = query.Where(x => x.IsApplicant == true);
			}
			else
			{
				query = query.Where(x => x.IsApplicant == false);
			}





				return query;
		}

		public override async Task BeforeInsertAsync(FreelancerInsertRequest request, Database.Freelancer entity, CancellationToken cancellationToken = default)
		{
			if (request.ServiceId != null && request.ServiceId.Any())
			{
				var services = _context.Services
					.Where(s => request.ServiceId.Contains(s.ServiceId))
					.ToList();

				entity.FreelancerServices = services.Select(service => new Database.FreelancerService
				{
					ServiceId = service.ServiceId,
					Freelancer = entity,
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


			entity.FreelancerId = request.FreelancerId;

			if (request.Roles != null && request.Roles.Any())
			{
				foreach (var roleId in request.Roles)
				{
					_context.UserRoles.Add(new Database.UserRole
					{
						UserId = entity.FreelancerId,
						RoleId = roleId,
						ChangedAt = DateTime.UtcNow,
						CreatedAt = DateTime.UtcNow
					});
				}
				_context.SaveChanges();
			}

			await base.BeforeInsertAsync(request, entity, cancellationToken);
		}


		public override async Task BeforeUpdateAsync(FreelancerUpdateRequest request, Database.Freelancer entity, CancellationToken cancellationToken = default)
		{
			if (request.ServiceId != null && request.ServiceId.Any())
			{
				
				var existingServices = _context.FreelancerServices
					.Where(fs => fs.FreelancerId == entity.FreelancerId);

				_context.FreelancerServices.RemoveRange(existingServices);

				var services = _context.Services
					.Where(s => request.ServiceId.Contains(s.ServiceId))
					.ToList();

				entity.FreelancerServices = services.Select(service => new Database.FreelancerService
				{
					ServiceId = service.ServiceId,
					FreelancerId = entity.FreelancerId,
					CreatedAt = DateTime.UtcNow,
				}).ToList();
			}

			if (request.Roles != null && request.Roles.Any())
			{
				var existingRoles = _context.UserRoles
					.Where(ur => ur.UserId == entity.FreelancerId)
					.ToList();

				_context.UserRoles.RemoveRange(existingRoles);

				foreach (var roleId in request.Roles.Distinct()) 
				{
					_context.UserRoles.Add(new Database.UserRole
					{
						UserId = entity.FreelancerId,
						RoleId = roleId,
						ChangedAt = DateTime.UtcNow,
						CreatedAt = DateTime.UtcNow
					});
				}

				_context.SaveChanges();
			}
			if (request.Rating.HasValue && request.Rating.Value > 0)
			{
				entity.RatingSum ??= 0;
				entity.TotalRatings ??= 0;

				entity.RatingSum += (double)request.Rating.Value;
				entity.TotalRatings += 1;

				entity.Rating = (decimal)(entity.RatingSum / entity.TotalRatings);
			}

			var user = await _context.Users
				.Include(u => u.Freelancer)
				.FirstOrDefaultAsync(u => u.UserId == entity.FreelancerId, cancellationToken);

			if (request.IsApplicant == false)
			{
				var messageContent = "Freelancer status changed";

			
				await _hubContext.Clients.User(user.UserId.ToString())
					.SendAsync("ReceiveNotification", messageContent, cancellationToken);

			
				var insertRequest = new MessageInsertRequest
				{
					Message1 = messageContent,
					UserId = user.UserId
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);

				Console.WriteLine("Notification sent and saved: " + user.FirstName);
			}






			await base.BeforeUpdateAsync(request, entity, cancellationToken);
		}



		public override async Task BeforeGetAsync(Model.Freelancer request, Database.Freelancer entity)
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



	

