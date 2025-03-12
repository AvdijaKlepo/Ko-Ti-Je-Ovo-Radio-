using KoRadio.API;
using KoRadio.Services;
using KoRadio.Services.Database;
using KoRadio.Services.Interfaces;
using Mapster;
using MapsterMapper;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<IWorkerService, WorkerService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddControllers();
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


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
