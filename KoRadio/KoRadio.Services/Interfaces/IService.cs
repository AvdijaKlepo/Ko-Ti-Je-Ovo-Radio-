using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using KoRadio.Model.SearchObject;

namespace KoRadio.Services.Interfaces
{
	public interface IService<TModel,TSearch> where TSearch : BaseSearchObject
	{
		public Model.PagedResult<TModel> GetPaged(TSearch search);
		public TModel GetById(int id);
	}
}
