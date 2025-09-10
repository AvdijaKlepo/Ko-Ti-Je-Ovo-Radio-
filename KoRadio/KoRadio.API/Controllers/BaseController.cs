using KoRadio.Model.SearchObject;
using KoRadio.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace KoRadio.API.Controllers
{
	[Route("[controller]")]
	[ApiController]
	[Authorize]

	public class BaseController<TModel,TSearch> : ControllerBase  where TSearch:BaseSearchObject
	{
		protected readonly IService<TModel, TSearch> _service;

		public BaseController(IService<TModel, TSearch> service)
		{
			_service = service;
		}

		[HttpGet]
		public Model.PagedResult<TModel> GetList([FromQuery] TSearch searchObject)
		{
			return _service.GetPaged(searchObject);
		}

		[HttpGet("{id}")]
		public TModel GetById(int id)
		{
			return _service.GetById(id);
		}
	}
}
