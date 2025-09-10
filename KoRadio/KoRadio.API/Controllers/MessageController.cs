using KoRadio.Model;
using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace KoRadio.API.Controllers
{
	[Route("[controller]")]
	[ApiController]
	public class MessageController : BaseCRUDControllerAsync<Model.Message, Model.SearchObject.MessageSearchObject, Model.Request.MessageInsertRequest, Model.Request.MessageUpdateRequest>
	{
		public MessageController(IMessageService service)
			: base(service)
		{

		}
	}
}
