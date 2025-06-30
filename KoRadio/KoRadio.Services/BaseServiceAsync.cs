using KoRadio.Model.SearchObject;
using KoRadio.Model;
using KoRadio.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;
using KoRadio.Services.Database;

namespace KoRadio.Services
{
	public class BaseServiceAsync<TModel, TSearch, TDbEntity> : IServiceAsync<TModel, TSearch> where TSearch : BaseSearchObject where TDbEntity : class where TModel : class
	{
		public KoTiJeOvoRadioContext _context { get; }
		public IMapper Mapper { get; }

		public BaseServiceAsync(KoTiJeOvoRadioContext context, IMapper mapper)
		{
			_context = context;
			Mapper = mapper;
		}

		public async Task<PagedResult<TModel>> GetPagedAsync(TSearch search, CancellationToken cancellationToken = default)
		{
			List<TModel> result = new List<TModel>();

			var query = _context.Set<TDbEntity>().AsQueryable();

			if (!string.IsNullOrEmpty(search?.IncludeTables))
			{
				query = ApplyIncludes(query, search.IncludeTables);
			}


			query = AddFilter(search, query);

			int count = await query.CountAsync(cancellationToken);

			if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
			{
				query = query.Skip((search.Page.Value - 1) * search.PageSize.Value).Take(search.PageSize.Value);
			}

			if (!string.IsNullOrEmpty(search?.OrderBy) && !string.IsNullOrEmpty(search?.SortDirection))
			{
				query = ApplySorting(query, search.OrderBy, search.SortDirection);
			}

			var list = await query.ToListAsync(cancellationToken);

			for (int i = 0; i < list.Count; i++)
			{
				var entity = list[i];
				var (isHandled, custom) = await TryManualProjectionAsync(entity);

				if (isHandled && custom is not null)
				{
					result.Add(custom);
				}
				else
				{
					var mapped = Mapper.Map<TModel>(entity);
					await BeforeGetAsync(mapped, entity);
					result.Add(mapped);
				}
			}



			PagedResult<TModel> pagedResult = new PagedResult<TModel>();

			pagedResult.ResultList = result;
			pagedResult.Count = count;

			return pagedResult;
		}

		public IQueryable<TDbEntity> ApplySorting(IQueryable<TDbEntity> query, string sortColumn, string sortDirection)
		{
			var entityType = typeof(TDbEntity);
			var property = entityType.GetProperty(sortColumn);
			if (property != null)
			{
				var parameter = Expression.Parameter(entityType, "x");
				var propertyAccess = Expression.MakeMemberAccess(parameter, property);
				var orderByExpression = Expression.Lambda(propertyAccess, parameter);

				string methodName = "";

				var sortDirectionToLower = sortDirection.ToLower();

				methodName = sortDirectionToLower == "desc" || sortDirectionToLower == "descending" ? "OrderByDescending" :
					sortDirectionToLower == "asc" || sortDirectionToLower == "ascending" ? "OrderBy" : "";

				if (methodName == "")
				{
					return query;
				}

				var resultExpression = Expression.Call(typeof(Queryable), methodName,
													   new Type[] { entityType, property.PropertyType },
													   query.Expression, Expression.Quote(orderByExpression));

				return query.Provider.CreateQuery<TDbEntity>(resultExpression);
			}
			else
			{
				return query;
			}
		}

		private IQueryable<TDbEntity> ApplyIncludes(IQueryable<TDbEntity> query, string includes)
		{
			try
			{
				var tableIncludes = includes.Split(',');
				query = tableIncludes.Aggregate(query, (current, inc) => current.Include(inc));
			}
			catch (Exception)
			{
				throw new UserException("Pogrešna include lista!");
			}

			return query;
		}
		public virtual IQueryable<TDbEntity> AddFilter(TSearch search, IQueryable<TDbEntity> query)
		{
			return query;
		}
		public async Task<TModel> GetByIdAsync(int id, CancellationToken cancellationToken = default)
		{
			var entity = await _context.Set<TDbEntity>().FindAsync(id, cancellationToken);

			if (entity != null)
			{
				return Mapper.Map<TModel>(entity);
			}
			else
			{
				return null;
			}
		}
		protected virtual Task<(bool IsHandled, TModel? CustomMapped)> TryManualProjectionAsync(TDbEntity entity)
		{
			return Task.FromResult((false, default(TModel)));
		}

		public virtual async Task BeforeGetAsync(TModel request, TDbEntity entity) { }
	}
}
