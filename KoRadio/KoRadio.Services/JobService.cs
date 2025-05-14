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
    public class JobService:BaseCRUDService<Model.Job, JobSearchObject, Database.Job, JobInsertRequest, JobUpdateRequest>, IJobService
	{
		public JobService(KoTiJeOvoRadioContext context, IMapper mapper) : base(context, mapper)
		{
		}

		public override IQueryable<Job> AddFilter(JobSearchObject search, IQueryable<Job> query)
		{
			query = base.AddFilter(search, query);
			query = query.Include(x=>x.JobsServices).ThenInclude(x => x.Service);
			query = query.Include(x => x.User);
			query = query.Include(x => x.Freelancer).ThenInclude(x=>x.User);
			if (search?.FreelancerId != null)
			{
				query = query.Where(x => x.FreelancerId == search.FreelancerId);
			}
			if (search?.UserId != null)
			{
				query = query.Where(x => x.UserId == search.UserId);

			}
			if (search?.JobDate != null)
			{
				query = query.Where(x => x.JobDate == search.JobDate);

			}
			return query;
			
		}
		public override void BeforeInsert(JobInsertRequest request, Database.Job entity)
		{

			base.BeforeInsert(request, entity);


			if (request.ServiceId != null && request.ServiceId.Any())
			{

				var services = _context.Services
					.Where(s => request.ServiceId.Contains(s.ServiceId))
					.ToList();


				entity.JobsServices = services.Select(service => new Database.JobsService
				{
					ServiceId = service.ServiceId,
					Job= entity
				}).ToList();
			}

			

		}
	}
    
    

















}
