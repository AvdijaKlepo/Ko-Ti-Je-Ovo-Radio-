using KoRadio.Model.Enums;
using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using KoRadio.Services.RabbitMQ;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Subscriber;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services
{
    public class JobService:BaseCRUDServiceAsync<Model.Job, JobSearchObject, Database.Job, JobInsertRequest, JobUpdateRequest>, IJobService
	{
		private readonly IRabbitMQService _rabbitMQService;
		public JobService(KoTiJeOvoRadioContext context, IMapper mapper, IRabbitMQService rabbitMQService) : base(context, mapper)
		{
			_rabbitMQService = rabbitMQService;
		}

		public override IQueryable<Job> AddFilter(JobSearchObject search, IQueryable<Job> query)
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

			return query;
			
		}
		public override async Task BeforeInsertAsync(JobInsertRequest request, Job entity, CancellationToken cancellationToken = default)
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

		public override async Task BeforeUpdateAsync(JobUpdateRequest request, Job entity, CancellationToken cancellationToken = default)
		{
		
			await base.BeforeUpdateAsync(request, entity, cancellationToken);
		}

		public override async Task AfterUpdateAsync(JobUpdateRequest request, Job entity, CancellationToken cancellationToken = default)
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
