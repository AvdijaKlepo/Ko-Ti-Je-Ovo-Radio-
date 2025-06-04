using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using KoRadio.Model.SearchObject;

namespace KoRadio.Services.Interfaces
{
	public interface ICRUDService<TModel, TSearch,TInsert,TUpdate> : IService<TModel,TSearch> where TSearch:BaseSearchObject where TModel : class 
	{
		TModel Insert(TInsert insert);
		TModel Update(int id, TUpdate request);
	}
}
