using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using MapsterMapper;

namespace KoRadio.Services
{
	public abstract class BaseCRUDService<TModel,TSearch,TDbEntity, TInsert, TUpdate> : BaseService<TModel,TSearch,TDbEntity> where TModel : class where TSearch : BaseSearchObject
		where TDbEntity: class
	{

		public BaseCRUDService(KoTiJeOvoRadioContext context, IMapper mapper) : base(context, mapper)
		{
			
		}
		
		public TModel Insert(TInsert request)
		{
		
				
			TDbEntity entity = _mapper.Map<TDbEntity>(request);
			
			
			BeforeInsert(request, entity);
			_context.Add(entity);
			_context.SaveChanges();

			return _mapper.Map<TModel>(entity);
		}

		public TModel Update(int id, TUpdate request)
		{
			var set = _context.Set<TDbEntity>();

			var entity = set.Find(id);
			_mapper.Map(request, entity);
			
			BeforeUpdate(request, entity);

			_context.SaveChanges();

			return _mapper.Map<TModel>(entity);
		}
		public virtual void BeforeInsert(TInsert request, TDbEntity entity) {}
		public virtual void BeforeUpdate(TUpdate request, TDbEntity entity) {}
		public virtual void AfterInsert(TInsert request, TDbEntity entity) { }



	}
}
