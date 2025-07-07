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
	public class ProductService : BaseCRUDServiceAsync<Model.Product, Model.SearchObject.ProductSearchObject, Database.Product, Model.Request.ProductInsertRequest, Model.Request.ProductUpdateRequest>, IProductService
	{
		public ProductService(KoTiJeOvoRadioContext context, IMapper mapper) : base(context, mapper)
		{
		}
		public override IQueryable<Product> AddFilter(ProductSearchObject search, IQueryable<Product> query)
		{
			
			query = query.Include(x => x.ProductsServices).ThenInclude(x => x.Service);
			if (!string.IsNullOrWhiteSpace(search?.Name))
			{
				query = query.Where(x => x.ProductName.StartsWith(search.Name));
			}
			if (search.IsDeleted==true)
			{
				query = query.Where(x => x.IsDeleted == true);
			}
			else
			{
				query = query.Where(x => x.IsDeleted == false);
			}
			if (search.StoreId!=null)
			{
				query = query.Where(x => x.StoreId == search.StoreId);
			}
			if (search.ServiceId != null)
			{
				query = query.Where(product => product.ProductsServices.Any(ps => ps.ServiceId == search.ServiceId));
			}


			return base.AddFilter(search, query);
		}
		public override async Task BeforeInsertAsync(ProductInsertRequest request, Product entity, CancellationToken cancellationToken = default)
		{
			if (request.ServiceId != null && request.ServiceId.Any())
			{
				var services = _context.Services
					.Where(s => request.ServiceId.Contains(s.ServiceId))
					.ToList();

				entity.ProductsServices = services.Select(service => new Database.ProductsService
				{
					ServiceId = service.ServiceId,
					Product = entity,
					CreatedAt = DateTime.UtcNow
				}).ToList();
			}
			await base.BeforeInsertAsync(request, entity, cancellationToken);
		}
	}
}
