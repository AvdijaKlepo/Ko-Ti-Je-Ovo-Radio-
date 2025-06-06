using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Interfaces
{
    public interface IServicesService:ICRUDServiceAsync<Model.Service, ServiceSearchObject, ServiceInsertRequest, ServiceUpdateRequest>
	{
    }
}
