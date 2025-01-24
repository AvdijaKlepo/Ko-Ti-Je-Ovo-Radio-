using KoRadio.Model;
using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace KoRadio.API.Controllers
{
	[Route("[controller]")]
	[ApiController]
	public class UserController : ControllerBase
	{
		private readonly IUserService _service;

		public UserController(IUserService service)
		{
			_service = service;
		}

		[HttpGet]
		public List<UserModel> GetUsers([FromQuery]UserSearchObject searchObject)
		{
			return _service.GetUsers(searchObject);
		}

		[HttpPost]
		public UserModel Insert(UserInsertRequest request)
		{
			return _service.Insert(request);
		}

		[HttpPut("{id}")]
		public UserModel Update(int id,UserUpdateRequest request)
		{
			return _service.Update(id, request);
		}
	}
}
