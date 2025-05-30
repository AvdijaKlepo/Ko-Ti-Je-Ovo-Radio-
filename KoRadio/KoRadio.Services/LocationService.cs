using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services
{
	
    public class LocationService:BaseCRUDService<Model.Location, LocationSearchObject, Database.Location, LocationInsertRequest, LocationUpdateRequest>, ILocationService
	{
		
		public LocationService(KoTiJeOvoRadioContext context, IMapper mapper) : base(context, mapper)
		{
		}

		public override IQueryable<Location> AddFilter(LocationSearchObject search, IQueryable<Location> query)
		{
			return base.AddFilter(search, query);
		}

		public Model.PagedResult<Model.Location> GetForRegistration(LocationSearchObject locationSearchObject)
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



			var resultList = _mapper.Map(list, result);
			for (int i = 0; i < resultList.Count; i++)
			{
				BeforeGet(resultList[i], list[i]);
			}
			Model.PagedResult<Model.Location> response = new();
			response.ResultList = resultList;
			response.Count = count;
			return response;
		}
	}
}
