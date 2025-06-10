using KoRadio.Model.SearchObject;
using KoRadio.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace KoRadio.API.Controllers
{
	[Route("api/[controller]")]
	[ApiController]
	public class BaseCRUDController<TModel,TSearch,TInsert,TUpdate> : BaseController<TModel,TSearch>  where TSearch:BaseSearchObject where TModel:class
	{
		public BaseCRUDController(ICRUDService<TModel, TSearch,TInsert,TUpdate> service) : base(service)
		{
		}

		[HttpPost]
		public TModel Insert([FromBody]TInsert request)
		{
			return (_service as ICRUDService<TModel, TSearch, TInsert, TUpdate>).Insert(request);
		}
		[HttpPut("{id}")]
		public TModel Update(int id,TUpdate request)
		{
			return (_service as ICRUDService<TModel, TSearch, TInsert, TUpdate>).Update(id,request);
		}
		[HttpPatch("{id")]
		public TModel Patch(int id, TUpdate request)
		{
			return (_service as ICRUDService<TModel, TSearch, TInsert, TUpdate>).Update(id, request);

		}
	}
}
