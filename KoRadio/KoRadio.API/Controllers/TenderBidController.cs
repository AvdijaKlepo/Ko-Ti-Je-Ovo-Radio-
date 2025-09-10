using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace KoRadio.API.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class TenderBidController : BaseCRUDControllerAsync<Model.TenderBid, Model.SearchObject.TenderBidSearchObject, Model.Request.TenderBidInsertRequest, Model.Request.TenderBidUpdateRequest>
	{
		public TenderBidController(Services.Interfaces.ITenderBidService service) : base(service)
		{
		}
     
    
    }
}
