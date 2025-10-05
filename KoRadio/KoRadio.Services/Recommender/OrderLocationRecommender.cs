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
	public class OrderLocationRecommender : IOrderLocationRecommender
	{
		private readonly KoTiJeOvoRadioContext _context;
		private static MLContext _mlContext;
		private static ITransformer _model;
		private static readonly string ModelPath = "product-model.zip";
		private static readonly object _lock = new();

		public OrderLocationRecommender(KoTiJeOvoRadioContext context)
		{
			_context = context;
			_mlContext ??= new MLContext();
		}

		public async Task<List<Model.Product>> GetRecommendedProducts(int userId)
		{
			LoadOrTrainModel();

			var orderedProductIds = await _context.Orders
				.Where(o => o.UserId == userId)
				.SelectMany(o => o.OrderItems)
				.Select(oi => oi.ProductId)
				.Distinct()
				.ToListAsync();

			var userLocationId = await _context.Users
				.Where(u => u.UserId == userId)
				.Select(u => u.LocationId)
				.FirstOrDefaultAsync();

			var candidateProducts = await _context.Products
				.Where(p => !p.IsDeleted
					&& p.Store.LocationId == userLocationId
					&& !orderedProductIds.Contains(p.ProductId))
				.Include(p => p.Store)
				.ToListAsync();

			if (!candidateProducts.Any())
				return await GetColdStartProducts(userLocationId);

			var predictionEngine = _mlContext.Model
				.CreatePredictionEngine<ProductEntry, ProductPrediction>(_model);

			var predictions = candidateProducts
				.Select(p => new
				{
					Product = p,
					Score = predictionEngine.Predict(new ProductEntry
					{
						UserId = (uint)userId,
						ProductId = (uint)p.ProductId
					}).Score
				})
				.OrderByDescending(p => p.Score)
				.Take(3)
				.Select(p => new Model.Product
				{
					ProductId = p.Product.ProductId,
					ProductName = p.Product.ProductName,
					ProductDescription = p.Product.ProductDescription,
					Price = p.Product.Price,
					Image = p.Product.Image,
					StoreId = p.Product.StoreId
					
				})
				.ToList();

			return predictions.Any() ? predictions : await GetColdStartProducts(userLocationId);
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
			var orderEntries = _context.OrderItems
				.Select(oi => new ProductEntry
				{
					UserId = (uint)oi.Order.UserId,
					ProductId = (uint)oi.ProductId,
					Label = (float)oi.Quantity 
				})
				.ToList();

			var trainingData = _mlContext.Data.LoadFromEnumerable(orderEntries);

			var options = new MatrixFactorizationTrainer.Options
			{
				MatrixColumnIndexColumnName = nameof(ProductEntry.UserId),
				MatrixRowIndexColumnName = nameof(ProductEntry.ProductId),
				LabelColumnName = nameof(ProductEntry.Label),
				LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossRegression,
				Alpha = 0.01,
				Lambda = 0.025,
				NumberOfIterations = 50
			};

			var estimator = _mlContext.Recommendation().Trainers.MatrixFactorization(options);
			_model = estimator.Fit(trainingData);

			using var fs = new FileStream(ModelPath, FileMode.Create, FileAccess.Write, FileShare.Write);
			_mlContext.Model.Save(_model, trainingData.Schema, fs);
		}

		private async Task<List<Model.Product>> GetColdStartProducts(int locationId)
		{
			// Popular products in the same location
			var products = await _context.Products
				.Where(p => !p.IsDeleted && p.Store.LocationId == locationId)
				.Include(p => p.OrderItems)
				.OrderByDescending(p => p.OrderItems.Count())
				.Take(3)
				.ToListAsync();

			return products.Select(p => new Model.Product
			{
				ProductId = p.ProductId,
				ProductName = p.ProductName,
				ProductDescription = p.ProductDescription,
				Price = p.Price,
				Image = p.Image,
				StoreId = p.StoreId
			}).ToList();
		}

		
	

		#endregion
	}

	public class ProductEntry
	{
		[KeyType(count: 100000)]
		public uint UserId { get; set; }

		[KeyType(count: 100000)]
		public uint ProductId { get; set; }

		public float Label { get; set; }
	}

	public class ProductPrediction
	{
		public float Score { get; set; }
	}
}
