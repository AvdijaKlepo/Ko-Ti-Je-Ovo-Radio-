using KoRadio.Model;
using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KoRadio.Services
{
    public class CompanyEmployeeService: BaseCRUDServiceAsync<Model.CompanyEmployee, Model.SearchObject.CompanyEmployeeSearchObject,Database.CompanyEmployee, Model.Request.CompanyEmployeeInsertRequest, Model.Request.CompanyEmployeeUpdateRequest>, Interfaces.ICompanyEmployeeService
	{
		private readonly KoTiJeOvoRadioContext _context;
		private readonly IMapper _mapper;
		public CompanyEmployeeService(IMapper mapper, KoTiJeOvoRadioContext context): base(context, mapper)
		{
			_context = context;
			_mapper = mapper;
		}

		public override IQueryable<KoRadio.Services.Database.CompanyEmployee> AddFilter(CompanyEmployeeSearchObject search, IQueryable<KoRadio.Services.Database.CompanyEmployee> query)
		{
			
			//query = query.Include(x => x.User);
			//query = query.Include(x => x.Company).ThenInclude(x=>x.CompanyRoles);

			if(search.CompanyId!=null)
			{
				query = query.Where(x => x.CompanyId == search.CompanyId);
			}
			if (search.UserId!=null)
			{
				query = query.Where(x => x.User.UserId == search.UserId);
			}
			if (search.IsApplicant == true)
			{
				query = query.Where(x => x.IsApplicant == true);
			}
			else
			{
				query = query.Where(x => x.IsApplicant == false);
			}
			if(search?.Name!=null)
			{
			
				query = query.Where(x => (x.User.FirstName + " " + x.User.LastName).StartsWith( search.Name));
		
			}
			if(search?.EmployeeRole!=null)
			{
				query = query.Where(x => x.CompanyRoleId == search.EmployeeRole);
			}
			if(search?.IsDeleted==true)
			{
				query = query.Where(x => x.IsDeleted == true);
			}
			else
			{
				query = query.Where(x => x.IsDeleted == false);
			}
		





				return base.AddFilter(search, query);
		}
		public override async Task AfterUpdateAsync(CompanyEmployeeUpdateRequest request, Database.CompanyEmployee entity, CancellationToken cancellationToken = default)
		{
		

			await base.AfterUpdateAsync(request, entity, cancellationToken);
		}
		public override async Task BeforeUpdateAsync(CompanyEmployeeUpdateRequest request, Database.CompanyEmployee entity, CancellationToken cancellationToken = default)
		{
			if (request.IsApplicant == false && entity.IsApplicant == true)
			{
				if (request.Roles != null && request.Roles.Any())
				{

					var existingRoleIds = _context.UserRoles
						.Where(ur => ur.UserId == entity.UserId)
						.Select(ur => ur.RoleId)
						.ToHashSet();

					foreach (var roleId in request.Roles.Distinct())
					{
						if (!existingRoleIds.Contains(roleId))
						{
							_context.UserRoles.Add(new Database.UserRole
							{
								UserId = entity.UserId,
								RoleId = roleId,
								ChangedAt = DateTime.Now,
								CreatedAt = DateTime.Now
							});
						}
					}

					_context.SaveChanges();
				}
			}

			await base.BeforeUpdateAsync(request, entity, cancellationToken);
		}
		public override async Task BeforeInsertAsync(CompanyEmployeeInsertRequest request, KoRadio.Services.Database.CompanyEmployee entity, CancellationToken cancellationToken = default)
		{
			var requestedUser = await _context.Users
			 .Where(x => x.Email == request.Email)
			 .FirstOrDefaultAsync(cancellationToken);

			if (requestedUser == null)
				throw new UserException("Korisnik sa unesenim emailom ne postoji.");

			entity.UserId = requestedUser.UserId;
			entity.DateJoined = DateTime.UtcNow;
			entity.IsApplicant = true;
			entity.IsDeleted = false;
			

			await base.BeforeInsertAsync(request, entity, cancellationToken);
		}
		protected override Task<(bool IsHandled, Model.CompanyEmployee? CustomMapped)> TryManualProjectionAsync(KoRadio.Services.Database.CompanyEmployee entity)
		{
			var custom = _context.CompanyEmployees
		.Where(x => x.CompanyEmployeeId == entity.CompanyEmployeeId)
		.Select(x => new Model.CompanyEmployee
		{
			CompanyEmployeeId = x.CompanyEmployeeId,
			UserId = x.UserId,
			CompanyId = x.CompanyId,
			IsApplicant = x.IsApplicant,
			IsDeleted = x.IsDeleted,
			CompanyRoleId = x.CompanyRoleId,
			DateJoined = x.DateJoined,
			CompanyName = x.Company.CompanyName,
			CompanyRoleName = x.CompanyRole.RoleName,
			IsOwner=x.IsOwner,
			User = new Model.DTOs.UserDTO
			{
				UserId = x.User.UserId,
				FirstName = x.User.FirstName,
				LastName = x.User.LastName,
				Email = x.User.Email,
				PhoneNumber = x.User.PhoneNumber,
			}
		})
		.FirstOrDefault();

			return Task.FromResult((true, custom));
			
		}

	

	}
}
