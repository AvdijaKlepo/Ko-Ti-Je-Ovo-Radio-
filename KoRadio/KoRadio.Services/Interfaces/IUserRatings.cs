using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Interfaces
{
    public interface IUserRatings : ICRUDServiceAsync<Model.UserRating, Model.SearchObject.UserRatingSearchObject, Model.Request.UserRatingInsertRequest, Model.Request.UserRatingUpdateRequest>
	{

    }
}
