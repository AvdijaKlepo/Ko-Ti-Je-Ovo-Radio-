using KoRadio.Model;
using KoRadio.Model.Enums;
using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using KoRadio.Services.SignalRService;
using MapsterMapper;
using Microsoft.AspNetCore.SignalR;
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
		string signalRMessage = "Nova obavijest je stigla.";
		private readonly IHubContext<SignalRHubService> _hubContext;
		private readonly IMessageService _messageService;
		public CompanyService(KoTiJeOvoRadioContext context, IMapper mapper, IHubContext<SignalRHubService> hubContext, IMessageService messageService) : base(context, mapper)
		{
			_hubContext = hubContext;
			_messageService = messageService;
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
			var normalizedEmail = request.Email.ToLower();
			var existingEmail = await _context.Companies
				.AnyAsync(x => x.Email.ToLower() == normalizedEmail, cancellationToken);
			var existingUserEmail = await _context.Users.
				AnyAsync(x => x.Email.ToLower() == normalizedEmail);

			if (existingEmail || existingUserEmail)
			{
				throw new UserException("Email se koristi. Odaberite drugi.");
			}

			if(request.IsApplicant==true)
			{
				string notification;
				int adminId = 1;


				notification = $"Nova prijava za firmu Provjerite aplikante.";
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
			

			await base.BeforeInsertAsync(request, entity, cancellationToken);
		}
		public override async Task BeforeDeleteAsync(Database.Company entity, CancellationToken cancellationToken)
		{
			await _context.Entry(entity)
		.Collection(c => c.CompanyEmployees)
		.LoadAsync(cancellationToken);

		
			var employee = entity.CompanyEmployees.FirstOrDefault();
			if (employee != null)
			{
				var notification = "Vaša prijava za firmu je odbijena.";

				await _hubContext.Clients.User(employee.UserId.ToString())
					.SendAsync("ReceiveNotification", notification, cancellationToken);

				var insertRequest = new MessageInsertRequest
				{
					Message1 = notification,
					UserId = employee.UserId,
					CreatedAt = DateTime.Now,
					IsOpened = false
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);
			}

			await base.BeforeDeleteAsync(entity, cancellationToken);
		}
		public override async Task BeforeUpdateAsync(CompanyUpdateRequest request, Database.Company entity, CancellationToken cancellationToken = default)
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

			if (entity.IsApplicant == true && request.IsApplicant == false)
			{
				var companyAdminIds = _context.CompanyEmployees
					.Where(x => x.CompanyId == entity.CompanyId)
					.Select(x => x.UserId)
					.ToList();

				if (companyAdminIds.Any() && request.Roles != null && request.Roles.Any())
				{
				
					var existingUserRoles = _context.UserRoles
						.Where(ur => companyAdminIds.Contains(ur.UserId))
						.ToList();

					foreach (var userId in companyAdminIds)
					{
						var existingRoleIds = existingUserRoles
							.Where(ur => ur.UserId == userId)
							.Select(ur => ur.RoleId)
							.ToHashSet();

						foreach (var roleId in request.Roles.Distinct())
						{
							if (!existingRoleIds.Contains(roleId))
							{
								_context.UserRoles.Add(new Database.UserRole
								{
									UserId = userId,
									RoleId = roleId,
									ChangedAt = DateTime.Now,
									CreatedAt = DateTime.Now
								});
							}
						}
					}
					var messageContent = "Vaša prijava za firmu je odobrena, preuzmite desktop aplikaciju.";


					await _hubContext.Clients.User(companyAdminIds.ToString())
						.SendAsync("ReceiveNotification", messageContent, cancellationToken);


					var insertRequest = new MessageInsertRequest
					{
						Message1 = messageContent,
						
						UserId = companyAdminIds.First(),
						
						IsOpened = false,
						CreatedAt = DateTime.Now
					};

					await _messageService.InsertAsync(insertRequest, cancellationToken);

					Console.WriteLine("Notification sent and saved");
				}

				_context.SaveChanges();
			}

			if (request.Rating.HasValue && request.Rating.Value > 0)
			{
				entity.RatingSum += request.Rating.Value;
				entity.TotalRatings += 1;

				entity.Rating = entity.RatingSum / entity.TotalRatings;
			}

			var jobs = _context.Jobs.Where(x => x.CompanyId == entity.CompanyId
			&& x.JobStatus == "approved").Any();

			if (request.WorkingDays != null && request.WorkingDays.All(d => Enum.IsDefined(typeof(DayOfWeek), d)))
			{
				var requestedWorkingDaysFlags = request.WorkingDays
					.Aggregate(WorkingDaysFlags.None, (acc, day) => acc | (WorkingDaysFlags)(1 << (int)day));

				var currentWorkingDays = (WorkingDaysFlags)entity.WorkingDays;


				if (currentWorkingDays != requestedWorkingDaysFlags)
				{

					if (jobs)
					{
						throw new UserException("Ne mogu se uređivati firmini radni dani dok ima aktivne poslove!");
					}


					entity.WorkingDays = (int)requestedWorkingDaysFlags;
				}
			}
			else
			{
				entity.WorkingDays = (int)WorkingDaysFlags.None;
			}
			if (request.ServiceId != null && request.ServiceId.Any())
			{

				var existingServices = _context.CompanyServices
					.Where(fs => fs.CompanyId == entity.CompanyId);

				_context.CompanyServices.RemoveRange(existingServices);

				var services = _context.Services
					.Where(s => request.ServiceId.Contains(s.ServiceId))
					.ToList();
				if (existingServices != services)
				{
					if (jobs)
					{
						throw new UserException("Firma ne može uređivati servise dok ima aktivne poslove!");
					}
					entity.CompanyServices = services.Select(service => new Database.CompanyService
					{
						ServiceId = service.ServiceId,
						CompanyId = entity.CompanyId,
						CreatedAt = DateTime.Now,
					}).ToList();
				}


			}
			if(request.IsDeleted==true && entity.IsDeleted==false)
			{
				if(jobs)
				{
					throw new UserException("Firma ne može biti izbrisana dok ima aktivne poslove!");
				}
				
			}




			await base.BeforeUpdateAsync(request, entity, cancellationToken);
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
						DateJoined = DateTime.Now,
						IsOwner=true
						

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
