using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services
{
	public class TenderBidService : BaseCRUDServiceAsync<Model.TenderBid, Model.SearchObject.TenderBidSearchObject, Database.TenderBid, Model.Request.TenderBidInsertRequest, Model.Request.TenderBidUpdateRequest>, Interfaces.ITenderBidService
	{
		public TenderBidService(KoTiJeOvoRadioContext context, IMapper mapper) : base(context, mapper)
		{
		}

		public override IQueryable<TenderBid> AddFilter(TenderBidSearchObject search, IQueryable<TenderBid> query)
		{
			query = query.Include(x => x.Freelancer).ThenInclude(x=>x.FreelancerNavigation);
			query = query.Include(x => x.Job).ThenInclude(x => x.JobsServices).ThenInclude(x=>x.Service);
			if(search.TenderId!=null)
			{
				query = query.Where(x => x.JobId == search.TenderId);
			}
			return base.AddFilter(search, query);
		}

		public override async Task AfterInsertAsync(TenderBidInsertRequest request, TenderBid entity, CancellationToken cancellationToken = default)
		{
			await _context.Entry(entity)
		.Reference(x => x.Freelancer)
		.Query()
		.Include(f => f.FreelancerNavigation)
		.LoadAsync(cancellationToken);

			await _context.Entry(entity)
				.Reference(x => x.Job)
				.Query()
				.Include(j => j.JobsServices)
				.ThenInclude(js => js.Service)
				.LoadAsync(cancellationToken);
		}
	}
}
