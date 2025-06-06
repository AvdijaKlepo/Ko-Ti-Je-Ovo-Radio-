using KoRadio.Model;
using KoRadio.Model.SearchObject;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Interfaces
{
	public interface IServiceAsync<TModel, TSearch> where TSearch : BaseSearchObject
	{
		public Task<PagedResult<TModel>> GetPagedAsync(TSearch search, CancellationToken cancellationToken = default);
		public Task<TModel> GetByIdAsync(int id, CancellationToken cancellationToken = default);
	}
}
