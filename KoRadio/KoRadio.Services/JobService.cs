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
using Microsoft.EntityFrameworkCore.Storage;
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
	public class JobService : BaseCRUDServiceAsync<Model.Job, JobSearchObject, Database.Job, JobInsertRequest, JobUpdateRequest>, IJobService
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
			query = query
			.Include(x => x.JobsServices).ThenInclude(x => x.Service)
			.Include(x => x.User).ThenInclude(x => x.Location)
			.Include(x => x.Freelancer).ThenInclude(x => x.FreelancerNavigation).ThenInclude(x => x.Location)
			.Include(x => x.Freelancer).ThenInclude(x => x.FreelancerServices).ThenInclude(x => x.Service)
			.Include(x => x.Freelancer).ThenInclude(x => x.FreelancerNavigation).ThenInclude(x => x.UserRoles)
			.Include(x => x.Company).ThenInclude(x => x.Location)
			.Include(x => x.Company).ThenInclude(x => x.CompanyServices).ThenInclude(x => x.Service)
			.Include(x => x.Company).ThenInclude(x => x.CompanyEmployees)
			.Include(x => x.CompanyJobAssignments)
			.AsSplitQuery()
			.AsNoTracking();



			if (search?.JobId != null)
			{
				query = query.Where(x => x.JobId == search.JobId);
			}
			if (search?.FreelancerId != null)
			{
				query = query.Where(x => x.FreelancerId == search.FreelancerId);
			}
			if (search?.CompanyId != null)
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
			if (!string.IsNullOrEmpty(search?.JobStatus))
			{
				query = query.Where(x => x.JobStatus == search.JobStatus);
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
				query = query.OrderBy(x => x.JobDate).ThenBy(x => x.JobId);
			}
			else if (search?.OrderBy == "desc")
			{
				query = query.OrderByDescending(x => x.JobDate);
			}
			if (search?.IsDeleted == false)
			{
				query = query.Where(x => x.IsDeleted == false);
			}
			if (search?.IsDeletedWorker == false)
			{
				query = query.Where(x => x.IsDeletedWorker == false);
			}
			if (search?.CompanyEmployeeId != null)
			{
				query = query.Where(x => x.CompanyJobAssignments.Any(x => x.CompanyEmployeeId == search.CompanyEmployeeId));


			}
			if (search?.DateRange != null)
			{
				var chosenDate = search.DateRange.Value.Date;

				query = query.Where(j =>
					j.JobDate <= chosenDate &&
					(j.DateFinished ?? j.JobDate) >= chosenDate
				);
			}
			if (string.IsNullOrEmpty(search?.OrderBy))
			{
		
				query = query.OrderBy(x => x.JobId);
			}
			if (search?.JobService != null)
			{
				query = query.Where(x => x.JobsServices.Any(x => x.ServiceId == search.JobService));
			}
			if(!string.IsNullOrWhiteSpace(search.ClientName))
			{
				query = query.Where(x => (x.User.FirstName + " " + x.User.LastName).StartsWith(search.ClientName));
			}



			if (!string.IsNullOrWhiteSpace(search.EmployeeName))
			{
				query = query.Where(x =>
					x.CompanyJobAssignments != null &&
					x.CompanyJobAssignments.Any(a =>
						a.CompanyEmployee != null &&
						a.CompanyEmployee.User != null &&
						(a.CompanyEmployee.User.FirstName + " " + a.CompanyEmployee.User.LastName)
							.StartsWith(search.EmployeeName)
					)
				);
			}
			if(search.Location!=null)
			{
				query = query.Where(x => x.User.Location.LocationId == search.Location);
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


			var user = await _context.Users
	   .FirstOrDefaultAsync(u => u.UserId == entity.UserId, cancellationToken);


			if (entity.FreelancerId != null && entity.CompanyId == null && request.IsTenderFinalized == false)
			{
				await _hubContext.Clients.User(entity.FreelancerId.ToString())
				.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);
				notification = $"Novi zahtjev za posao od {user.FirstName} {user.LastName}";

				var insertRequest = new MessageInsertRequest
				{
					Message1 = notification,
					UserId = entity.FreelancerId,
					CreatedAt = DateTime.Now,
					IsOpened = false
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);

				Console.WriteLine("Notification sent and saved: " + entity.Freelancer?.FreelancerNavigation.FirstName);
			}
			if (entity.CompanyId != null && entity.FreelancerId == null && request.IsTenderFinalized == false)
			{
				await _hubContext.Clients.User(entity.CompanyId.ToString())
				.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);
				notification = $"Novi zahtjev za posao od korisnika {user.FirstName} {user.LastName}";

				var insertRequest = new MessageInsertRequest
				{
					Message1 = notification,
					CompanyId = entity.CompanyId,
					CreatedAt = DateTime.Now,
					IsOpened = false
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);

				Console.WriteLine("Notification sent and saved: " + entity.Company?.CompanyName);
			}




			await base.AfterInsertAsync(request, entity, cancellationToken);
		}


		public override async Task BeforeUpdateAsync(JobUpdateRequest request, Database.Job entity, CancellationToken cancellationToken = default)
		{
			var job = await _context.Jobs
	.Include(j => j.User)
	.Include(j => j.Freelancer).ThenInclude(f => f.FreelancerNavigation)
	.Include(j => j.Company)
	.FirstOrDefaultAsync(j => j.JobId == entity.JobId, cancellationToken);


			if (request.ServiceId != null && request.ServiceId.Any())
			{

				var existingServices = _context.JobsServices
					.Where(fs => fs.JobId == entity.JobId);

				_context.JobsServices.RemoveRange(existingServices);

				var services = _context.Services
					.Where(s => request.ServiceId.Contains(s.ServiceId))
					.ToList();

				entity.JobsServices = services.Select(service => new Database.JobsService
				{
					ServiceId = service.ServiceId,
					JobId = entity.JobId,
					CreatedAt = DateTime.Now,
				}).ToList();

			}

			_context.Jobs.Include(x => x.User);
		

			if(request.JobStatus=="approved" && entity.JobStatus=="unapproved")
			{
				entity.Pin = new Random().Next(100, 999);
			}
			if(request.JobStatus == "finished" && entity.JobStatus == "approved")
			{
				if(request.Pin!=entity.Pin)
				{
					throw new UserException("Pogrešan PIN. Molimo pokušajte ponovo.");
				}
			}



			if (entity?.FreelancerId != null && entity.CompanyId == null && entity.JobStatus == "unapproved" && request.JobStatus == "approved")
			{
				string notificationJobApprovedFreelancer = $"Zahtjev za posao kod radnika {job.Freelancer.FreelancerNavigation.FirstName}" +
					$" {job.Freelancer.FreelancerNavigation.LastName} je odobren.\nNjegovo trenutno stanje možete pregledati pod sekcijom odobrenih poslova.";
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
			if (entity?.FreelancerId == null && entity?.CompanyId != null && entity.JobStatus == "unapproved" && request.JobStatus == "approved")
			{
				string notificationJobApprovedCompany = $"Zahtjev za posao kod firme {job?.Company?.CompanyName} je odobren.\nNjegovo trenutno stanje možete pregledati pod sekcijom odobrenih poslova.";
				await _hubContext.Clients.User(entity.UserId.ToString())
					.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);
				var insertRequest = new MessageInsertRequest
				{
					Message1 = notificationJobApprovedCompany,
					UserId = entity.UserId,
					CreatedAt = DateTime.Now,
					IsOpened = false
				};
				await _messageService.InsertAsync(insertRequest, cancellationToken);
				Console.WriteLine("Notification sent and saved: ");
			}



			if (entity?.JobStatus == "approved" && request.JobStatus == "finished")
			{
				string messageContent;
				if (entity.FreelancerId != null && entity.CompanyId == null)
				{
					messageContent = $"Faktura poslana od radnika {job?.Freelancer?.FreelancerNavigation.FirstName}" +
						$" {job?.Freelancer?.FreelancerNavigation.LastName}.\nPlaćanje možete izvršiti odabirom navedenog posla iz sekcije završenih poslova.";
				}
				else
				{
					messageContent = $"Faktura poslana od firme {job?.Company?.CompanyName}" +
						".\nPlaćanje možete izvršiti odabirom navedenog posla iz sekcije završenih poslova.";
				}

				await _hubContext.Clients.User(entity.UserId.ToString())
					.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);

				var insertRequest = new MessageInsertRequest
				{
					Message1 = messageContent,
					UserId = entity.UserId,
					CreatedAt = DateTime.Now,
					IsOpened = false
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);

				Console.WriteLine("Notification sent and saved: " + entity.Freelancer?.FreelancerNavigation.FirstName);
			}





			if (entity.FreelancerId != null && entity.CompanyId == null && request.IsInvoiced == true && request.IsRated==false)
			{
				var messageContent = $"Korisnik {job.User.FirstName} {job.User.LastName} je izvršio uplatu.";

				await _hubContext.Clients.User(entity.FreelancerId.ToString())
					.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);

				var insertRequest = new MessageInsertRequest
				{
					Message1 = messageContent,
					UserId = entity.FreelancerId,
					CreatedAt = DateTime.Now,
					IsOpened = false
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);

				Console.WriteLine("Notification sent and saved: " + entity.Freelancer?.FreelancerNavigation.FirstName );
			}
			if (entity.FreelancerId == null && entity.CompanyId != null && request.IsInvoiced == true && request.IsRated == false)
			{
				var messageContent = $"Korisnik {job.User.FirstName} {job.User.LastName} je izvršio uplatu.";

				await _hubContext.Clients.User(entity.CompanyId.ToString())
					.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);

				var insertRequest = new MessageInsertRequest
				{
					Message1 = messageContent,
					CompanyId = entity.CompanyId,
					CreatedAt = DateTime.Now,
					IsOpened = false
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);

				Console.WriteLine("Notification sent and saved: " + entity.Company?.CompanyName);
			}
			if (entity.FreelancerId != null && entity.CompanyId == null && request.IsEdited == true)
			{
				var messageContent = $"Korisnik {job.User.FirstName} je uredio posao {job.JobTitle}. Pregledajte promjene.";
				await _hubContext.Clients.User(entity.FreelancerId.ToString())
					.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);
				var insertRequest = new MessageInsertRequest
				{
					Message1 = messageContent,
					UserId = entity.FreelancerId,
					CreatedAt = DateTime.Now,
					IsOpened = false
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);

			}
			if (entity.FreelancerId == null && entity.CompanyId != null && request.IsEdited == true)
			{
				var messageContent = $"Korisnik {job.User.FirstName} je uredio posao {job.JobTitle}. Pregledajte promjene.";
				await _hubContext.Clients.User(entity.CompanyId.ToString())
					.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);
				var insertRequest = new MessageInsertRequest
				{
					Message1 = messageContent,
					CompanyId = entity.CompanyId,
					CreatedAt = DateTime.Now,
					IsOpened = false
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);

			}
			if (entity.FreelancerId != null && entity.CompanyId == null && request.IsWorkerEdited == true)
			{
				var messageContent = $"Radnik {job.Freelancer.FreelancerNavigation.FirstName} {job.Freelancer.FreelancerNavigation.LastName} je uredio posao {job.JobTitle}. Pregledajte promjene.";
				await _hubContext.Clients.User(entity.UserId.ToString())
					.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);
				var insertRequest = new MessageInsertRequest
				{
					Message1 = messageContent,
					UserId = entity.UserId,
					CreatedAt = DateTime.Now,
					IsOpened = false
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);

			}
			if (entity.FreelancerId == null && entity.CompanyId != null && request.IsWorkerEdited == true)
			{
				var messageContent = $"Firma {job.Company.CompanyName} je uredila posao {job.JobTitle}. Pregledajte promjene.";
				await _hubContext.Clients.User(entity.UserId.ToString())
					.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);
				var insertRequest = new MessageInsertRequest
				{
					Message1 = messageContent,
					UserId = entity.UserId,
					CreatedAt = DateTime.Now,
					IsOpened = false
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);

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

		public override async Task BeforeDeleteAsync(Database.Job entity, CancellationToken cancellationToken)
		{
			if(entity.IsTenderFinalized==true)
			{
				var asignments = _context.CompanyJobAssignments.Where(x => x.JobId == entity.JobId).ToList();

				_context.RemoveRange(asignments);

				var bids = _context.TenderBids.Where(x => x.JobId == entity.JobId).ToList();

				_context.RemoveRange(bids);
			}
			await base.BeforeDeleteAsync(entity, cancellationToken);
		}


	}


















}