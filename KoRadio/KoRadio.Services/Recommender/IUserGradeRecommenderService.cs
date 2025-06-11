using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Recommender
{
    public interface IUserGradeRecommenderService
    {
		Task<List<Model.Freelancer>> GetRecommendedGradedProducts(int userId, int freelancerId);
		void TrainData();
	}
}
