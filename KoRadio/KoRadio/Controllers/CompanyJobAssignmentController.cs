using KoRadio.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace KoRadio.API.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class CompanyJobAssignmentController : BaseCRUDControllerAsync<Model.CompanyJobAssignment,	Model.SearchObject.CompanyJobAssignmentSearchObject,Model.Request.CompanyJobAssignmentInsertRequest,Model.Request.CompanyJobAssignmentUpdateRequest>
	{

		public CompanyJobAssignmentController(ICompanyJobAssignment service)
			: base(service)
		{

		}

	}
	
	

}
