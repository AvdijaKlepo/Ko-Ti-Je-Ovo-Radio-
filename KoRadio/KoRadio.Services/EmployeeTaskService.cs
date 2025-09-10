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
	public class EmployeeTaskService : BaseCRUDServiceAsync<Model.EmployeeTask, Model.SearchObject.EmployeeTaskSearchObject,Database.EmployeeTask, Model.Request.EmployeeTaskInsertRequest, Model.Request.EmployeeTaskUpdateRequest>,IEmployeeTaskService
	{
	
		public EmployeeTaskService(KoTiJeOvoRadioContext context, IMapper mapper) : base(context, mapper)
		{

		}
		public override IQueryable<EmployeeTask> AddFilter(EmployeeTaskSearchObject search, IQueryable<EmployeeTask> query)
		{
			query = query.Include(x => x.CompanyEmployee).ThenInclude(x => x.User);
			if(search.CompanyId!=null)
			{
				query = query.Where(x => x.CompanyId == search.CompanyId);
			}
			if(search.JobId!=null)
			{
				query = query.Where(x => x.JobId == search.JobId);
			}
			if(search.CompanyEmployeeId!=null)
			{
				query = query.Where(x => x.CompanyEmployeeId == search.CompanyEmployeeId);
			}
			if(search.IsFinished!=null)
			{
				query = query.Where(x => x.IsFinished == search.IsFinished);
			}
			return base.AddFilter(search, query);
		}
	}
}
