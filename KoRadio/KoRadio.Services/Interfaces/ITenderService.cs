using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Interfaces
{
   public interface ITenderService:ICRUDServiceAsync<Model.Tender, Model.SearchObject.TenderSearchObject, Model.Request.TenderInsertRequest, Model.Request.TenderUpdateRequest>
	{
	}
   
}
