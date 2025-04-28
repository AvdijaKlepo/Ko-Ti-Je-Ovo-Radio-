using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using KoRadio.Model;
using KoRadio.Model.Request;
using KoRadio.Model.SearchObject;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using User = KoRadio.Services.Database.User;

namespace KoRadio.Services
{
	public class UserService:BaseCRUDService<Model.User,UserSearchObject,Database.User,UserInsertRequest,UserUpdateRequest>,IUserService
	{
		public UserService(KoTiJeOvoRadioContext context, IMapper mapper) : base(context, mapper)
		{
		}

		public override IQueryable<User> AddFilter(UserSearchObject searchObject, IQueryable<User> query)
		{
			query = base.AddFilter(searchObject, query);

			query = query.GroupJoin(
							_context.Freelancers,
							user => user.UserId,
							freelancer => freelancer.UserId,
							(user, freelancer) => new { user, freelancer }
						)
						.Where(x => !x.freelancer.Any()) 
						.Select(x => x.user);


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

		
			

			return query;
		}

		public override void BeforeInsert(UserInsertRequest request, User entity)
		{
			if (request.Password!=request.ConfirmPassword)
			{
				throw new Exception("Lozinke se ne poklapaju!");
			}
			entity.PasswordSalt = GenerateSalt();
			entity.PasswordHash = GenerateHash(entity.PasswordSalt, request.Password);
			base.BeforeInsert(request, entity);

		}

		public override void BeforeUpdate(UserUpdateRequest request, User entity)
		{
			if (request.Password != request.ConfirmPassword)
			{
				throw new Exception("Lozinke se ne poklapaju!");
				
			}
			entity.PasswordSalt = GenerateSalt();
			entity.PasswordHash = GenerateHash(entity.PasswordSalt, request.Password);
			base.BeforeUpdate(request, entity);
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

		public Model.User Login(string username, string password)
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

			return _mapper.Map<Model.User>(entity);
		}
	}
}
