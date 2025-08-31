using KoRadio.Model.SearchObject;
using KoRadio.Model;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using KoRadio.Services.Database;

using KoRadio.Model.Request;
using Mapster;
using Microsoft.EntityFrameworkCore.Storage;

namespace KoRadio.Services
{
	public class BaseCRUDServiceAsync<TModel, TSearch, TDbEntity, TInsert, TUpdate> : BaseServiceAsync<TModel, TSearch, TDbEntity> where TModel : class where TSearch : BaseSearchObject where TDbEntity : class where TUpdate : class
	{
		public BaseCRUDServiceAsync(KoTiJeOvoRadioContext context, IMapper mapper) : base(context, mapper)
		{
		}

		public virtual async Task<TModel> InsertAsync(TInsert request, CancellationToken cancellationToken = default)
		{

			TDbEntity entity = Mapper.Map<TDbEntity>(request);

			await BeforeInsertAsync(request, entity);
			_context.Add(entity);
			await _context.SaveChangesAsync(cancellationToken);

			await AfterInsertAsync(request, entity);

			return Mapper.Map<TModel>(entity);
		}

		public virtual async Task BeforeInsertAsync(TInsert request, TDbEntity entity, CancellationToken cancellationToken = default) { }
		public virtual async Task AfterInsertAsync(TInsert request, TDbEntity entity, CancellationToken cancellationToken = default) { }


		public virtual async Task<TModel> UpdateAsync(int id, TUpdate request, CancellationToken cancellationToken = default)
		{
			var set = _context.Set<TDbEntity>();

			var entity = await set.FindAsync(id, cancellationToken);
			await BeforeUpdateAsync(request, entity);
			Mapper.Map(request, entity);



			await _context.SaveChangesAsync(cancellationToken);

			await AfterUpdateAsync(request, entity);

			return Mapper.Map<TModel>(entity);
		}







		public virtual async Task BeforeUpdateAsync(TUpdate request, TDbEntity entity, CancellationToken cancellationToken = default) { }
		public virtual async Task AfterUpdateAsync(TUpdate request, TDbEntity entity, CancellationToken cancellationToken = default) { }

		public virtual async Task DeleteAsync(int id, CancellationToken cancellationToken = default)
		{
			var entity = await _context.Set<TDbEntity>().FindAsync(id, cancellationToken);

			if (entity == null)
				throw new UserException("Unesite postojeći id.");

			await BeforeDeleteAsync(entity, cancellationToken);

		
			if (entity is IApplicantDelete applicantEntity &&
				entity is ISoftDelete softDeleteApplicantEntity)
			{
				if (applicantEntity.IsApplicant && !softDeleteApplicantEntity.IsDeleted)
				{
					_context.Remove(entity);
				}
				else
				{
					
				
					if (!softDeleteApplicantEntity.IsDeleted)
					{
						softDeleteApplicantEntity.IsDeleted = true;
						_context.Update(entity);
					}
					else
					{
						softDeleteApplicantEntity.Undo();
						_context.Update(entity);
					}
				}
			}
			
			else if (entity is ISoftCancel softCancelEntity)
			{
				if (!softCancelEntity.IsCancelled)
				{
					softCancelEntity.IsCancelled = true;
					_context.Update(entity);
				}
				else
				{
					softCancelEntity.Undo();
					_context.Update(entity);
				}
			}
			
			else if (entity is ISoftDelete softDeleteEntity)
			{
				if (!softDeleteEntity.IsDeleted)
				{
					softDeleteEntity.IsDeleted = true;
					_context.Update(entity);
				}
				else
				{
					softDeleteEntity.Undo();
					_context.Update(entity);
				}
			}
			else if(entity is IJobDelete jobDeleteEntity)
			{
				_context.Remove(entity);
			}


			else
			{
				_context.Remove(entity);
			}

			await _context.SaveChangesAsync(cancellationToken);
			await AfterDeleteAsync(entity, cancellationToken);
		}

		public virtual async Task BeforeDeleteAsync(TDbEntity entity, CancellationToken cancellationToken) { }
		public virtual async Task AfterDeleteAsync(TDbEntity entity, CancellationToken cancellationToken) { }

		


	}
}
