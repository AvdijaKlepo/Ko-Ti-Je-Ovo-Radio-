using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace KoRadio.API.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class CompanyEmployeeController : BaseCRUDControllerAsync<Model.CompanyEmployee, CompanyEmployeeSearchObject, CompanyEmployeeInsertRequest, CompanyEmployeeUpdateRequest>
	{
		public CompanyEmployeeController(ICompanyEmployeeService service)
			: base(service)
		{
		}
	}
}
