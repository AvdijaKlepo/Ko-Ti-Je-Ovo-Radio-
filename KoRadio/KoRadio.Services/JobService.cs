using KoRadio.Services.Database;
using MapsterMapper;
using KoRadio.Model;
using KoRadio.Model.Request;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace KoRadio.Services
{
    public class JobService:BaseCRUDService<Model.Job, JobSearchObject, Database.Job, JobInsertRequest, JobUpdateRequest>, IJobService
	{
		public JobService(KoTiJeOvoRadioContext context, IMapper mapper) : base(context, mapper)
		{
		}
		public override IQueryable<Database.Job> AddFilter(JobSearchObject search, IQueryable<Database.Job> query)
		{
			query = query.Include(x => x.User);
			query = query.Include(x => x.Freelancer).ThenInclude(x=>x.User);


			return base.AddFilter(search, query);
		}
	}
 
}
