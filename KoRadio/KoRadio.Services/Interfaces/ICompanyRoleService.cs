using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Interfaces
{
    public interface ICompanyRoleService:ICRUDServiceAsync<Model.CompanyRole, Model.SearchObject.CompanyRoleSearchObject, Model.Request.CompanyRoleInsertRequest, Model.Request.CompanyRoleUpdateRequest>
	{
    }
}
