using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Interfaces
{
    public interface IStoreService:ICRUDServiceAsync<Model.Store,Model.SearchObject.StoreSearchObject,Model.Request.StoreInsertRequest,Model.Request.StoreUpdateRequest>
    {
    }
}
