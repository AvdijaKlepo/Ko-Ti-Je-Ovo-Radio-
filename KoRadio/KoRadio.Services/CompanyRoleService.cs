using KoRadio.Model;
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
    public class CompanyRoleService:BaseCRUDServiceAsync<Model.CompanyRole, CompanyRoleSearchObject, Database.CompanyRole, CompanyRoleInsertRequest, CompanyRoleUpdateRequest>, ICompanyRoleService
	{
		
		public CompanyRoleService(IMapper mapper, KoTiJeOvoRadioContext context) : base(context, mapper)
		{
		
		}
		public override IQueryable<Database.CompanyRole> AddFilter(CompanyRoleSearchObject search, IQueryable<Database.CompanyRole> query)
		{

			if(search.CompanyId!=null)
			{
				query = query.Where(x => x.CompanyId == search.CompanyId);
			}
			return base.AddFilter(search, query);
		}

		public override async Task BeforeDeleteAsync(Database.CompanyRole entity, CancellationToken cancellationToken)
		{
			var isUsedByEmployee = await _context.CompanyEmployees
		   .AnyAsync(fs => fs.CompanyRoleId == entity.CompanyRoleId, cancellationToken);

			

			if (isUsedByEmployee)
			{
				throw new UserException("Ne možete izbrisati ulogu koja je trenutno dodijeljena radniku.");
			}
			await base.BeforeDeleteAsync(entity, cancellationToken);
			
		}
		public override async Task BeforeInsertAsync(CompanyRoleInsertRequest request, Database.CompanyRole entity, CancellationToken cancellationToken = default)
		{
			
			await base.BeforeInsertAsync(request, entity, cancellationToken);
		}

	}
}
