using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Recommender
{
	public interface ICompanyRecommenderService
	{
		Task<List<Model.Company>> GetRecommendedCompanies(int userId, int? serviceId);
		void TrainData();
	}
}
