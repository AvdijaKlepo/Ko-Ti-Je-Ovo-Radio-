using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using KoRadio.Services.Database;
using KoRadio.Model;
using KoRadio.Model.SearchObject;
using MapsterMapper;
using KoRadio.Services.Interfaces;
using Mapster;
using Microsoft.EntityFrameworkCore;
using Worker = KoRadio.Services.Database.Worker;

namespace KoRadio.Services
{
	public class WorkerService:BaseService<Model.Worker,WorkerSearchObject,Database.Worker>,IWorkerService
	{
	

		public WorkerService(KoTiJeOvoRadioContext context,IMapper mapper)
		:base(context,mapper){ }

		public override IQueryable<Worker> AddFilter(WorkerSearchObject searchObject, IQueryable<Worker> query)
		{
			query = base.AddFilter(searchObject, query);
			if (!string.IsNullOrWhiteSpace(searchObject?.FirstNameGTE))
			{
				query = query.Where(x => x.User.FirstName.StartsWith(searchObject.FirstNameGTE));
			}

			if (!string.IsNullOrWhiteSpace(searchObject?.LastNameGTE))
			{
				query = query.Where(x => x.User.LastName.StartsWith(searchObject.LastNameGTE));
			}
			if (searchObject.isNameIncluded == true)
			{
				query = query.Include(x => x.User);
			}


			return query;
		}
	}
}
