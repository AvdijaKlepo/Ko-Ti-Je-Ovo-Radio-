using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services
{
    public class CompanyEmployeeService: BaseCRUDServiceAsync<Model.CompanyEmployee, Model.SearchObject.CompanyEmployeeSearchObject,Database.CompanyEmployee, Model.Request.CompanyEmployeeInsertRequest, Model.Request.CompanyEmployeeUpdateRequest>, Interfaces.ICompanyEmployeeService
	{
		private readonly KoTiJeOvoRadioContext _context;
		private readonly IMapper _mapper;
		public CompanyEmployeeService(IMapper mapper, KoTiJeOvoRadioContext context): base(context, mapper)
		{
			_context = context;
			_mapper = mapper;
		}

		public override IQueryable<CompanyEmployee> AddFilter(CompanyEmployeeSearchObject search, IQueryable<CompanyEmployee> query)
		{
			return base.AddFilter(search, query);
		}
	}
}
