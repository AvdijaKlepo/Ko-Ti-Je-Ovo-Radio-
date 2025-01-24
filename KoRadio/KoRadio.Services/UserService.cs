using System;
using System.Collections.Generic;
using System.Linq;
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

namespace KoRadio.Services
{
	public class UserService:IUserService
	{
		private readonly KoTiJeOvoRadioContext _context;
		private readonly IMapper _mapper;

		public UserService(KoTiJeOvoRadioContext context,IMapper mapper)
		{
			_context = context;
			_mapper = mapper;
		}

		public List<UserModel> GetUsers(UserSearchObject searchObject)
		{
			List<UserModel> result = new();
			var query = _context.Users.AsQueryable();

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
				query = query.Where(x => x.Email.StartsWith(searchObject.Email));
			}

			if (searchObject?.IsUserRolesIncluded==true)
			{
				query = query.Include(x => x.UserRoles).ThenInclude(x => x.Role);
			}

			var list = query.ToList();
			result = _mapper.Map(list, result);
			return result;
		}

		public UserModel Insert(UserInsertRequest request)
		{
			if (request.Password != request.ConfirmPassword)
			{
				throw new Exception("Lozinke se ne poklapaju!");
			}

			User entity = new User();
			_mapper.Map(request, entity);
			entity.PasswordSalt = GenerateSalt();
			entity.PasswordHash = GenerateHash(entity.PasswordSalt,request.Password);
			_context.Add(entity);
			_context.SaveChanges();

			return _mapper.Map<UserModel>(entity);
		}

		public UserModel Update(int id, UserUpdateRequest request)
		{
			var entity = _context.Users.Find(id);
			_mapper.Map(request, entity);
			if (request.Password != request.ConfirmPassword)
			{
				throw new Exception("Lozinke se ne poklapaju!");
				entity.PasswordSalt = GenerateSalt();
				entity.PasswordHash = GenerateHash(entity.PasswordSalt, request.Password);
			}
			
			_context.SaveChanges();

			return _mapper.Map<UserModel>(entity);
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
	}
}
