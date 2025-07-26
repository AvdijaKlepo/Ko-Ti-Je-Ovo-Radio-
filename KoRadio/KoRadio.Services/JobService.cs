using Azure.Messaging;
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
using Org.BouncyCastle.Asn1.Ocsp;
using Subscriber;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

namespace KoRadio.Services
{
    public class JobService:BaseCRUDServiceAsync<Model.Job, JobSearchObject, Database.Job, JobInsertRequest, JobUpdateRequest>, IJobService
	{	
		string signalRMessage = "Nova obavijest je stigla. Provjerite sekciju poslovi.";
		private readonly IRabbitMQService _rabbitMQService;
		private readonly IHubContext<SignalRHubService> _hubContext;
		private readonly IMessageService _messageService;
		public JobService(KoTiJeOvoRadioContext context, IMapper mapper, IRabbitMQService rabbitMQService, IHubContext<SignalRHubService> hubContext, IMessageService messageService) : base(context, mapper)

		{
			_rabbitMQService = rabbitMQService;
			_hubContext = hubContext;
			_messageService = messageService;
		}

		public override IQueryable<Database.Job> AddFilter(JobSearchObject search, IQueryable<Database.Job> query)
		{
			query = base.AddFilter(search, query);
			query = query.Include(x=>x.JobsServices).ThenInclude(x => x.Service);
			query = query.Include(x => x.User);
			query = query.Include(x => x.Freelancer).ThenInclude(x => x.FreelancerNavigation).ThenInclude(x=>x.Location);
			query = query.Include(x => x.Freelancer).ThenInclude(x => x.FreelancerServices).ThenInclude(x=>x.Service);
			query = query.Include(x => x.Freelancer).ThenInclude(x => x.FreelancerNavigation).ThenInclude(x => x.UserRoles);
			query = query.Include(x => x.Company).ThenInclude(x => x.Location);
			query = query.Include(x => x.Company).ThenInclude(x => x.CompanyServices).ThenInclude(x => x.Service);
			


			if(search?.JobId!=null)
			{
				query = query.Where(x => x.JobId == search.JobId);
			}
			if (search?.FreelancerId != null)
			{
				query = query.Where(x => x.FreelancerId == search.FreelancerId);
			}
			if(search?.CompanyId!=null)
			{
				query = query.Where(x => x.CompanyId == search.CompanyId);
			}
			if (search?.UserId != null)
			{
				query = query.Where(x => x.UserId == search.UserId);

			}
			if (search?.JobDate != null)
			{
				query = query.Where(x => x.JobDate == search.JobDate);

			}
			if (search?.JobStatus=="unapproved")
			{
				query = query.Where(x => x.JobStatus == "unapproved");
			}
			if (search?.JobStatus == "approved")
			{
				query = query.Where(x => x.JobStatus == "approved");
			}
			if (search?.JobStatus == "finished")
			{
				query = query.Where(x => x.JobStatus == "finished");
			}
			if (search?.JobStatus == "cancelled")
			{
				query = query.Where(x => x.JobStatus == "cancelled");
			}
			if (search?.JobStatus == "inProgress")
			{
				query = query.Where(x => x.JobStatus == "inProgress");
			}
			if (search?.IsTenderFinalized != null)
			{
				query = query.Where(x => x.IsTenderFinalized == search.IsTenderFinalized);
			}

			if (search?.IsFreelancer != null)
			{
				query = query.Where(x => x.IsFreelancer == search.IsFreelancer);
			}
			if (search?.OrderBy == "asc")
			{
				query = query.OrderBy(x => x.JobDate).ThenBy(x=>x.JobId);
			}
			else if (search?.OrderBy == "desc")
			{
				query = query.OrderByDescending(x => x.JobDate).ThenBy(x => x.JobId);
			}

			return query;
			
		}
		public override async Task BeforeInsertAsync(JobInsertRequest request, Database.Job entity, CancellationToken cancellationToken = default)
		{
			if (request.ServiceId != null && request.ServiceId.Any())
			{

				var services = _context.Services
					.Where(s => request.ServiceId.Contains(s.ServiceId))
					.ToList();


				entity.JobsServices = services.Select(service => new Database.JobsService
				{
					ServiceId = service.ServiceId,
					Job = entity
				}).ToList();
			}

			


			await base.BeforeInsertAsync(request, entity, cancellationToken);

		}

