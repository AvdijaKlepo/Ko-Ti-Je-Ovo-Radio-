using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Interfaces
{
    public interface IOrderService:ICRUDServiceAsync<Model.Order,OrderSearchObject, OrderInsertRequest, OrderUpdateRequest>
    {
    }
}
