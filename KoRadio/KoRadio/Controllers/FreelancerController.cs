using KoRadio.Model;
using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using MapsterMapper;
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

		public override Task<Model.Freelancer> GetById(int id, CancellationToken cancellationToken = default)
		{

			return base.GetById(id, cancellationToken);
		}

		






	}
	
}
