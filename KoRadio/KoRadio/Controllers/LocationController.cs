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

        [HttpGet("LocationRegistration")]
        [AllowAnonymous]
		public Task<PagedResult<Location>> GetForRegistration([FromQuery]LocationSearchObject locationSearchObject)
        {
			return (_service as ILocationService).GetForRegistration(locationSearchObject);
		}



	}
}
