using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using KoRadio.Services.RabbitMQ;
using KoRadio.Services.SignalRService;
using MapsterMapper;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Subscriber;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services
{
	public class OrderService : BaseCRUDServiceAsync<Model.Order, OrderSearchObject, Database.Order, OrderInsertRequest, OrderUpdateRequest>, IOrderService
	{
		string signalRMessage = "Nova notifikacija je stigla.";
		private readonly IRabbitMQService _rabbitMQService;
		private readonly IHubContext<SignalRHubService> _hubContext;
		private readonly IMessageService _messageService;
		public OrderService(KoTiJeOvoRadioContext context, IMapper mapper,IRabbitMQService rabbitMQService, IHubContext<SignalRHubService> hubContext, IMessageService messageService) : base(context, mapper)
		{
			_rabbitMQService = rabbitMQService;
			_hubContext = hubContext;
			_messageService = messageService;

		}

		public override IQueryable<Order> AddFilter(OrderSearchObject search, IQueryable<Order> query)
		{
			query = query.Include(x => x.OrderItems).ThenInclude(x=>x.Product).ThenInclude(x=>x.Store).Include(x=>x.User);

			if(search.UserId!=null)
			{
				query = query.Where(x => x.UserId == search.UserId);
			}
			if (search.StoreId!=null)
			{
				query = query
		.Where(x => x.OrderItems.Any(oi => oi.StoreId == search.StoreId))
		.Select(x => new Order
		{
			OrderId = x.OrderId,
			OrderNumber=x.OrderNumber,
			CreatedAt=x.CreatedAt,
			IsCancelled=x.IsCancelled,
			IsShipped=x.IsShipped,
			UserId=x.UserId,
			User = x.User,
			
			OrderItems = x.OrderItems.Where(oi => oi.StoreId == search.StoreId).ToList(),
			
		});

			}
			if(search.Name!=null)
			{
				
				query = query.Where(x => (x.User.FirstName + " " + x.User.LastName).StartsWith(search.Name));
			
			}
			if (search.IsShipped != null)
			{
				query = query.Where(x => x.IsShipped == search.IsShipped);
			}

			if (search.IsCancelled != null)
			{
				query = query.Where(x => x.IsCancelled == search.IsCancelled);
			}

			return base.AddFilter(search, query);
		}



		public override Task BeforeInsertAsync(
		OrderInsertRequest request,
		Database.Order entity,
		CancellationToken cancellationToken = default)
		{
			entity.OrderItems.Clear();          
			return base.BeforeInsertAsync(request, entity, cancellationToken);
		}
		public override async Task BeforeUpdateAsync(OrderUpdateRequest request, Order entity, CancellationToken cancellationToken = default)
		{
			string notification;

			var order = await _context.Orders
				.Include(x => x.User)
				.FirstOrDefaultAsync(x => x.OrderId == entity.OrderId, cancellationToken);

			if (request.IsShipped == true && entity.IsShipped == false)
			{
				notification = $"Vaša narudžba broj #{order.OrderNumber} je poslana.";
				await _hubContext.Clients.User(entity.UserId.ToString())
				.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);


				var insertRequest = new MessageInsertRequest
				{
					Message1 = notification,
					UserId = entity.UserId,
					CreatedAt = DateTime.Now,
					IsOpened = false
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);

			}
			if(request.IsCancelled==true)
			{
				notification = $"Vaša narudžba broj #{order.OrderNumber} je otkazana.";
				await _hubContext.Clients.User(entity.UserId.ToString())
				.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);


				var insertRequest = new MessageInsertRequest
				{
					Message1 = notification,
					UserId = entity.UserId,
					CreatedAt = DateTime.Now,
					IsOpened = false
				};

				await _messageService.InsertAsync(insertRequest, cancellationToken);
			}
			

			await base.BeforeUpdateAsync(request, entity, cancellationToken);
		}
		

		public override async Task AfterInsertAsync(
			OrderInsertRequest request,
			Database.Order entity,
			CancellationToken cancellationToken = default)
		{
			string notification;


			notification = $"Novi narudžba pristigla.";
			using var tx = await _context.Database.BeginTransactionAsync(cancellationToken);
			try
			{
				if (request.OrderItems?.Any() == true)
				{
					var grouped = request.OrderItems
						.GroupBy(i => new { i.ProductId, i.StoreId })
						.Select(g => new
						{
							g.Key.ProductId,
							g.Key.StoreId,
							TotalQty = g.Sum(x => x.Quantity),
							ProductPrice = g.First().ProductPrice
						});

					foreach (var g in grouped)
					{
						_context.OrderItems.Add(new Database.OrderItem
						{
							OrderId = entity.OrderId,
							ProductId = g.ProductId,
							StoreId = g.StoreId,
							Quantity = g.TotalQty,
							ProductPrice=g.ProductPrice
						});
						await _hubContext.Clients.User(g.StoreId.ToString())
				.SendAsync("ReceiveNotification", signalRMessage, cancellationToken);


						var insertRequest = new MessageInsertRequest
						{
							Message1 = notification,
							StoreId = g.StoreId,
							CreatedAt = DateTime.Now,
							IsOpened = false
						};

						await _messageService.InsertAsync(insertRequest, cancellationToken);

						Console.WriteLine("Notification sent and saved: ");

					}

					await _context.SaveChangesAsync(cancellationToken);
					await tx.CommitAsync(cancellationToken);
				}
			}
			catch
			{
				await tx.RollbackAsync(cancellationToken);
				throw;
			}

		}

		}
}
