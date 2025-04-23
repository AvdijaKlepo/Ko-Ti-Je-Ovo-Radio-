using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace KoRadio.API.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class JobController : BaseCRUDController<Model.Job, JobSearchObject, JobInsertRequest, JobUpdateRequest>
    {
		public JobController(IJobService service)
			  : base(service)
		{

		}
	}
}
