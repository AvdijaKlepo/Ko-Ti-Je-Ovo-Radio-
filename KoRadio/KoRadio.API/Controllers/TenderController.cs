using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace KoRadio.API.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class TenderController : BaseCRUDControllerAsync<Model.Tender, Model.SearchObject.TenderSearchObject, Model.Request.TenderInsertRequest, Model.Request.TenderUpdateRequest>
	{
		public TenderController(Services.Interfaces.ITenderService service) : base(service)
		{
		}
	
	}
    
}
