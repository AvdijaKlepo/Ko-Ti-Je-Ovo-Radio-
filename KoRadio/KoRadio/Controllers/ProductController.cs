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
	public class ProductController : BaseCRUDControllerAsync<Model.Product, Model.SearchObject.ProductSearchObject, Model.Request.ProductInsertRequest, Model.Request.ProductUpdateRequest>
	{
		public ProductController(IProductService service) : base(service)
		{
		}
	}
}
