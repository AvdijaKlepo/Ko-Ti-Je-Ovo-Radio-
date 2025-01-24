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

namespace KoRadio.Services
{
	public class WorkerService:IWorkerService
	{
		private readonly KoTiJeOvoRadioContext _context;
		public IMapper _mapper { get; set; }

		public WorkerService(KoTiJeOvoRadioContext context,IMapper mapper)
		{
			_context = context;
			_mapper = mapper;
		}
		public virtual List<WorkerModel> GetList(WorkerSearchObject searchObject)
		{
			List<WorkerModel> result = new List<WorkerModel>();
			var query = _context.Workers.Include(x=>x.User).AsQueryable();
			if (!string.IsNullOrWhiteSpace(searchObject?.FirstNameGTE))
			{
				query = query.Include(x => x.User).Where(x => x.User.FirstName.StartsWith(searchObject.FirstNameGTE));
			}
			if (!string.IsNullOrWhiteSpace(searchObject?.LastNameGTE))
			{
				query = query.Include(x => x.User).Where(x => x.User.LastName.StartsWith(searchObject.LastNameGTE));
			}

			var list = query.ToList();
			result = _mapper.Map(list, result);
			return result;
		}
	}
}