		public override async Task AfterInsertAsync(JobInsertRequest request, Database.Job entity, CancellationToken cancellationToken = default)
		{
			string notification;
			
			
			notification = $"Novi zahtjev za posao od korisnika {entity.User.FirstName} {entity.User.LastName}.";

			if(entity.FreelancerId!=null && entity.CompanyId==null)
			{
				await _hubContext.Clients.User(entity.FreelancerId.ToString())
				.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);


				var insertRequest = new MessageInsertRequest
				{
					Message1 = notification,
					UserId = entity.FreelancerId,
					CreatedAt = DateTime.UtcNow,
					IsOpened = false
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);

				Console.WriteLine("Notification sent and saved: " + entity.Freelancer?.FreelancerNavigation.FirstName);
			}
			if(entity.CompanyId!=null && entity.FreelancerId==null)
			{
				await _hubContext.Clients.User(entity.CompanyId.ToString())
				.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);


				var insertRequest = new MessageInsertRequest
				{
					Message1 = notification,
					CompanyId = entity.CompanyId,
					CreatedAt = DateTime.UtcNow,
					IsOpened = false
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);

				Console.WriteLine("Notification sent and saved: " + entity.Company?.CompanyName);
			}

			
		

			await base.AfterInsertAsync(request, entity, cancellationToken);
		}

		public override async Task BeforeUpdateAsync(JobUpdateRequest request, Database.Job entity, CancellationToken cancellationToken = default)
		{
			_context.Jobs.Include(x => x.User);

			string notificationJobApprovedFreelancer = $"Zahtjev za posao od radnika {entity?.Freelancer?.FreelancerNavigation.FirstName}" +
					$" {entity.Freelancer?.FreelancerNavigation.LastName} je odobren.\nNjegovo trenutno stanje možete pregledati pod sekcijom odobrenih poslova.";
			string notificationJobApprovedCompany = $"Zahtjev za posao od firme {entity?.Company?.CompanyName} je odobren.\nNjegovo trenutno stanje možete pregledati pod sekcijom odobrenih poslova.";

			if(entity?.FreelancerId!=null && entity.CompanyId == null && entity.JobStatus == "unapproved" && request.JobStatus == "approved")
			{
				await _hubContext.Clients.User(entity.UserId.ToString())
					.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);
				var insertRequest = new MessageInsertRequest
				{
					Message1 = notificationJobApprovedFreelancer,
					UserId = entity.UserId,
					CreatedAt = DateTime.UtcNow,
					IsOpened = false
				};
				await _messageService.InsertAsync(insertRequest, cancellationToken);
				Console.WriteLine("Notification sent and saved: ");
			}
			if(entity?.FreelancerId == null && entity?.CompanyId != null && entity.JobStatus == "unapproved" && request.JobStatus == "approved")
			{
				await _hubContext.Clients.User(entity.UserId.ToString())
					.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);
				var insertRequest = new MessageInsertRequest
				{
					Message1 = notificationJobApprovedCompany,
					UserId = entity.UserId,
					CreatedAt = DateTime.UtcNow,
					IsOpened = false
				};
				await _messageService.InsertAsync(insertRequest, cancellationToken);
				Console.WriteLine("Notification sent and saved: ");
			}

			

			if (entity?.JobStatus == "approved" && request.JobStatus == "finished")
			{
				string messageContent;
				if (entity.FreelancerId != null && entity.CompanyId==null)
				{
					messageContent = $"Faktura poslana od radnika {entity?.Freelancer?.FreelancerNavigation.FirstName}" +
						$" {entity?.Freelancer?.FreelancerNavigation.LastName}.\nPlaćanje možete izvršiti odabirom navedenog posla iz sekcije završenih poslova.";
				}
				else
				{
					messageContent = $"Faktura poslana od firme {entity?.Company?.CompanyName}" +
						".\nPlaćanje možete izvršiti odabirom navedenog posla iz sekcije završenih poslova.";
				}

				await _hubContext.Clients.User(entity.UserId.ToString())
					.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);

				var insertRequest = new MessageInsertRequest
				{
					Message1 = messageContent,
					UserId = entity.UserId,
					CreatedAt = DateTime.UtcNow,
					IsOpened = false
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);

				Console.WriteLine("Notification sent and saved: " + entity.Freelancer?.FreelancerNavigation.FirstName);
			}


			if (entity?.FreelancerId != null && entity.CompanyId == null && request.JobStatus == "cancelled")
			{
				var messageContentCancelled = $"Posao ${entity.JobTitle} je otkazan.";

				await _hubContext.Clients.User(entity.UserId.ToString())
					.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);
				await _hubContext.Clients.User(entity.FreelancerId.ToString())
					.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);
				

				var insertRequest = new MessageInsertRequest
				{
					Message1 = messageContentCancelled,
					UserId = entity.UserId,
					CreatedAt = DateTime.UtcNow,
					IsOpened = false
				};
				var insertRequestFreelancer = new MessageInsertRequest
				{
					Message1 = messageContentCancelled,
					UserId = entity.FreelancerId,
					CreatedAt = DateTime.UtcNow,
					IsOpened = false
				};
			

				await _messageService.InsertAsync(insertRequest, cancellationToken);
				await _messageService.InsertAsync(insertRequestFreelancer, cancellationToken);
				

				Console.WriteLine("Notification sent and saved: " + entity.Freelancer?.FreelancerNavigation.FirstName);
			}
			if(entity.FreelancerId == null && entity?.CompanyId != null && request.JobStatus == "cancelled")
			{
				var messageContentCancelled = $"Posao ${entity.JobTitle} je otkazan.";

				await _hubContext.Clients.User(entity.UserId.ToString())
					.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);
			
				await _hubContext.Clients.User(entity.CompanyId.ToString())
					.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);

				var insertRequest = new MessageInsertRequest
				{
					Message1 = messageContentCancelled,
					UserId = entity.UserId,
					CreatedAt = DateTime.UtcNow,
					IsOpened = false
				};
				
				var insertRequestCompany = new MessageInsertRequest
				{
					Message1 = messageContentCancelled,
					CompanyId = entity.CompanyId,
					CreatedAt = DateTime.UtcNow,
					IsOpened = false
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);
				
				await _messageService.InsertAsync(insertRequestCompany, cancellationToken);

				Console.WriteLine("Notification sent and saved: " + entity?.Company?.CompanyName);
			}


			if (entity.FreelancerId != null && entity.CompanyId == null && request.IsInvoiced == true)
			{
				var messageContent = $"Korisnik {entity.User.FirstName} {entity.User.LastName} je izvršio uplatu.";

				await _hubContext.Clients.User(entity.FreelancerId.ToString())
					.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);

				var insertRequest = new MessageInsertRequest
				{
					Message1 = messageContent,
					UserId = entity.FreelancerId,
					CreatedAt = DateTime.UtcNow,
					IsOpened = false
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);

				Console.WriteLine("Notification sent and saved: " + entity.Freelancer?.FreelancerNavigation.FirstName);
			}
			if (entity.FreelancerId == null && entity.CompanyId != null && request.IsInvoiced == true)
			{
				var messageContent = $"Korisnik {entity.User.FirstName} {entity.User.LastName} je izvršio uplatu.";

				await _hubContext.Clients.User(entity.FreelancerId.ToString())
					.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);

				var insertRequest = new MessageInsertRequest
				{
					Message1 = messageContent,
					CompanyId = entity.CompanyId,
					CreatedAt = DateTime.UtcNow,
					IsOpened = false
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);

				Console.WriteLine("Notification sent and saved: " + entity.Company?.CompanyName);
			}

			await base.BeforeUpdateAsync(request, entity, cancellationToken);
		}

		public override async Task AfterUpdateAsync(JobUpdateRequest request, Database.Job entity, CancellationToken cancellationToken = default)
		{
			var job = await _context.Jobs
				.Include(j => j.User)
				.FirstOrDefaultAsync(j => j.JobId == entity.JobId);
			




			//if (request.JobStatus == "approved" && entity.User != null)
			//{
			//	await _rabbitMQService.SendEmail(new Email
			//	{
			//		EmailTo = entity.User.Email,
			//		Message = $"Poštovani, posao zakazan za {entity.JobDate} je odobren od strane radnika " +
			//				  "Stanja posla možete pratiti kroz aplikaciju. Lijep Pozdrav.",
			//		ReceiverName = $"{entity.User.FirstName} {entity.User.FirstName}",
			//		Subject = "Rezervacija posla"
			//	});
			//}
			//if (request.JobStatus == "finished" && entity.User != null)
			//{
			//	await _rabbitMQService.SendEmail(new Email
			//	{
			//		EmailTo = entity.User.Email,
			//		Message = $"Poštovani, posao zakazan za {entity.JobDate} je odobren od strane radnika " +
			//				  "Stanja posla možete pratiti kroz aplikaciju. Lijep Pozdrav.",
			//		ReceiverName = $"{entity.User.FirstName} {entity.User.FirstName}",
			//		Subject = "Rezervacija posla"
			//	});
			//}

			await base.AfterUpdateAsync(request, entity, cancellationToken);
		}


	}


















}
