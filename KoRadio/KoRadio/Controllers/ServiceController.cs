using KoRadio.Model;
using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace KoRadio.API.Controllers
{
	[Route("[controller]")]
	[ApiController]
	public class ServiceController : BaseCRUDControllerAsync<Model.Service,ServiceSearchObject,ServiceInsertRequest,ServiceUpdateRequest>
	{
		

		public ServiceController(IServicesService service)
			: base(service)
		{
			
		}

		


		
	}
}
