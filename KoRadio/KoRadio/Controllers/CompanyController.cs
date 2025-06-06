using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace KoRadio.API.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class CompanyController : BaseCRUDControllerAsync<Model.Company, CompanySearchObject, CompanyInsertRequest, CompanyUpdateRequest>
	{
		public CompanyController(ICompanyService service)
			: base(service)
		{
		}
		
	}
}
