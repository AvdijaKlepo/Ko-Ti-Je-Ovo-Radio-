using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Recommender
{
	public interface IOrderLocationRecommender
	{
		Task<List<Model.Product>> GetRecommendedProducts(int userId);
		void TrainData();
	}
}
