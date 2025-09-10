using KoRadio.Model;
using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services;
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

		[HttpGet("RecommendedFreelancers/{userId}")]
		public Task<List<Model.Freelancer>> GetRecommendedFreelancers(int userId,int serviceId)
		{
			return (_service as UserService).GetRecommendedFreelancers(userId, serviceId);
		}
		[HttpGet("RecommendedCompanies/{userId}")]
		public Task<List<Model.Company>> GetRecommendedCompanies(int userId, int serviceId)
		{
			return (_service as UserService).GetRecommendedCompanies(userId, serviceId);
		}
		[HttpGet("RecommendedProducts/{userId}")]
		public Task<List<Model.Product>> GetRecommendedProducts(int userId)
		{
			return (_service as UserService).GetRecommendedProducts(userId);
		}



	}
}
