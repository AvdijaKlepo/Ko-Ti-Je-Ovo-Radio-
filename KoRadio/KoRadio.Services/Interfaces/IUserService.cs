using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using KoRadio.Model;
using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using Microsoft.EntityFrameworkCore.Metadata.Internal;

namespace KoRadio.Services.Interfaces
{
	public interface IUserService:ICRUDService<Model.User,UserSearchObject,UserInsertRequest,UserUpdateRequest>
	{
	
	}
}
