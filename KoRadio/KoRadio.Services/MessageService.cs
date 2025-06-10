using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services
{
	public class MessageService : BaseCRUDServiceAsync<Model.Message, Model.SearchObject.MessageSearchObject, Database.Message, Model.Request.MessageInsertRequest, Model.Request.MessageUpdateRequest>, IMessageService
	{
		public MessageService(KoTiJeOvoRadioContext context, IMapper mapper) : base(context, mapper)
		{
		}

		public override IQueryable<Message> AddFilter(MessageSearchObject search, IQueryable<Message> query)
		{
			return base.AddFilter(search, query);
		}
	}
}
