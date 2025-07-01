using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services
{
    public class CompanyJobAssignmentService: BaseCRUDServiceAsync<Model.CompanyJobAssignment, Model.SearchObject.CompanyJobAssignmentSearchObject,Database.CompanyJobAssignment, Model.Request.CompanyJobAssignmentInsertRequest, Model.Request.CompanyJobAssignmentUpdateRequest>, Interfaces.ICompanyJobAssignment
	{
		public CompanyJobAssignmentService(IMapper mapper, KoTiJeOvoRadioContext context) : base(context, mapper)
		{

		}

		public override IQueryable<CompanyJobAssignment> AddFilter(CompanyJobAssignmentSearchObject search, IQueryable<CompanyJobAssignment> query)
		{
			query = query.Include(x => x.CompanyEmployee).ThenInclude(x => x.User);
			if (search.JobId!=null)
			{
				query = query.Where(x => x.JobId == search.JobId);
			}
			return base.AddFilter(search, query);
		}
	}
}
