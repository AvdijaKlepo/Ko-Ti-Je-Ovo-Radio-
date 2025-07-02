using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Interfaces
{
    public interface IProductService: ICRUDServiceAsync<Model.Product, Model.SearchObject.ProductSearchObject, Model.Request.ProductInsertRequest, Model.Request.ProductUpdateRequest>
	{
    }
}
