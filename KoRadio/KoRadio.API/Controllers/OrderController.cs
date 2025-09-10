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
	public class OrderController : BaseCRUDControllerAsync<KoRadio.Model.Order, KoRadio.Model.SearchObject.OrderSearchObject, KoRadio.Model.Request.OrderInsertRequest, KoRadio.Model.Request.OrderUpdateRequest>
	{
		public OrderController(IOrderService service) : base(service)
		{
		}
	}
}
