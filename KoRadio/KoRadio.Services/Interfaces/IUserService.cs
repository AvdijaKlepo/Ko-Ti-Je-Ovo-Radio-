using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using KoRadio.Model;
using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;

namespace KoRadio.Services.Interfaces
{
	public interface IUserService
	{
		List<UserModel> GetUsers(UserSearchObject searchObject);
		UserModel Insert(UserInsertRequest request);
		UserModel Update(int id,UserUpdateRequest request);
	}
}
