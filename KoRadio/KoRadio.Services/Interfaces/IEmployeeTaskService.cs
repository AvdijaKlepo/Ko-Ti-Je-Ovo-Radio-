using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Interfaces
{
	public interface IEmployeeTaskService:ICRUDServiceAsync<Model.EmployeeTask, Model.SearchObject.EmployeeTaskSearchObject, Model.Request.EmployeeTaskInsertRequest,Model.Request.EmployeeTaskUpdateRequest>
	{
	}
}
