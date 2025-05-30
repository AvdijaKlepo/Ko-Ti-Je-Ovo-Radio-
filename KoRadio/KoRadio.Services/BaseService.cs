using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using KoRadio.Model;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace KoRadio.Services
{
	public abstract class BaseService<TModel,TSearch,TDbEntity> : IService<TModel, TSearch> where TSearch : BaseSearchObject where TDbEntity:class where TModel:class
	{
		protected readonly KoTiJeOvoRadioContext _context;
		protected readonly IMapper _mapper;

		public BaseService(KoTiJeOvoRadioContext context, IMapper mapper)
		{
			_context = context;
			_mapper = mapper;
		}

		
		public PagedResult<TModel> GetPaged(TSearch search)
		{
			List<TModel> result = new();
			var query = _context.Set<TDbEntity>().AsQueryable();
			query = AddFilter(search,query);


			int count = query.Count();

			if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
			{
				query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);
			}


			var list = query.ToList();
			


			var resultList = _mapper.Map(list, result);
			for (int i = 0; i < resultList.Count; i++)
			{
				BeforeGet(resultList[i], list[i]);
			}
			Model.PagedResult<TModel> response = new();
			response.ResultList = resultList;
			response.Count = count;
			return response;
		}

		public virtual IQueryable<TDbEntity> AddFilter(TSearch search, IQueryable<TDbEntity> query)
		{
			return query;
		}
		public TModel GetById(int id)
		{
			var query = _context.Set<TDbEntity>().Find(id);
			if (query ==null)
			{
				return null;
				
			}
				return _mapper.Map<TModel>(query);
			


		}
		public virtual void BeforeGet(TModel request,TDbEntity entity) { }
	}
}
