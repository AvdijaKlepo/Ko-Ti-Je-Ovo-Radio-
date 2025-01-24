using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using KoRadio.Model;
using KoRadio.Model.SearchObject;

namespace KoRadio.Services.Interfaces
{
	public interface IWorkerService
	{
		List<WorkerModel> GetList(WorkerSearchObject searchObject);
	}
}
