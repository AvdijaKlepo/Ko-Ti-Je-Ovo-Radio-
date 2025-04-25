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
			query = query.Include(x=>x.JobsServices).ThenInclude(x => x.Service);
			return base.AddFilter(search, query);
			
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
