using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace KoRadio.API.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class UserRatingController : BaseCRUDControllerAsync<Model.UserRating, UserRatingSearchObject, UserRatingInsertRequest, UserRatingUpdateRequest>
    {
		public UserRatingController(IUserRatings service)
		: base(service)
		{

		}
	}
}
