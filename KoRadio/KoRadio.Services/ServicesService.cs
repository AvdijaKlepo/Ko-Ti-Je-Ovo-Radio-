﻿using KoRadio.Model.Request;
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
    public class ServicesService:BaseCRUDServiceAsync<Model.Service, ServiceSearchObject, Database.Service, ServiceInsertRequest, ServiceUpdateRequest>,IServicesService
    {
        public ServicesService(KoTiJeOvoRadioContext context, IMapper mapper) : base(context, mapper)
		{
		}
		public override IQueryable<Service> AddFilter(ServiceSearchObject searchObject, IQueryable<Service> query)
		{


			query = base.AddFilter(searchObject, query);
			query = query.Include(x => x.FreelancerServices).ThenInclude(x => x.Freelancer).Include(x => x.CompanyServices).ThenInclude(x => x.Company);
			if (!string.IsNullOrWhiteSpace(searchObject?.ServiceName))
			{
				query = query.Where(x => x.ServiceName.StartsWith(searchObject.ServiceName));
			}
			
		

		








			return query;
		}

	
	}
}
