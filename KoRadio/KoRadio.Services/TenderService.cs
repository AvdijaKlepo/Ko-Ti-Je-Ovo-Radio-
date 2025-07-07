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
	public class TenderService : BaseCRUDServiceAsync<Model.Tender, Model.SearchObject.TenderSearchObject, Database.Tender, Model.Request.TenderInsertRequest, Model.Request.TenderUpdateRequest>, Interfaces.ITenderService
	{
		public TenderService(KoTiJeOvoRadioContext context, IMapper mapper) : base(context, mapper)
		{
		}

		public override IQueryable<Tender> AddFilter(TenderSearchObject search, IQueryable<Tender> query)
		{
			query = query.Include(x => x.User)
				.Include(x=>x.TenderServices)
				.ThenInclude(x=>x.Service);

			if(search.UserId!=null)
			{
				query = query.Where(x => x.UserId == search.UserId);
			}
			return base.AddFilter(search, query);
		}

		public override async Task BeforeInsertAsync(TenderInsertRequest request, Tender entity, CancellationToken cancellationToken = default)
		{
			if (request.ServiceId != null && request.ServiceId.Any())
			{
				var services = _context.Services
					.Where(s => request.ServiceId.Contains(s.ServiceId))
					.ToList();

				entity.TenderServices = services.Select(service => new Database.TenderService
				{
					ServiceId = service.ServiceId,
					Tender = entity,
					CreatedAt = DateTime.UtcNow
				}).ToList();
			}
			await base.BeforeInsertAsync(request, entity, cancellationToken);
		}
	}
}
