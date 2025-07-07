using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Interfaces
{
    public interface ITenderBidService : ICRUDServiceAsync<Model.TenderBid, Model.SearchObject.TenderBidSearchObject, Model.Request.TenderBidInsertRequest, Model.Request.TenderBidUpdateRequest>
	{
    }
}
