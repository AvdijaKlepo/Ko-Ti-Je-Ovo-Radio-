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
	
    public class LocationService:BaseCRUDServiceAsync<Model.Location, LocationSearchObject, Database.Location, LocationInsertRequest, LocationUpdateRequest>, ILocationService
	{
		
		public LocationService(KoTiJeOvoRadioContext context, IMapper mapper) : base(context, mapper)
		{
		}

		public override IQueryable<Database.Location> AddFilter(LocationSearchObject search, IQueryable<Database.Location> query)
		{
			if (!string.IsNullOrWhiteSpace(search?.LocationName))
			{
				query = query.Where(x => x.LocationName.StartsWith(search.LocationName));
			}
			return base.AddFilter(search, query);

		}
		public override async Task BeforeInsertAsync(LocationInsertRequest request, Database.Location entity, CancellationToken cancellationToken = default)
		{
			var locations =await _context.Locations.AnyAsync(x => x.LocationName == request.LocationName);
			if (locations)
				throw new UserException("Lokacija već postoji.");
			await base.BeforeInsertAsync(request, entity, cancellationToken);
		}

		public async Task<Model.PagedResult<Model.Location>> GetForRegistration(LocationSearchObject locationSearchObject)
		{
			List<Model.Location> result = new();
			var query = _context.Set<Database.Location>().AsQueryable();
			query = AddFilter(locationSearchObject, query);


			int count = query.Count();

			if (locationSearchObject?.Page.HasValue == true && locationSearchObject?.PageSize.HasValue == true)
			{
				query = query.Skip(locationSearchObject.Page.Value * locationSearchObject.PageSize.Value).Take(locationSearchObject.PageSize.Value);
			}


			var list = query.ToList();



			var resultList = Mapper.Map(list, result);
			for (int i = 0; i < resultList.Count; i++)
			{
				 BeforeGetAsync(resultList[i], list[i]);
			}
			Model.PagedResult<Model.Location> response = new();
			response.ResultList = resultList;
			response.Count = count;
			return response;
		}
	}
}
