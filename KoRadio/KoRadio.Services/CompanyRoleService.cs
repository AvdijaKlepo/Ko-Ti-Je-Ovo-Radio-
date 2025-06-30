using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using MapsterMapper;
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
		public override IQueryable<CompanyRole> AddFilter(CompanyRoleSearchObject search, IQueryable<CompanyRole> query)
		{

			if(search.CompanyId!=null)
			{
				query = query.Where(x => x.CompanyId == search.CompanyId);
			}
			return base.AddFilter(search, query);
		}

	}
}
