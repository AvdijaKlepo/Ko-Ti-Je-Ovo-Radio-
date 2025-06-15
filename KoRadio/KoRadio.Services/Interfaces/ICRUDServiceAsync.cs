using KoRadio.Model.SearchObject;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Interfaces
{
	public interface ICRUDServiceAsync<TModel, TSearch, TInsert, TUpdate> : IServiceAsync<TModel, TSearch> where TModel : class where TSearch : BaseSearchObject where TUpdate : class
	{
		Task<TModel> InsertAsync(TInsert request, CancellationToken cancellationToken = default);

		Task<TModel> UpdateAsync(int id, TUpdate request, CancellationToken cancellationToken = default);

		Task DeleteAsync(int id, CancellationToken cancellationToken = default);
	
	}
}
