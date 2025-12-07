using KoRadio.Model;
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
    public class ServicesService:BaseCRUDServiceAsync<Model.Service, ServiceSearchObject, Database.Service, ServiceInsertRequest, ServiceUpdateRequest>,IServicesService
    {
        public ServicesService(KoTiJeOvoRadioContext context, IMapper mapper) : base(context, mapper)
		{
		}
		public override IQueryable<Database.Service> AddFilter(ServiceSearchObject searchObject, IQueryable<Database.Service> query)
		{


			query = base.AddFilter(searchObject, query);
			query = query.Include(x => x.FreelancerServices).ThenInclude(x => x.Freelancer).Include(x => x.CompanyServices).ThenInclude(x => x.Company);
			if (!string.IsNullOrWhiteSpace(searchObject?.ServiceName))
			{
				query = query.Where(x => x.ServiceName.StartsWith(searchObject.ServiceName));
			}
			
		

		








			return query;
		}
		public override async Task BeforeInsertAsync(ServiceInsertRequest request, Database.Service entity, CancellationToken cancellationToken = default)
		{
			var serviceExists = await _context.Services.AnyAsync(x => x.ServiceName == request.ServiceName, cancellationToken);
			if (serviceExists)
				throw new UserException("Servis već postoji");
			await base.BeforeInsertAsync(request, entity, cancellationToken);
		}
		public override async Task BeforeUpdateAsync(ServiceUpdateRequest request, Database.Service entity, CancellationToken cancellationToken = default)
		{
			var serviceExists = await _context.Services.AnyAsync(x => x.ServiceName == request.ServiceName, cancellationToken);
			if (serviceExists)
				throw new UserException("Servis već postoji");
			await base.BeforeUpdateAsync(request, entity, cancellationToken);
		}
		public override async Task BeforeDeleteAsync(Database.Service entity, CancellationToken cancellationToken)
		{
			var isUsedByFreelancer = await _context.FreelancerServices
		   .AnyAsync(fs => fs.ServiceId == entity.ServiceId, cancellationToken);

			var isUsedByCompany = await _context.CompanyServices
				.AnyAsync(c => c.ServiceId == entity.ServiceId, cancellationToken);

			var isUsedByJob = await _context.JobsServices
				.AnyAsync(c => c.ServiceId == entity.ServiceId, cancellationToken);

			var isUsedByProduct = await _context.ProductsServices
				.AnyAsync(c => c.ServiceId == entity.ServiceId, cancellationToken);

			if (isUsedByFreelancer ||  isUsedByCompany || isUsedByJob || isUsedByProduct)
			{
				throw new UserException("Ne možete izbrisati servisi koji se aktivno koristi od strane radnika ili firme, ili je dodijeljen poslu ili proizvodu.");
			}
			await  base.BeforeDeleteAsync(entity, cancellationToken);
		}

	
	}
}
