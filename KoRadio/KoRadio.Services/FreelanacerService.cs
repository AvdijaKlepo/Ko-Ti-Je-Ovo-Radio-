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
		string signalRMessage = "Nova obavijest je stigla.";
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
				query = query.Where(x => (x.FreelancerNavigation.FirstName + " " + x.FreelancerNavigation.LastName).StartsWith(searchObject.FirstNameGTE));
			}
			if(!string.IsNullOrWhiteSpace(searchObject?.Email))
			{
				query = query.Where(x => x.FreelancerNavigation.Email.StartsWith(searchObject.Email));
			}

			if (searchObject?.FreelancerId!=null)
			{
				query = query.Where(x => x.FreelancerId == searchObject.FreelancerId);
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
			if (searchObject.IsDeleted==true)
			{
				query = query.Where(x => x.IsDeleted == true);
			}
			else
			{
				query = query.Where(x => x.IsDeleted == false);
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
			
			if(request.IsApplicant==true)
			{
				string notification;
				int adminId = 1;


				notification = $"Nova prijava za radnika Provjerite aplikante.";
				await _hubContext.Clients.User(adminId.ToString())
				.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);


				var insertRequest = new MessageInsertRequest
				{
					Message1 = notification,
					UserId = adminId,
					CreatedAt = DateTime.Now,
					IsOpened = false
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);
			}
			if(request.IsApplicant==false)
			{
				string notification;
				notification = $"Vaša prijava za radnika je odobrena. Tokom slijedeće prijave možete pristupit radničkom profilu";
				await _hubContext.Clients.User(entity.FreelancerId.ToString())
					.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);
				var insertRequest = new MessageInsertRequest
				{
					Message1 = notification,
					UserId = entity.FreelancerId,
					CreatedAt = DateTime.Now,
					IsOpened = false
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);
			}
			var existingApplication = await _context.Freelancers
			.Where(f => f.FreelancerId == request.FreelancerId)
			.FirstOrDefaultAsync(cancellationToken);

			if (existingApplication != null)
			{
				throw new UserException("Već ste poslali prijavu za radnika.");
			}



			await base.BeforeInsertAsync(request, entity, cancellationToken);
		}

		public override async Task BeforeDeleteAsync(Database.Freelancer entity, CancellationToken cancellationToken)
		{
			string notification;
		


			notification = $"Vaša prijava radnička prijava je odbijena.";
			await _hubContext.Clients.User(entity.FreelancerId.ToString())
			.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);


			var insertRequest = new MessageInsertRequest
			{
				Message1 = notification,
				UserId = entity.FreelancerId,
				CreatedAt = DateTime.Now,
				IsOpened = false
			};

			await _messageService.InsertAsync(insertRequest, cancellationToken);
			await base.BeforeDeleteAsync(entity, cancellationToken);
		}
	


		public override async Task BeforeUpdateAsync(FreelancerUpdateRequest request, Database.Freelancer entity, CancellationToken cancellationToken = default)
		{
			
			var jobs = _context.Jobs.Any(x => x.FreelancerId == entity.FreelancerId
												   && x.JobStatus == "approved");

			if (request.ServiceId != null && request.ServiceId.Any())
			{
				
				var existingServices = _context.FreelancerServices
					.Where(fs => fs.FreelancerId == entity.FreelancerId);

				_context.FreelancerServices.RemoveRange(existingServices);

				var services = _context.Services
					.Where(s => request.ServiceId.Contains(s.ServiceId))
					.ToList();
				if(existingServices!=services)
				{
					if(jobs)
					{
						throw new UserException("Ne možete uređivati servise dok imate aktivne poslove!");
					}
					entity.FreelancerServices = services.Select(service => new Database.FreelancerService
					{
						ServiceId = service.ServiceId,
						FreelancerId = entity.FreelancerId,
						CreatedAt = DateTime.Now,
					}).ToList();
				}
				

			}
			if (request.isDeleted == true && entity.IsDeleted == false)
			{
				if(jobs)
					throw new UserException("Radnik ne može biti izbrisan dok ima aktivne poslove!");
			}

			if (request.WorkingDays != null && request.WorkingDays.All(d => Enum.IsDefined(typeof(DayOfWeek), d)))
			{
				var requestedWorkingDaysFlags = request.WorkingDays
					.Aggregate(WorkingDaysFlags.None, (acc, day) => acc | (WorkingDaysFlags)(1 << (int)day));

				var currentWorkingDays = (WorkingDaysFlags)entity.WorkingDays;

				
				if (currentWorkingDays != requestedWorkingDaysFlags)
				{
					
					if (jobs)
					{
						throw new UserException("Ne možete uređivati radne dane dok imate aktivne poslove!");
					}

				
					entity.WorkingDays = (int)requestedWorkingDaysFlags;
				}
			}
			else
			{
				entity.WorkingDays = (int)WorkingDaysFlags.None;
			}


			if (request.IsApplicant == false && entity.IsApplicant == true)
			{
				
				var existingRoleIds = _context.UserRoles
					.Where(ur => ur.UserId == entity.FreelancerId)
					.Select(ur => ur.RoleId)
					.ToHashSet();

				foreach (var roleId in request.Roles.Distinct())
				{
					
					if (!existingRoleIds.Contains(roleId))
					{
						_context.UserRoles.Add(new Database.UserRole
						{
							UserId = entity.FreelancerId,
							RoleId = roleId,
							ChangedAt = DateTime.Now,
							CreatedAt = DateTime.Now
						});
					}
				}
				var messageContent = "Vaša prijava za radnika je odobrena.";


				await _hubContext.Clients.User(entity.FreelancerId.ToString())
					.SendAsync("ReceiveNotification", messageContent, cancellationToken);


				var insertRequest = new MessageInsertRequest
				{
					Message1 = messageContent,
					UserId = entity.FreelancerId,
					IsOpened = false,
					CreatedAt=DateTime.Now
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);

				Console.WriteLine("Notification sent and saved");

				_context.SaveChanges();
			}

			if (request.Rating.HasValue && request.Rating.Value > 0)
			{
				entity.RatingSum ??= 0;
				entity.TotalRatings ??= 0;

				entity.RatingSum += (double)request.Rating.Value;
				entity.TotalRatings += 1;

				entity.Rating = (decimal)(entity.RatingSum / entity.TotalRatings);
				request.Rating = entity.Rating;
			}

			var user = await _context.Users
				.Include(u => u.Freelancer)
				.FirstOrDefaultAsync(u => u.UserId == entity.FreelancerId, cancellationToken);


		
				
				
			








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



	

