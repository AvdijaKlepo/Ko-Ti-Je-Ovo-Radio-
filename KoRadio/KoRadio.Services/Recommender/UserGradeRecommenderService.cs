using KoRadio.Model;
using KoRadio.Services.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.ML.Trainers;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace KoRadio.Services.Recommender
{
	public class UserGradeRecommenderService : IUserGradeRecommenderService
	{
		private readonly KoTiJeOvoRadioContext _context;
		private static MLContext _mlContext;
		private static ITransformer _model;
		private static readonly string ModelPath = "freelancer-model.zip";
		private static readonly object _lock = new();

		public UserGradeRecommenderService(KoTiJeOvoRadioContext context)
		{
			_context = context;
			_mlContext ??= new MLContext();
		}

		public async Task<List<Model.Freelancer>> GetRecommendedFreelancers(int userId, int? serviceId = null)
		{
			LoadOrTrainModel();

			var ratedFreelancerIds = await _context.UserRatings
				.Where(r => r.UserId == userId)
				.Select(r => r.FreelancerId)
				.Distinct()
				.ToListAsync();

			// Filter freelancers by service if serviceId is provided
			var freelancersQuery = _context.Freelancers
				.Where(f => !f.IsDeleted && !ratedFreelancerIds.Contains(f.FreelancerId))
				.Include(f => f.FreelancerNavigation)
				.Include(f=>f.FreelancerServices)
				.ThenInclude(x=>x.Service)
				.AsQueryable();

			if (serviceId.HasValue)
			{
				freelancersQuery = freelancersQuery
					.Where(f => f.FreelancerServices.Any(fs => fs.ServiceId == serviceId.Value));
			}

			var allFreelancers = await freelancersQuery.ToListAsync();

			if (!allFreelancers.Any())
				return await GetColdStartFreelancers(serviceId);

			var predictionEngine = _mlContext.Model
				.CreatePredictionEngine<FreelancerEntry, FreelancerPrediction>(_model);

			var predictions = allFreelancers
				.Select(f => new
				{
					Freelancer = f,
					Score = predictionEngine.Predict(new FreelancerEntry
					{
						UserId = (uint)userId,
						FreelancerId = (uint)f.FreelancerId
					}).Score
				})
				.OrderByDescending(p => p.Score)
				.Take(3)
				.Select(p => new Model.Freelancer
				{
					FreelancerId = p.Freelancer.FreelancerId,
					IsApplicant = p.Freelancer.IsApplicant,
					IsDeleted = p.Freelancer.IsDeleted,
					Bio = p.Freelancer.Bio,
					Rating = p.Freelancer.Rating,
					ExperianceYears = p.Freelancer.ExperianceYears,
					StartTime = p.Freelancer.StartTime,
					EndTime = p.Freelancer.EndTime,
					WorkingDays = ConvertIntToDaysOfWeekList(p.Freelancer.WorkingDays),
					FreelancerServices = p.Freelancer.FreelancerServices.Select(fs => new Model.FreelancerService
					{
						FreelancerId = fs.FreelancerId,
						ServiceId = fs.ServiceId,
						Service = new Model.Service
						{
							ServiceId = fs.Service.ServiceId,
							ServiceName = fs.Service.ServiceName
						}

					}).ToList(),

					FreelancerNavigation = new Model.User
					{
						FirstName = p.Freelancer.FreelancerNavigation.FirstName,
						LastName = p.Freelancer.FreelancerNavigation.LastName,
						Image = p.Freelancer.FreelancerNavigation.Image
					}
				})
				.ToList();

			return predictions.Any() ? predictions : await GetColdStartFreelancers(serviceId);
		}


		public void TrainData()
		{
			TrainModel();
		}

		#region Private Helpers

		private void LoadOrTrainModel()
		{
			if (_model != null) return;

			lock (_lock)
			{
				if (_model != null) return;

				if (File.Exists(ModelPath))
				{
					using var stream = new FileStream(ModelPath, FileMode.Open, FileAccess.Read, FileShare.Read);
					_model = _mlContext.Model.Load(stream, out _);
				}
				else
				{
					TrainModel();
				}
			}
		}

		private void TrainModel()
		{
			var ratings = _context.UserRatings
				.Where(r => r.UserId.HasValue && r.FreelancerId.HasValue)
				.Select(r => new FreelancerEntry
				{
					UserId = (uint)r.UserId.Value,
					FreelancerId = (uint)r.FreelancerId.Value,
					Label = (float)r.Rating
				})
				.ToList();

			var trainingData = _mlContext.Data.LoadFromEnumerable(ratings);

			var options = new MatrixFactorizationTrainer.Options
			{
				MatrixColumnIndexColumnName = nameof(FreelancerEntry.UserId),
				MatrixRowIndexColumnName = nameof(FreelancerEntry.FreelancerId),
				LabelColumnName = nameof(FreelancerEntry.Label),
				LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossRegression,
				Alpha = 0.01,
				Lambda = 0.025,
				NumberOfIterations = 100
			};

			var estimator = _mlContext.Recommendation().Trainers.MatrixFactorization(options);
			_model = estimator.Fit(trainingData);

			using var fs = new FileStream(ModelPath, FileMode.Create, FileAccess.Write, FileShare.Write);
			_mlContext.Model.Save(_model, trainingData.Schema, fs);
		}

		private async Task<List<Model.Freelancer>> GetColdStartFreelancers(int? serviceId = null)
		{
			var freelancersQuery = _context.Freelancers
	.Where(f => !f.IsDeleted)
	.Include(f => f.FreelancerNavigation)
	.Include(f => f.FreelancerServices)
		.ThenInclude(fs => fs.Service)
	.OrderByDescending(f => f.UserRatings.Any() ? f.UserRatings.Average(r => r.Rating) : 0)
	.ThenByDescending(f => f.UserRatings.Count())
	.Take(3)
	.AsQueryable();


			if (serviceId.HasValue)
			{
				freelancersQuery = freelancersQuery
					.Where(f => f.FreelancerServices.Any(fs => fs.ServiceId == serviceId.Value));
			}

			var freelancers = await freelancersQuery.ToListAsync();

			return freelancers.Select(p => new Model.Freelancer
			{
				FreelancerId = p.FreelancerId,
				IsApplicant = p.IsApplicant,
				IsDeleted = p.IsDeleted,
				Bio = p.Bio,
				Rating = p.Rating,
				ExperianceYears = p.ExperianceYears,
				StartTime = p.StartTime,
				EndTime = p.EndTime,
				WorkingDays = ConvertIntToDaysOfWeekList(p.WorkingDays),
				FreelancerServices = p.FreelancerServices.Select(fs => new Model.FreelancerService
				{
					FreelancerId = fs.FreelancerId,
					ServiceId = fs.ServiceId,
					Service = new Model.Service
					{
						ServiceId = fs.Service.ServiceId,
						ServiceName = fs.Service.ServiceName
					}

				}).ToList(),
				FreelancerNavigation = new Model.User
				{
					FirstName = p.FreelancerNavigation.FirstName,
					LastName = p.FreelancerNavigation.LastName,
					Image = p.FreelancerNavigation.Image
				}
			}).ToList();
		}

		// And add this helper method inside the class:
		private List<DayOfWeek> ConvertIntToDaysOfWeekList(int daysBitmask)
		{
			var days = new List<DayOfWeek>();
			for (int i = 0; i < 7; i++)
			{
				if ((daysBitmask & (1 << i)) != 0)
					days.Add((DayOfWeek)i);
			}
			return days;
		}
		#endregion
	}

	public class FreelancerEntry
	{
		[KeyType(count: 100000)]
		public uint UserId { get; set; }

		[KeyType(count: 100000)]
		public uint FreelancerId { get; set; }

		public float Label { get; set; }
	}

	public class FreelancerPrediction
	{
		public float Score { get; set; }
	}
}
