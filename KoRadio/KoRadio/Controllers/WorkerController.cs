using KoRadio.Model;
using KoRadio.Model.SearchObject;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using KoRadio.Services;
using KoRadio.Services.Interfaces;

namespace KoRadio.API.Controllers
{
	[Route("[controller]")]
	[ApiController]
	public class WorkerController : ControllerBase
	{
		protected readonly IWorkerService _service;

		public WorkerController(IWorkerService service)
		{
			_service = service;
		}

		[HttpGet]
		public List<WorkerModel> GetList([FromQuery]WorkerSearchObject searchObject)
		{
			return _service.GetList(searchObject);
		}
	}
}
