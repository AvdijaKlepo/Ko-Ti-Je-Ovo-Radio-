using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services
{
	public class OrderService : BaseCRUDServiceAsync<Model.Order, OrderSearchObject, Database.Order, OrderInsertRequest, OrderUpdateRequest>, IOrderService
	{
		public OrderService(KoTiJeOvoRadioContext context, IMapper mapper) : base(context, mapper)
		{

			
		}

		public override IQueryable<Order> AddFilter(OrderSearchObject search, IQueryable<Order> query)
		{
			query = query.Include(x => x.OrderItems).ThenInclude(x=>x.Product).Include(x=>x.User);

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

		public override async Task AfterInsertAsync(
			OrderInsertRequest request,
			Database.Order entity,
			CancellationToken cancellationToken = default)
		{
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
							TotalQty = g.Sum(x => x.Quantity)
						});

					foreach (var g in grouped)
					{
						_context.OrderItems.Add(new Database.OrderItem
						{
							OrderId = entity.OrderId,
							ProductId = g.ProductId,
							StoreId = g.StoreId,
							Quantity = g.TotalQty
						});
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
