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
	public class UserController : BaseCRUDControllerAsync<Model.User, UserSearchObject,UserInsertRequest,UserUpdateRequest>
	{
		

		public UserController(IUserService service)
			: base(service)
		{
			
		}

		[HttpPost("Login")]
		[AllowAnonymous]
		public Model.User Login(string username,string password, string connectionId)
		{
			return (_service as IUserService).Login(username, password, connectionId);
		}

		[HttpPost("Registration")]
		[AllowAnonymous]

		public  Task<Model.DTOs.UserDTO> Registrate(UserInsertRequest request)
		{
			return (_service as IUserService).Registration(request);
		}

	



	}
}
