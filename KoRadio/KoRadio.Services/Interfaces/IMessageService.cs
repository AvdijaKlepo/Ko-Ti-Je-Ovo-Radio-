using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Interfaces
{
   public interface IMessageService:ICRUDServiceAsync<Model.Message, Model.SearchObject.MessageSearchObject, Model.Request.MessageInsertRequest, Model.Request.MessageUpdateRequest>
	{
    }
}
