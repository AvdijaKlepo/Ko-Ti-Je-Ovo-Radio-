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
    public class CompanyJobAssignmentService: BaseCRUDServiceAsync<Model.CompanyJobAssignment, Model.SearchObject.CompanyJobAssignmentSearchObject,Database.CompanyJobAssignment, Model.Request.CompanyJobAssignmentInsertRequest, Model.Request.CompanyJobAssignmentUpdateRequest>, Interfaces.ICompanyJobAssignment
	{
		public CompanyJobAssignmentService(IMapper mapper, KoTiJeOvoRadioContext context) : base(context, mapper)
		{

		}

		public override IQueryable<CompanyJobAssignment> AddFilter(CompanyJobAssignmentSearchObject search, IQueryable<CompanyJobAssignment> query)
		{
			query = query.Include(x => x.CompanyEmployee).ThenInclude(x => x.User);
			query = query.Include(x => x.Job);
			if (search.JobId!=null)
			{
				query = query.Where(x => x.JobId == search.JobId);
			}
			if(search.IsFinished!=null)
			{
				query = query.Where(x => x.IsFinished == search.IsFinished);
			}
			if (search.IsCancelled !=null)
			{
				query = query.Where(x => x.IsCancelled == search.IsCancelled);
			}
			if (search.CompanyEmployeeId!=null)
			{
				query = query.Where(x => x.CompanyEmployeeId == search.CompanyEmployeeId);
			}
			if (search?.JobDate != null && search?.DateRange != null)
			{
				var jobDate = search.JobDate.Value.Date;
				var chosenDate = search.DateRange.Value.Date;

				query = query.Where(j =>
		
					j.Job.JobDate <= chosenDate &&
				
					(j.Job.DateFinished ?? j.Job.JobDate) >= jobDate
				);
			}
			else if (search?.JobDate != null)
			{
				var jobDate = search.JobDate.Value.Date;

				query = query.Where(j =>
					j.Job.JobDate <= jobDate &&
					(j.Job.DateFinished ?? j.Job.JobDate) >= jobDate
				);
			}
			else if (search?.DateRange != null)
			{
				var chosenDate = search.DateRange.Value.Date;

				query = query.Where(j =>
					j.Job.JobDate <= chosenDate &&
					(j.Job.DateFinished ?? j.Job.JobDate) >= chosenDate
				);
			}








			return base.AddFilter(search, query);
		}

		public override async Task BeforeInsertAsync(CompanyJobAssignmentInsertRequest request, CompanyJobAssignment entity, CancellationToken cancellationToken = default)
		{
			
			await base.BeforeInsertAsync(request, entity, cancellationToken);
		}

		public override async Task AfterInsertAsync(CompanyJobAssignmentInsertRequest request, CompanyJobAssignment entity, CancellationToken cancellationToken = default)
		{
			var exists = await _context.CompanyJobAssignments.Where(
				x=>x.JobId==request.JobId && x.CompanyEmployeeId==request.CompanyEmployeeId
				&& x.CompanyJobId!=entity.CompanyJobId).ToListAsync(cancellationToken);
			var doesntExits = await _context.CompanyJobAssignments.Where(
				x => x.JobId == request.JobId && x.CompanyEmployeeId != request.CompanyEmployeeId
				&& x.CompanyJobId != entity.CompanyJobId).ToListAsync(cancellationToken);
			if (exists.Any())
			{
				if (doesntExits.Any())
				{
					
						_context.CompanyJobAssignments.RemoveRange(doesntExits);
					

					await _context.SaveChangesAsync(cancellationToken);
					_context.CompanyJobAssignments.RemoveRange(exists);
				}
				else
					_context.CompanyJobAssignments.RemoveRange(exists);
					

				await _context.SaveChangesAsync(cancellationToken);
			}

			
			
			
				
			await base.AfterInsertAsync(request, entity, cancellationToken);
		}
	}
}
