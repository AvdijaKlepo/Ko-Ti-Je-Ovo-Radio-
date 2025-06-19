using KoRadio.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace KoRadio.API.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class CompanyRoleController : BaseCRUDControllerAsync<Model.CompanyRole, Model.SearchObject.CompanyRoleSearchObject, Model.Request.CompanyRoleInsertRequest, Model.Request.CompanyRoleUpdateRequest>
	{
		public CompanyRoleController(ICompanyRoleService service)
		: base(service)
		{

		}
	}
}
