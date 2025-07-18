using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services
{
	public class StoreService : BaseCRUDServiceAsync<Model.Store, Model.SearchObject.StoreSearchObject, Database.Store, Model.Request.StoreInsertRequest, Model.Request.StoreUpdateRequest>, IStoreService
	{
		public StoreService(KoTiJeOvoRadioContext context, IMapper mapper) : base(context, mapper)
		{
		}

		public override IQueryable<Store> AddFilter(StoreSearchObject search, IQueryable<Store> query)
		{
			query = query.Include(x => x.User);
			query = query.Include(x => x.Location);

			if (!string.IsNullOrWhiteSpace(search?.Name))
			{
				query = query.Where(x => x.StoreName.StartsWith(search.Name));
			}
			if (search.IsApplicant==true)
			{
				query = query.Where(x => x.IsApplicant == true);
			}
			else
			{
				query = query.Where(x => x.IsApplicant == false);

			}
			if (search.IsDeleted == true)
			{
				query = query.Where(x => x.IsDeleted == true);
			}
			else
			{
				query = query.Where(x => x.IsDeleted == false);

			}
			if (search.LocationId!=null)
			{
				query = query.Where(x => x.LocationId == search.LocationId);
			}
			if (search.StoreId!=null)
			{
				query = query.Where(x => x.StoreId == search.StoreId);
			}
			return base.AddFilter(search, query);
		}
		public override Task BeforeUpdateAsync(StoreUpdateRequest request, Store entity, CancellationToken cancellationToken = default)
		{
			if(entity.IsApplicant==true && request.IsApplicant==false)
			{
				if (request.Roles != null && request.Roles.Any())
				{
					var existingRoles = _context.UserRoles
						.Where(ur => ur.UserId == entity.UserId)
						.ToList();

					_context.UserRoles.RemoveRange(existingRoles);

					foreach (var roleId in request.Roles.Distinct())
					{
						_context.UserRoles.Add(new Database.UserRole
						{
							UserId = entity.UserId,
							RoleId = roleId,
							ChangedAt = DateTime.UtcNow,
							CreatedAt = DateTime.UtcNow
						});
					}

					_context.SaveChanges();
				}
			}
			return base.BeforeUpdateAsync(request, entity, cancellationToken);
		}
	}
}
