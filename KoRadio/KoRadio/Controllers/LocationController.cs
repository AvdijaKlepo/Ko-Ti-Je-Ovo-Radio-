using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using KoRadio.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using KoRadio.Model;

namespace KoRadio.API.Controllers
{
    [Route("[controller]")]
    [ApiController]

    
    public class LocationController : BaseCRUDControllerAsync<Model.Location, LocationSearchObject, LocationInsertRequest, LocationUpdateRequest>
	{

       
        public LocationController(ILocationService service)
            : base(service)
        {


		}

     

      
        [AllowAnonymous]
		public override Task<PagedResult<Location>> GetList([FromQuery] LocationSearchObject searchObject, CancellationToken cancellationToken = default)
		{
			return base.GetList(searchObject, cancellationToken);
		}



	}
}
