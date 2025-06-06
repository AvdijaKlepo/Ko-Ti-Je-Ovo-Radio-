using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Interfaces
{
    public interface IJobService:ICRUDServiceAsync<Model.Job, JobSearchObject, JobInsertRequest, JobUpdateRequest>
	{
    }
}
