using KoRadio.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace KoRadio.API.Controllers
{
	[Route("[controller]")]
	[ApiController]
	public class EmployeeTaskController : BaseCRUDControllerAsync<Model.EmployeeTask,Model.SearchObject.EmployeeTaskSearchObject, Model.Request.EmployeeTaskInsertRequest, Model.Request.EmployeeTaskUpdateRequest>
	{
		public EmployeeTaskController(IEmployeeTaskService service)
			: base(service)
		{
		}
	}
}
