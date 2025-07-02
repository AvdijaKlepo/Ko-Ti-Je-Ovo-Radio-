using KoRadio.Model;
using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace KoRadio.API.Controllers
{
	[Route("[controller]")]
	[ApiController]
	public class StoreController : BaseCRUDControllerAsync<Model.Store, Model.SearchObject.StoreSearchObject, Model.Request.StoreInsertRequest, Model.Request.StoreUpdateRequest>
	{
		public StoreController(IStoreService service)
			: base(service)
		{
		}
	}
}
