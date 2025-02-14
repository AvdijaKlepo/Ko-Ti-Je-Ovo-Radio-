using KoRadio.Model;
using KoRadio.Model.SearchObject;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using KoRadio.Services;
using KoRadio.Services.Interfaces;
using KoRadio.Services.Database;

namespace KoRadio.API.Controllers
{
	[Route("[controller]")]
	[ApiController]
	public class WorkerController : BaseController<Model.Worker,WorkerSearchObject>
	{


		public WorkerController(IWorkerService service)
		:base(service){
			
		}

	
	}
}
