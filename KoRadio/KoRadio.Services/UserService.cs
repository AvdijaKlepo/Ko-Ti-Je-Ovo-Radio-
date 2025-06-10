using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Azure.Core;
using KoRadio.Model;
using KoRadio.Model.DTOs;
using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using KoRadio.Services.SignalRService;
using MapsterMapper;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;
using User = KoRadio.Services.Database.User;


namespace KoRadio.Services
{
	public class UserService:BaseCRUDServiceAsync<Model.User,UserSearchObject,Database.User,UserInsertRequest,UserUpdateRequest>,IUserService
	{
		private readonly IHubContext<SignalRHubService> _hubContext;
		public UserService(KoTiJeOvoRadioContext context, IMapper mapper, IHubContext<SignalRHubService> hubContext) : base(context, mapper)
		{
			_hubContext = hubContext;
		}

		public override IQueryable<User> AddFilter(UserSearchObject searchObject, IQueryable<User> query)
		{
			query = base.AddFilter(searchObject, query);

			


			query = query.Include(x => x.Location);
			query = query.Where(x => x.IsDeleted == false);


			if (!string.IsNullOrWhiteSpace(searchObject?.FirstNameGTE))
			{
				query = query.Where(x => x.FirstName.StartsWith(searchObject.FirstNameGTE));
			}

			if (!string.IsNullOrWhiteSpace(searchObject?.LastNameGTE))
			{
				query = query.Where(x => x.LastName.StartsWith(searchObject.LastNameGTE));
			}

			if (!string.IsNullOrWhiteSpace(searchObject?.Email))
			{
				query = query.Where(x => x.Email == searchObject.Email);
			}


			if (searchObject.IsUserRolesIncluded == true)
			{
				query = query.Include(x => x.UserRoles).ThenInclude(x => x.Role);
			}

			if(searchObject.IsFreelancerIncluded==false)
			{
				query = FilterOutFreelancers(query);
			}
			if(searchObject.isDeleted==true)
			{
				query = query.Where(x => x.IsDeleted == true);
			}
			
		
			

			return query;
		}
		private IQueryable<User> FilterOutFreelancers(IQueryable<User> query)
		{
			return query
				.GroupJoin(
					_context.Freelancers,
					user => user.UserId,
					freelancer => freelancer.FreelancerNavigation.UserId,
					(user, freelancer) => new { user, freelancer }
				)
				.Where(x => !x.freelancer.Any())
				.Select(x => x.user);
		}
		public override async Task AfterInsertAsync(UserInsertRequest request, User entity, CancellationToken cancellationToken = default)
		{
			if (request.Roles != null && request.Roles.Any())
			{
				foreach (var roleId in request.Roles)
				{
					_context.UserRoles.Add(new Database.UserRole
					{
						UserId = entity.UserId,
						RoleId = roleId,
						ChangedAt = DateTime.UtcNow,
						CreatedAt = DateTime.UtcNow
					});
				}
				_context.SaveChanges();
			}
			await base.AfterInsertAsync(request, entity, cancellationToken);
		}

		public override async Task BeforeInsertAsync(UserInsertRequest request, User entity, CancellationToken cancellationToken = default)
		{
			if (request.Password != request.ConfirmPassword)
			{
				throw new UserException("Lozinke se ne poklapaju!");
			}
			entity.PasswordSalt = GenerateSalt();
			entity.PasswordHash = GenerateHash(entity.PasswordSalt, request.Password);
			entity.CreatedAt = DateTime.Now;
			entity.IsDeleted = false;
			await base.BeforeInsertAsync(request, entity, cancellationToken);
		}


		public override async Task BeforeUpdateAsync(UserUpdateRequest request, User entity, CancellationToken cancellationToken = default)
		{
			if (!string.IsNullOrWhiteSpace(request.Password) || !string.IsNullOrWhiteSpace(request.ConfirmPassword))
			{
				if (request.Password != request.ConfirmPassword)
				{
					throw new UserException("Lozinke se ne poklapaju!");
				}

				entity.PasswordSalt = GenerateSalt();
				entity.PasswordHash = GenerateHash(entity.PasswordSalt, request.Password);
			}

			await base.BeforeUpdateAsync(request, entity, cancellationToken);
		}




		public static string GenerateSalt()
		{
			var byteArray = RNGCryptoServiceProvider.GetBytes(16);


			return Convert.ToBase64String(byteArray);
		}
		public static string GenerateHash(string salt, string password)
		{
			byte[] src = Convert.FromBase64String(salt);
			byte[] bytes = Encoding.Unicode.GetBytes(password);
			byte[] dst = new byte[src.Length + bytes.Length];

			System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
			System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

			HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
			byte[] inArray = algorithm.ComputeHash(dst);
			return Convert.ToBase64String(inArray);
		}

		public Model.User Login(string username, string password, string connectionId)
		{
			

			var entity = _context.Users.Include(x => x.UserRoles).ThenInclude(y => y.Role).FirstOrDefault(x => x.Email == username);

			if (entity == null)
			{
				return null;
			}

			var hash = GenerateHash(entity.PasswordSalt, password);

			if (hash != entity.PasswordHash)
			{
				return null;
			}
			if (connectionId != "")
			{
				_hubContext.Groups.AddToGroupAsync(connectionId, username);
			}

			return Mapper.Map<Model.User>(entity);
		}
		public async Task<Model.DTOs.UserDTO> Registration(UserInsertRequest request)
		{
			
			await using var transaction = await _context.Database.BeginTransactionAsync();

			try
			{
				
				var emailInUse = await _context.Users.AnyAsync(u => u.Email == request.Email);
				if (emailInUse)
					throw new UserException("Email se već koristi.");

				var emailRegex = new Regex(@"^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$");
				if (!emailRegex.IsMatch(request.Email))
					throw new UserException("Pogrešan format emaila");



				User entity = Mapper.Map<User>(request);

				await BeforeInsertAsync(request, entity);

	
				_context.Users.Add(entity);
				await _context.SaveChangesAsync();

		
				if (request.Roles != null && request.Roles.Any())
				{
					foreach (var roleId in request.Roles)
					{
						_context.UserRoles.Add(new Database.UserRole
						{
							UserId = entity.UserId,
							RoleId = roleId,
							CreatedAt = DateTime.UtcNow,
							ChangedAt = DateTime.UtcNow
						});
					}
					await _context.SaveChangesAsync();
				}

	
				await transaction.CommitAsync();

	
				entity.Location = await _context.Locations
											   .FirstOrDefaultAsync(l => l.LocationId == entity.LocationId);
				entity.UserRoles = await _context.UserRoles
										  .Where(ur => ur.UserId == entity.UserId)
										  .Include(ur => ur.Role)
										  .ToListAsync();

		
				return Mapper.Map<Model.DTOs.UserDTO>(entity);
			}
			catch
			{
				await transaction.RollbackAsync();
				throw;
			}
		}




	}
}
