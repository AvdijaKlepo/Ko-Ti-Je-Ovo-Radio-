using KoRadio.Model;
using KoRadio.Model.SearchObject;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Interfaces
{
    public interface ILocationService: ICRUDService<Model.Location, Model.SearchObject.LocationSearchObject, Model.Request.LocationInsertRequest, Model.Request.LocationUpdateRequest>
	{
        PagedResult<Location> GetForRegistration(LocationSearchObject locationSearchObject);
    }
}
