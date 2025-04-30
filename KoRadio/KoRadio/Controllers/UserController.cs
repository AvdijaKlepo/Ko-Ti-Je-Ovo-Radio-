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
	public class UserController : BaseCRUDController<Model.User,UserSearchObject,UserInsertRequest,UserUpdateRequest>
	{
		

		public UserController(IUserService service)
			: base(service)
		{
			
		}

		[HttpPost("Login")]
		[AllowAnonymous]
		public Model.User Login(string username,string password)
		{
			return (_service as IUserService).Login(username, password);
		}

		[HttpPost("Registration")]
		[AllowAnonymous]

		public Model.User Registrate(UserInsertRequest request)
		{
			return (_service as IUserService).Registration(request);
		}

		
	}
}
