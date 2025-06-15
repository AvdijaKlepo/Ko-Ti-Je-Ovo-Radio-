using KoRadio.Model;
using KoRadio.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.ML.Trainers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services.Recommender
{
	public class UserGradeRecommenderService
	{


		//		private readonly KoTiJeOvoRadioContext _context;
		//		private static MLContext _mlContext;
		//		private static ITransformer _model;
		//		private static readonly string ModelPath = "freelancer-model.zip";
		//		private static readonly object _lock = new();

		//		public UserGradeRecommenderService(KoTiJeOvoRadioContext context)
		//		{
		//			_context = context;
		//		}

		//		public async Task<List<Database.Freelancer>> GetRecommendedFreelancers(int userId)
		//		{
		//			if (_model == null)
		//			{
		//				lock (_lock)
		//				{
		//					_mlContext ??= new MLContext();

		//					if (File.Exists(ModelPath))
		//					{
		//						using var stream = new FileStream(ModelPath, FileMode.Open, FileAccess.Read, FileShare.Read);
		//						_model = _mlContext.Model.Load(stream, out _);
		//					}
		//					else
		//					{
		//						TrainModel();
		//					}
		//				}
		//			}

		//			var ratedFreelancerIds = await _context.UserRatings
		//				.Where(r => r.UserId == userId && r.Rating >= 3.5m)
		//				.Select(r => r.FreelancerId)
		//				.Distinct()
		//				.ToListAsync();

		//			var allFreelancers = await _context.Freelancers
		//				.Where(f => !f.IsDeleted)
		//				.ToListAsync();

		//			var predictions = new List<(Database.Freelancer Freelancer, float Score)>();

		//			var predictionEngine = _mlContext.Model.CreatePredictionEngine<FreelancerEntry, FreelancerPrediction>(_model);

		//			foreach (var freelancer in allFreelancers)
		//			{
		//				if (ratedFreelancerIds.Contains(freelancer.FreelancerId))
		//					continue;

		//				var prediction = predictionEngine.Predict(new FreelancerEntry
		//				{
		//					UserId = (uint)userId,
		//					FreelancerId = (uint)freelancer.FreelancerId
		//				});

		//				predictions.Add((freelancer, prediction.Score));
		//			}

		//			return predictions
		//				.OrderByDescending(p => p.Score)
		//				.Select(p => p.Freelancer)
		//				.Take(5)
		//				.ToList();
		//		}

		//		private void TrainModel()
		//		{
		//			var ratings = _context.UserRatings
		//				.Where(r => r.UserId.HasValue && r.FreelancerId.HasValue && r.Rating >= 3.5m)
		//				.Select(r => new FreelancerEntry
		//				{
		//					UserId = (uint)r.UserId.Value,
		//					FreelancerId = (uint)r.FreelancerId.Value,
		//					Label = (float)r.Rating
		//				})
		//				.ToList();

		//			var trainingData = _mlContext.Data.LoadFromEnumerable(ratings);

		//			var options = new MatrixFactorizationTrainer.Options
		//			{
		//				MatrixColumnIndexColumnName = nameof(FreelancerEntry.UserId),
		//				MatrixRowIndexColumnName = nameof(FreelancerEntry.FreelancerId),
		//				LabelColumnName = nameof(FreelancerEntry.Label),
		//				LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
		//				Alpha = 0.01,
		//				Lambda = 0.025,
		//				NumberOfIterations = 100,
		//				C = 0.00001
		//			};

		//			var estimator = _mlContext.Recommendation().Trainers.MatrixFactorization(options);
		//			_model = estimator.Fit(trainingData);

		//			using var fs = new FileStream(ModelPath, FileMode.Create, FileAccess.Write, FileShare.Write);
		//			_mlContext.Model.Save(_model, trainingData.Schema, fs);
		//		}
		//	}


		//public class FreelancerEntry
		//	{
		//		[KeyType(count: 100000)] 
		//		public uint UserId { get; set; }

		//		[KeyType(count: 100000)]
		//		public uint FreelancerId { get; set; }

		//		public float Label { get; set; }  
		//	}

		//	public class FreelancerPrediction
		//	{
		//		public float Score { get; set; }
		//	}
	}


}
