using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Interfaces
{
    public interface ICompanyEmployeeService:ICRUDServiceAsync<Model.CompanyEmployee, Model.SearchObject.CompanyEmployeeSearchObject, Model.Request.CompanyEmployeeInsertRequest, Model.Request.CompanyEmployeeUpdateRequest>
	{
    }
}
