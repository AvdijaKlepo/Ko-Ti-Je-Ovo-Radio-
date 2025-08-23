using KoRadio.Model;
using KoRadio.Services.Database;
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
	public class CompanyRecommenderService : ICompanyRecommenderService
	{
		private readonly KoTiJeOvoRadioContext _context;
		private static MLContext _mlContext;
		private static ITransformer _model;
		private static readonly string ModelPath = "company-model.zip";
		private static readonly object _lock = new();

	
		public CompanyRecommenderService(KoTiJeOvoRadioContext context)
		{
			_context = context;
			_mlContext ??= new MLContext();
		}

		public async Task<List<Model.Company>> GetRecommendedCompanies(int userId, int? serviceId = null)
		{
			LoadOrTrainModel();

			var ratedCompanyIds = await _context.UserRatings
				.Where(r => r.UserId == userId)
				.Select(r => r.CompanyId)
				.Distinct()
				.ToListAsync();

		
			var companyQuery = _context.Companies
				.Where(f => !f.IsDeleted && !ratedCompanyIds.Contains(f.CompanyId))
				
				.Include(f => f.CompanyServices)
				.ThenInclude(x => x.Service)
				.AsQueryable();

			if (serviceId.HasValue)
			{
				companyQuery = companyQuery
					.Where(f => f.CompanyServices.Any(fs => fs.ServiceId == serviceId.Value));
			}

			var allCompanies = await companyQuery.ToListAsync();

			if (!allCompanies.Any())
				return await GetColdStartCompanies(serviceId);

			var predictionEngine = _mlContext.Model
				.CreatePredictionEngine<CompanyEntry, CompanyPrediction>(_model);

			var predictions = allCompanies
				.Select(c => new
				{
					Company = c,
					Score = predictionEngine.Predict(new CompanyEntry
					{
						UserId = (uint)userId,
						CompanyId = (uint)c.CompanyId,
						
					}).Score
				})
				.OrderByDescending(p => p.Score)
				.Take(3)
				.Select(p => new Model.Company
				{
					CompanyId = p.Company.CompanyId,
					CompanyName = p.Company.CompanyName,
					Bio = p.Company.Bio,
					Rating = p.Company.Rating,
					IsDeleted = p.Company.IsDeleted,
					Email = p.Company.Email,
					EndTime=p.Company.EndTime,
					StartTime=p.Company.StartTime,
					ExperianceYears=p.Company.ExperianceYears,
					Image=p.Company.Image,
					LocationId=p.Company.LocationId,
					IsApplicant=p.Company.IsApplicant,
					PhoneNumber=p.Company.PhoneNumber,
					WorkingDays= ConvertIntToDaysOfWeekList(p.Company.WorkingDays),
					
					CompanyServices = p.Company.CompanyServices.Select(cs => new Model.CompanyService
					{
						CompanyId = cs.CompanyId,
						ServiceId = cs.ServiceId,
						Service = new Model.Service
						{
							ServiceId = cs.Service.ServiceId,
							ServiceName = cs.Service.ServiceName
						}
					}).ToList(),
					
				})
				.ToList();

			return predictions.Any() ? predictions : await GetColdStartCompanies(serviceId);
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
				.Where(r => r.UserId.HasValue && r.CompanyId.HasValue)
				.Select(r => new CompanyEntry
				{
					UserId = (uint)r.UserId.Value,
					CompanyId = (uint)r.CompanyId.Value,
					Label = (float)r.Rating
				})
				.ToList();

			var trainingData = _mlContext.Data.LoadFromEnumerable(ratings);

			var options = new MatrixFactorizationTrainer.Options
			{
				MatrixColumnIndexColumnName = nameof(CompanyEntry.UserId),
				MatrixRowIndexColumnName = nameof(CompanyEntry.CompanyId),
				LabelColumnName = nameof(CompanyEntry.Label),
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

		private async Task<List<Model.Company>> GetColdStartCompanies(int? serviceId = null)
		{
			var companiesQuery = _context.Companies
				.Where(c => !c.IsDeleted)
				
				.Include(c => c.CompanyServices)
					.ThenInclude(cs => cs.Service)
				.OrderByDescending(c => c.UserRatings.Any() ? c.UserRatings.Average(r => r.Rating) : 0)
				.ThenByDescending(c => c.UserRatings.Count())
				.Take(3)
				.AsQueryable();

			if (serviceId.HasValue)
			{
				companiesQuery = companiesQuery
					.Where(c => c.CompanyServices.Any(cs => cs.ServiceId == serviceId.Value));
			}

			var companies = await companiesQuery.ToListAsync();

			return companies.Select(p => new Model.Company
			{
				CompanyId = p.CompanyId,
				CompanyName = p.CompanyName,
				Bio = p.Bio,
				Rating = p.Rating,
				IsDeleted = p.IsDeleted,
				Email = p.Email,
				EndTime = p.EndTime,
				StartTime = p.StartTime,
				ExperianceYears = p.ExperianceYears,
				Image = p.Image,
				LocationId = p.LocationId,
				IsApplicant = p.IsApplicant,
				PhoneNumber = p.PhoneNumber,
				WorkingDays = ConvertIntToDaysOfWeekList(p.WorkingDays),
				
				CompanyServices = p.CompanyServices.Select(cs => new Model.CompanyService
				{
					CompanyId = cs.CompanyId,
					ServiceId = cs.ServiceId,
					Service = new Model.Service
					{
						ServiceId = cs.Service.ServiceId,
						ServiceName = cs.Service.ServiceName
					}
				}).ToList(),

				
			}).ToList();
		}
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

	public class CompanyEntry
	{
		[KeyType(count: 100000)]
		public uint UserId { get; set; }

		[KeyType(count: 100000)]
		public uint CompanyId { get; set; }

		public float Label { get; set; }
	}

	public class CompanyPrediction
	{
		public float Score { get; set; }
	}
}
