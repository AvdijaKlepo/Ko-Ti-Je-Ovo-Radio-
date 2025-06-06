using KoRadio.Model;
using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace KoRadio.API.Controllers
{
	[Route("[controller]")]
	[ApiController]
	public class FreelancerController : BaseCRUDControllerAsync<Model.Freelancer,FreelancerSearchObject,FreelancerInsertRequest,FreelancerUpdateRequest>
	{
		

		public FreelancerController(IFreelanceService service)
			: base(service)
		{
			
		}

		


		
	}
}
