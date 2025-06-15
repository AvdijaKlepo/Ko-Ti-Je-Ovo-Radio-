using KoRadio.API;
using KoRadio.Services;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using KoRadio.Services.RabbitMQ;
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

app.Run();
