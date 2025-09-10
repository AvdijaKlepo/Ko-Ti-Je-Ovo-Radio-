using DotNetEnv;
using KoRadio.API;
using KoRadio.Model;
using KoRadio.Services;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using KoRadio.Services.RabbitMQ;
using KoRadio.Services.Recommender;
using KoRadio.Services.Recommender;
using KoRadio.Services.SignalRService;
using Mapster;
using MapsterMapper;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using System.Text.Json;
using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);


builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IFreelanceService, FreelanacerService>();
builder.Services.AddTransient<IServicesService, ServicesService>();
builder.Services.AddTransient<IJobService, JobService>();
builder.Services.AddTransient<ILocationService, LocationService>();
builder.Services.AddTransient<IMessageService, MessageService>();
builder.Services.AddTransient<IUserRatings, UserRatingService>();
builder.Services.AddTransient<ICompanyService, KoRadio.Services.CompanyService>();
builder.Services.AddTransient<ICompanyEmployeeService, CompanyEmployeeService>();
builder.Services.AddTransient<ICompanyRoleService, CompanyRoleService>();
builder.Services.AddTransient<ICompanyJobAssignment, CompanyJobAssignmentService>();
builder.Services.AddTransient<IStoreService, KoRadio.Services.StoreService>();
builder.Services.AddTransient<IProductService, KoRadio.Services.ProductService>();
builder.Services.AddTransient<IOrderService, KoRadio.Services.OrderService>();
builder.Services.AddTransient<ITenderService, KoRadio.Services.TenderService>();
builder.Services.AddTransient<ITenderBidService, KoRadio.Services.TenderBidService>();
builder.Services.AddTransient<IEmployeeTaskService, KoRadio.Services.EmployeeTaskService>();
builder.Services.AddScoped<IUserGradeRecommenderService, UserGradeRecommenderService>();
builder.Services.AddScoped<ICompanyRecommenderService, CompanyRecommenderService>();
builder.Services.AddScoped<IOrderLocationRecommender, OrderLocationRecommender>();
builder.Services.AddScoped<ISignalRHubService, SignalRHubService>();
builder.Services.AddScoped<IRabbitMQService, RabbitMQService>();
builder.Services.AddSingleton<IUserIdProvider, CustomUserIdProvider>();

builder.Services.AddSignalR();

builder.Services.AddControllers(options =>
{
	options.Filters.Add<ExceptionFilter>();
})
.AddJsonOptions(options =>
{
options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter());
	options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
	
});



// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
	c.AddSecurityDefinition("basicAuth", new Microsoft.OpenApi.Models.OpenApiSecurityScheme()
	{
		Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
		Scheme = "basic"
	});

	c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement()
	{
		{
			new OpenApiSecurityScheme
			{
				Reference = new OpenApiReference{Type = ReferenceType.SecurityScheme, Id = "basicAuth"}
			},
			new string[]{}
	} });

});





var connectionString = builder.Configuration.GetConnectionString("KoRadio");

builder.Services.AddDbContext<KoTiJeOvoRadioContext>(options =>
	options.UseSqlServer(connectionString));

builder.Services.AddMapster();
builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

MapsterConfig.RegisterMappings();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.Use(async (context, next) =>
{
	try
	{
		await next();
	}
	catch (Exception ex)
	{
		var logger = context.RequestServices.GetRequiredService<ILogger<Program>>();
		logger.LogError(ex, ex.Message);

		if (!context.Response.HasStarted)
		{
			context.Response.StatusCode = 500;
			context.Response.ContentType = "application/json";
			var result = JsonSerializer.Serialize(new
			{
				errors = new { general = new[] { "Server error, check logs." } }
			});
			await context.Response.WriteAsync(result);
		}
	}
});
app.MapHub<SignalRHubService>("/notifications-hub");
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
//using (var scope = app.Services.CreateScope())
//{
//	var dataContext = scope.ServiceProvider.GetRequiredService<KoTiJeOvoRadioContext>();
//	dataContext.Database.Migrate();
//}

app.Run();
