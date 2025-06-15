using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using KoRadio.Services.SignalRService;
using MapsterMapper;
using Microsoft.AspNetCore.SignalR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services
{
    public class UserRatingService:BaseCRUDServiceAsync<Model.UserRating, Model.SearchObject.UserRatingSearchObject, Database.UserRating, Model.Request.UserRatingInsertRequest, Model.Request.UserRatingUpdateRequest>, IUserRatings
	{
		public UserRatingService(KoTiJeOvoRadioContext context, IMapper mapper, IHubContext<SignalRHubService> hubContext) : base(context, mapper)
		{
			
		}
	}
}
