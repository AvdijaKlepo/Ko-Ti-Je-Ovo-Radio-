using KoRadio.Model.SearchObject;
using KoRadio.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace KoRadio.API.Controllers
{
	[Route("api/[controller]")]
	[ApiController]
	[Authorize]

	public class BaseCRUDControllerAsync<TModel, TSearch, TInsert, TUpdate> : BaseControllerAsync<TModel, TSearch> where TSearch : BaseSearchObject where TModel : class
	{
		protected new ICRUDServiceAsync<TModel, TSearch, TInsert, TUpdate> _service;

		public BaseCRUDControllerAsync(ICRUDServiceAsync<TModel, TSearch, TInsert, TUpdate> service) : base(service)
		{
			_service = service;
		}
		[HttpPost]
		public virtual Task<TModel> Insert(TInsert request, CancellationToken cancellationToken = default)
		{
			return _service.InsertAsync(request, cancellationToken);
		}

		[HttpPut("{id}")]
		public virtual Task<TModel> Update(int id, TUpdate request, CancellationToken cancellationToken = default)
		{
			return _service.UpdateAsync(id, request, cancellationToken);
		}

		[HttpDelete("{id}")]
		public virtual Task Delete(int id, CancellationToken cancellationToken = default)
		{
			return _service.DeleteAsync(id, cancellationToken);
		}

	}
}
