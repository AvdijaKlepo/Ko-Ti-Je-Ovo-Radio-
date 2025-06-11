using KoRadio.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Recommender
{
	public class UserGradeRecommenderService : IUserGradeRecommenderService
	{
		public Task<List<Freelancer>> GetRecommendedGradedProducts(int userId, int freelancerId)
		{
			throw new NotImplementedException();
		}

		public void TrainData()
		{
			throw new NotImplementedException();
		}
	}
}
