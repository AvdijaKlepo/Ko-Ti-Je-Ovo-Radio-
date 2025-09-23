using KoRadio.Model;
using KoRadio.Model.Enums;
using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using KoRadio.Services.RabbitMQ;
using KoRadio.Services.SignalRService;
using MapsterMapper;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Subscriber;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services
{
	public class StoreService : BaseCRUDServiceAsync<Model.Store, Model.SearchObject.StoreSearchObject, Database.Store, Model.Request.StoreInsertRequest, Model.Request.StoreUpdateRequest>, IStoreService
	{
		string signalRMessage = "Nova obavijest je stigla.";
		private readonly IHubContext<SignalRHubService> _hubContext;
		private readonly IMessageService _messageService;
		private readonly IRabbitMQService _rabbitMQService;
		public StoreService(KoTiJeOvoRadioContext context, IMapper mapper, IHubContext<SignalRHubService> hubContext, IMessageService messageService, IRabbitMQService rabbitMQService) : base(context, mapper)
		{
			_hubContext = hubContext;
			_messageService = messageService;
			_rabbitMQService = rabbitMQService;

		}

		public override IQueryable<Database.Store> AddFilter(StoreSearchObject search, IQueryable<Database.Store> query)
		{
			query = query.Include(x => x.User);
			query = query.Include(x => x.Location);

			if (!string.IsNullOrWhiteSpace(search?.Name))
			{
				query = query.Where(x => x.StoreName.StartsWith(search.Name));
			}
			if(!string.IsNullOrWhiteSpace(search?.OwnerName))
			{
				query = query.Where(x => (x.User.FirstName + " " + x.User.LastName).StartsWith(search.OwnerName));
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
			if (search.LocationId!=null)
			{
				query = query.Where(x => x.LocationId == search.LocationId);
			}
			if (search.StoreId!=null)
			{
				query = query.Where(x => x.StoreId == search.StoreId);
			}
			return base.AddFilter(search, query);
		}
		public override async Task BeforeUpdateAsync(StoreUpdateRequest request, Database.Store entity, CancellationToken cancellationToken = default)
		{

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
				if (request.Roles != null && request.Roles.Any())
				{
					
					var existingRoleIds = _context.UserRoles
						.Where(ur => ur.UserId == entity.UserId)
						.Select(ur => ur.RoleId)
						.ToHashSet();

					foreach (var roleId in request.Roles.Distinct())
					{
						if (!existingRoleIds.Contains(roleId))
						{
							_context.UserRoles.Add(new Database.UserRole
							{
								UserId = entity.UserId,
								RoleId = roleId,
								ChangedAt = DateTime.Now,
								CreatedAt = DateTime.Now
							});
						}
					}

					_context.SaveChanges();
				}
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


			if (request.StoreCatalogue != null)
			{
			
				//if (entity.StoreCataloguePublish != null && entity.StoreCataloguePublish.Value.AddDays(5) > DateTime.Now)
				//{
				//	throw new UserException("Novi katalog se može objaviti tek nakon 5 dana od posljednjeg objavljenog kataloga.");
				//}

			
				entity.StoreCataloguePublish = DateTime.Now;

				var users = _context.Users.ToList();

				foreach (var user in users)
				{
					await _rabbitMQService.SendEmail(new Email
					{
						EmailTo = user.Email,
						ReceiverName = $"{user.FirstName} {user.LastName}",
						Subject = "Novi katalog",
						Message = $"Poštovani, u prilogu se nalazi najnoviji katalog od {entity.StoreName}.",
						PdfBytes = request.StoreCatalogue
					});
				}
			}


			await base.BeforeUpdateAsync(request, entity, cancellationToken);

			await base.BeforeUpdateAsync(request, entity, cancellationToken);
		}
		public override async Task BeforeInsertAsync(StoreInsertRequest request, Database.Store entity, CancellationToken cancellationToken = default)
		{
			

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

			if (request.IsApplicant == true)
			{
				string notification;
				int adminId = 1;


				notification = $"Nova prijava za trgovinu, provjerite aplikante.";
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
			if (request.IsApplicant == false)
			{
				string notification;
				notification = $"Vaša prijava za trgovinu je odobrena, preuzmite desktop aplikaciju.";
				await _hubContext.Clients.User(entity.UserId.ToString())
					.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);
				var insertRequest = new MessageInsertRequest
				{
					Message1 = notification,
					UserId = entity.UserId,
					CreatedAt = DateTime.Now,
					IsOpened = false
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);
			}
			await base.BeforeInsertAsync(request, entity, cancellationToken);
		}
		public override async Task BeforeDeleteAsync(Database.Store entity, CancellationToken cancellationToken)
		{
			string notification;



			notification = $"Vaša prijava za trgovinu je odbijena.";
			await _hubContext.Clients.User(entity.UserId.ToString())
			.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);


			var insertRequest = new MessageInsertRequest
			{
				Message1 = notification,
				UserId = entity.UserId,
				CreatedAt = DateTime.Now,
				IsOpened = false
			};

			await _messageService.InsertAsync(insertRequest, cancellationToken);
			await base.BeforeDeleteAsync(entity, cancellationToken);
		}

		public override async Task BeforeGetAsync(Model.Store request, Database.Store entity)
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
