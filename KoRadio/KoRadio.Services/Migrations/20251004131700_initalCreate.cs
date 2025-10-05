using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace KoRadio.Services.Migrations
{
    /// <inheritdoc />
    public partial class initalCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Locations",
                columns: table => new
                {
                    LocationID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    LocationName = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Location__E7FEA4779B95C597", x => x.LocationID);
                });

            migrationBuilder.CreateTable(
                name: "Roles",
                columns: table => new
                {
                    RoleID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    RoleName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    RoleDescription = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Roles__8AFACE3A92DD3D4B", x => x.RoleID);
                });

            migrationBuilder.CreateTable(
                name: "Service",
                columns: table => new
                {
                    ServiceID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceName = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Image = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Service__C51BB0EAAC6763C6", x => x.ServiceID);
                });

            migrationBuilder.CreateTable(
                name: "Company",
                columns: table => new
                {
                    CompanyID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Bio = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Rating = table.Column<decimal>(type: "decimal(3,2)", nullable: true),
                    PhoneNumber = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    ExperianceYears = table.Column<int>(type: "int", nullable: false),
                    Image = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    WorkingDays = table.Column<int>(type: "int", nullable: false),
                    StartTime = table.Column<TimeOnly>(type: "time", nullable: false),
                    EndTime = table.Column<TimeOnly>(type: "time", nullable: false),
                    LocationID = table.Column<int>(type: "int", nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    IsApplicant = table.Column<bool>(type: "bit", nullable: false),
                    CompanyName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    TotalRatings = table.Column<int>(type: "int", nullable: false),
                    RatingSum = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    BusinessCertificate = table.Column<byte[]>(type: "varbinary(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Company__2D971C4CB07C8C16", x => x.CompanyID);
                    table.ForeignKey(
                        name: "FK__Company__Locatio__0F2D40CE",
                        column: x => x.LocationID,
                        principalTable: "Locations",
                        principalColumn: "LocationID");
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    UserID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FirstName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    LastName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    PasswordHash = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    PasswordSalt = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    Image = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    LocationID = table.Column<int>(type: "int", nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    PhoneNumber = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Address = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Users__1788CCACDE55EC71", x => x.UserID);
                    table.ForeignKey(
                        name: "FK__Users__LocationI__0E391C95",
                        column: x => x.LocationID,
                        principalTable: "Locations",
                        principalColumn: "LocationID");
                });

            migrationBuilder.CreateTable(
                name: "CompanyRole",
                columns: table => new
                {
                    CompanyRoleId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CompanyID = table.Column<int>(type: "int", nullable: true),
                    RoleName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__CompanyR__9CF06B50EF6710FD", x => x.CompanyRoleId);
                    table.ForeignKey(
                        name: "FK__CompanyRo__Compa__7AF13DF7",
                        column: x => x.CompanyID,
                        principalTable: "Company",
                        principalColumn: "CompanyID");
                });

            migrationBuilder.CreateTable(
                name: "CompanyService",
                columns: table => new
                {
                    CompanyID = table.Column<int>(type: "int", nullable: false),
                    ServiceID = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__CompanyS__91C6A7424FCFED49", x => new { x.CompanyID, x.ServiceID });
                    table.ForeignKey(
                        name: "FK__CompanySe__Compa__1F98B2C1",
                        column: x => x.CompanyID,
                        principalTable: "Company",
                        principalColumn: "CompanyID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK__CompanySe__Servi__208CD6FA",
                        column: x => x.ServiceID,
                        principalTable: "Service",
                        principalColumn: "ServiceID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Freelancer",
                columns: table => new
                {
                    FreelancerID = table.Column<int>(type: "int", nullable: false),
                    Bio = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Rating = table.Column<decimal>(type: "decimal(3,2)", nullable: false),
                    ExperianceYears = table.Column<int>(type: "int", nullable: false),
                    WorkingDays = table.Column<int>(type: "int", nullable: false),
                    StartTime = table.Column<TimeOnly>(type: "time", nullable: false),
                    EndTime = table.Column<TimeOnly>(type: "time", nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    IsApplicant = table.Column<bool>(type: "bit", nullable: false),
                    TotalRatings = table.Column<int>(type: "int", nullable: true, defaultValue: 0),
                    RatingSum = table.Column<double>(type: "float", nullable: true, defaultValue: 0.0),
                    CV = table.Column<byte[]>(type: "varbinary(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Freelanc__3D00E30C80E0E635", x => x.FreelancerID);
                    table.ForeignKey(
                        name: "FK__Freelance__Freel__1B9317B3",
                        column: x => x.FreelancerID,
                        principalTable: "Users",
                        principalColumn: "UserID");
                });

            migrationBuilder.CreateTable(
                name: "Orders",
                columns: table => new
                {
                    OrderId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    OrderNumber = table.Column<int>(type: "int", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    IsCancelled = table.Column<bool>(type: "bit", nullable: false),
                    IsShipped = table.Column<bool>(type: "bit", nullable: false),
                    Price = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Orders__C3905BCF591ED19A", x => x.OrderId);
                    table.ForeignKey(
                        name: "FK_Orders_Users",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserID");
                });

            migrationBuilder.CreateTable(
                name: "Stores",
                columns: table => new
                {
                    StoreId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    StoreName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    IsApplicant = table.Column<bool>(type: "bit", nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    LocationId = table.Column<int>(type: "int", nullable: false),
                    Image = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    BusinessCertificate = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    WorkingDays = table.Column<int>(type: "int", nullable: false),
                    StartTime = table.Column<TimeOnly>(type: "time", nullable: false),
                    EndTime = table.Column<TimeOnly>(type: "time", nullable: false),
                    Rating = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    TotalRatings = table.Column<int>(type: "int", nullable: true),
                    RatingSum = table.Column<double>(type: "float", nullable: true),
                    Address = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    StoreCatalogue = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    StoreCataloguePublish = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Stores__3B82F10142B7B44A", x => x.StoreId);
                    table.ForeignKey(
                        name: "FK_Stores_Users",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserID");
                    table.ForeignKey(
                        name: "FK__Stores__Location__4460231C",
                        column: x => x.LocationId,
                        principalTable: "Locations",
                        principalColumn: "LocationID");
                });

            migrationBuilder.CreateTable(
                name: "UserRoles",
                columns: table => new
                {
                    UserRoleID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserID = table.Column<int>(type: "int", nullable: false),
                    RoleID = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: false),
                    ChangedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__UserRole__3D978A551693E34E", x => x.UserRoleID);
                    table.ForeignKey(
                        name: "FK__UserRoles__RoleI__16CE6296",
                        column: x => x.RoleID,
                        principalTable: "Roles",
                        principalColumn: "RoleID");
                    table.ForeignKey(
                        name: "FK__UserRoles__UserI__15DA3E5D",
                        column: x => x.UserID,
                        principalTable: "Users",
                        principalColumn: "UserID");
                });

            migrationBuilder.CreateTable(
                name: "CompanyEmployee",
                columns: table => new
                {
                    CompanyEmployeeID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserID = table.Column<int>(type: "int", nullable: false),
                    CompanyID = table.Column<int>(type: "int", nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    IsApplicant = table.Column<bool>(type: "bit", nullable: false),
                    IsOwner = table.Column<bool>(type: "bit", nullable: false),
                    CompanyRoleId = table.Column<int>(type: "int", nullable: true),
                    DateJoined = table.Column<DateTime>(type: "datetime", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__CompanyE__3916BD7B00AC7565", x => x.CompanyEmployeeID);
                    table.ForeignKey(
                        name: "FK__CompanyEm__Compa__69C6B1F5",
                        column: x => x.CompanyID,
                        principalTable: "Company",
                        principalColumn: "CompanyID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK__CompanyEm__Compa__7BE56230",
                        column: x => x.CompanyRoleId,
                        principalTable: "CompanyRole",
                        principalColumn: "CompanyRoleId");
                    table.ForeignKey(
                        name: "FK__CompanyEm__UserI__68D28DBC",
                        column: x => x.UserID,
                        principalTable: "Users",
                        principalColumn: "UserID");
                });

            migrationBuilder.CreateTable(
                name: "FreelancerService",
                columns: table => new
                {
                    FreelancerID = table.Column<int>(type: "int", nullable: false),
                    ServiceID = table.Column<int>(type: "int", nullable: false),
                    CreatedAT = table.Column<DateTime>(type: "datetime", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Freelanc__815158029BB39A82", x => new { x.FreelancerID, x.ServiceID });
                    table.ForeignKey(
                        name: "FK__Freelance__Freel__1F63A897",
                        column: x => x.FreelancerID,
                        principalTable: "Freelancer",
                        principalColumn: "FreelancerID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK__Freelance__Servi__2057CCD0",
                        column: x => x.ServiceID,
                        principalTable: "Service",
                        principalColumn: "ServiceID");
                });

            migrationBuilder.CreateTable(
                name: "Jobs",
                columns: table => new
                {
                    JobId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserID = table.Column<int>(type: "int", nullable: false),
                    StartEstimate = table.Column<TimeOnly>(type: "time", nullable: true),
                    EndEstimate = table.Column<TimeOnly>(type: "time", nullable: true),
                    PayEstimate = table.Column<decimal>(type: "decimal(10,2)", nullable: true),
                    PayInvoice = table.Column<decimal>(type: "decimal(10,2)", nullable: true),
                    JobDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    JobDescription = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Image = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    Job_Status = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: false, defaultValue: "unnaproved"),
                    Pin = table.Column<int>(type: "int", maxLength: 3, nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    FreelancerID = table.Column<int>(type: "int", nullable: true),
                    CompanyID = table.Column<int>(type: "int", nullable: true),
                    DateFinished = table.Column<DateTime>(type: "datetime2", nullable: true),
                    JobTitle = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    isTenderFinalized = table.Column<bool>(type: "bit", nullable: false),
                    isFreelancer = table.Column<bool>(type: "bit", nullable: false),
                    IsInvoiced = table.Column<bool>(type: "bit", nullable: false),
                    IsRated = table.Column<bool>(type: "bit", nullable: false),
                    IsDeletedWorker = table.Column<bool>(type: "bit", nullable: false),
                    IsEdited = table.Column<bool>(type: "bit", nullable: false),
                    IsWorkerEdited = table.Column<bool>(type: "bit", nullable: false),
                    IsApproved = table.Column<bool>(type: "bit", nullable: false),
                    RescheduleNote = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Jobs__056690C234DE197E", x => x.JobId);
                    table.ForeignKey(
                        name: "FK__Jobs__CompanyID__7EC1CEDB",
                        column: x => x.CompanyID,
                        principalTable: "Company",
                        principalColumn: "CompanyID");
                    table.ForeignKey(
                        name: "FK__Jobs__Freelancer__214BF109",
                        column: x => x.FreelancerID,
                        principalTable: "Freelancer",
                        principalColumn: "FreelancerID");
                    table.ForeignKey(
                        name: "FK__Jobs__UserID__4F47C5E3",
                        column: x => x.UserID,
                        principalTable: "Users",
                        principalColumn: "UserID");
                });

            migrationBuilder.CreateTable(
                name: "Tender",
                columns: table => new
                {
                    TenderId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    JobDate = table.Column<DateTime>(type: "datetime", nullable: false),
                    JobDescription = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Image = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    IsFinalized = table.Column<bool>(type: "bit", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: true),
                    FreelancerId = table.Column<int>(type: "int", nullable: true),
                    CompanyId = table.Column<int>(type: "int", nullable: true),
                    IsFreelancer = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Tender__B21B4268197B2C83", x => x.TenderId);
                    table.ForeignKey(
                        name: "FK__Tender__CompanyI__5C37ACAD",
                        column: x => x.CompanyId,
                        principalTable: "Company",
                        principalColumn: "CompanyID");
                    table.ForeignKey(
                        name: "FK__Tender__Freelanc__5B438874",
                        column: x => x.FreelancerId,
                        principalTable: "Freelancer",
                        principalColumn: "FreelancerID");
                    table.ForeignKey(
                        name: "FK__Tender__UserId__5A4F643B",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserID");
                });

            migrationBuilder.CreateTable(
                name: "Messages",
                columns: table => new
                {
                    MessageId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Message = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    UserID = table.Column<int>(type: "int", nullable: true),
                    IsOpened = table.Column<bool>(type: "bit", nullable: false),
                    CompanyID = table.Column<int>(type: "int", nullable: true),
                    StoreId = table.Column<int>(type: "int", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Messages__C87C0C9CD5627697", x => x.MessageId);
                    table.ForeignKey(
                        name: "FK__Messages__Compan__7E8CC4B1",
                        column: x => x.CompanyID,
                        principalTable: "Company",
                        principalColumn: "CompanyID");
                    table.ForeignKey(
                        name: "FK__Messages__StoreI__7F80E8EA",
                        column: x => x.StoreId,
                        principalTable: "Stores",
                        principalColumn: "StoreId");
                    table.ForeignKey(
                        name: "FK__Messages__UserID__2CBDA3B5",
                        column: x => x.UserID,
                        principalTable: "Users",
                        principalColumn: "UserID");
                });

            migrationBuilder.CreateTable(
                name: "Products",
                columns: table => new
                {
                    ProductId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ProductName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    ProductDescription = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Price = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    StoreId = table.Column<int>(type: "int", nullable: false),
                    StockQuantity = table.Column<int>(type: "int", nullable: false),
                    IsOnSale = table.Column<bool>(type: "bit", nullable: false),
                    SalePrice = table.Column<decimal>(type: "decimal(18,2)", nullable: true),
                    IsOutOfStock = table.Column<bool>(type: "bit", nullable: false),
                    SaleExpires = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    Image = table.Column<byte[]>(type: "varbinary(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Products__B40CC6CDD7BA1DD8", x => x.ProductId);
                    table.ForeignKey(
                        name: "FK_Products_Stores",
                        column: x => x.StoreId,
                        principalTable: "Stores",
                        principalColumn: "StoreId");
                });

            migrationBuilder.CreateTable(
                name: "CompanyJobAssignment",
                columns: table => new
                {
                    CompanyJobID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CompanyEmployeeID = table.Column<int>(type: "int", nullable: true),
                    JobId = table.Column<int>(type: "int", nullable: true),
                    AssignedAt = table.Column<DateTime>(type: "datetime", nullable: false),
                    IsFinished = table.Column<bool>(type: "bit", nullable: false),
                    IsCancelled = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__CompanyJ__B783C37E390DA91B", x => x.CompanyJobID);
                    table.ForeignKey(
                        name: "FK__CompanyJo__Compa__019E3B86",
                        column: x => x.CompanyEmployeeID,
                        principalTable: "CompanyEmployee",
                        principalColumn: "CompanyEmployeeID");
                    table.ForeignKey(
                        name: "FK__CompanyJo__JobId__02925FBF",
                        column: x => x.JobId,
                        principalTable: "Jobs",
                        principalColumn: "JobId");
                });

            migrationBuilder.CreateTable(
                name: "EmployeeTask",
                columns: table => new
                {
                    EmployeeTaskId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Task = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    IsFinished = table.Column<bool>(type: "bit", nullable: false),
                    CompanyEmployeeId = table.Column<int>(type: "int", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: false),
                    JobId = table.Column<int>(type: "int", nullable: false),
                    CompanyId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Employee__47942B9E0BC0A370", x => x.EmployeeTaskId);
                    table.ForeignKey(
                        name: "FK__EmployeeT__Compa__1387E197",
                        column: x => x.CompanyEmployeeId,
                        principalTable: "CompanyEmployee",
                        principalColumn: "CompanyEmployeeID");
                    table.ForeignKey(
                        name: "FK__EmployeeT__Compa__269AB60B",
                        column: x => x.CompanyId,
                        principalTable: "Company",
                        principalColumn: "CompanyID");
                    table.ForeignKey(
                        name: "FK__EmployeeT__JobId__25A691D2",
                        column: x => x.JobId,
                        principalTable: "Jobs",
                        principalColumn: "JobId");
                });

            migrationBuilder.CreateTable(
                name: "JobsService",
                columns: table => new
                {
                    JobId = table.Column<int>(type: "int", nullable: false),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__JobsServ__B9372BC2B802A0FE", x => new { x.JobId, x.ServiceId });
                    table.ForeignKey(
                        name: "FK__JobsServi__JobId__7849DB76",
                        column: x => x.JobId,
                        principalTable: "Jobs",
                        principalColumn: "JobId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK__JobsServi__Servi__793DFFAF",
                        column: x => x.ServiceId,
                        principalTable: "Service",
                        principalColumn: "ServiceID");
                });

            migrationBuilder.CreateTable(
                name: "TenderBid",
                columns: table => new
                {
                    TenderBidId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FreelancerId = table.Column<int>(type: "int", nullable: true),
                    CompanyId = table.Column<int>(type: "int", nullable: true),
                    BidAmount = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    BidDescription = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    DateFinished = table.Column<DateTime>(type: "datetime", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    JobId = table.Column<int>(type: "int", nullable: false),
                    StartEstimate = table.Column<TimeOnly>(type: "time", nullable: true),
                    EndEstimate = table.Column<TimeOnly>(type: "time", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__TenderBi__5C928D9693AA275C", x => x.TenderBidId);
                    table.ForeignKey(
                        name: "FK__TenderBid__Compa__61F08603",
                        column: x => x.CompanyId,
                        principalTable: "Company",
                        principalColumn: "CompanyID");
                    table.ForeignKey(
                        name: "FK__TenderBid__Freel__60FC61CA",
                        column: x => x.FreelancerId,
                        principalTable: "Freelancer",
                        principalColumn: "FreelancerID");
                    table.ForeignKey(
                        name: "FK__TenderBid__JobId__6A85CC04",
                        column: x => x.JobId,
                        principalTable: "Jobs",
                        principalColumn: "JobId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UserRatings",
                columns: table => new
                {
                    UserRatingID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserID = table.Column<int>(type: "int", nullable: true),
                    FreelancerID = table.Column<int>(type: "int", nullable: true),
                    Rating = table.Column<decimal>(type: "decimal(3,2)", nullable: false),
                    JobId = table.Column<int>(type: "int", nullable: true),
                    CompanyID = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__UserRati__9E5FEAAA63E96E4C", x => x.UserRatingID);
                    table.ForeignKey(
                        name: "FK__UserRatin__Compa__6B79F03D",
                        column: x => x.CompanyID,
                        principalTable: "Company",
                        principalColumn: "CompanyID");
                    table.ForeignKey(
                        name: "FK__UserRatin__Freel__42ACE4D4",
                        column: x => x.FreelancerID,
                        principalTable: "Freelancer",
                        principalColumn: "FreelancerID");
                    table.ForeignKey(
                        name: "FK__UserRatin__JobId__4589517F",
                        column: x => x.JobId,
                        principalTable: "Jobs",
                        principalColumn: "JobId");
                    table.ForeignKey(
                        name: "FK__UserRatin__UserI__41B8C09B",
                        column: x => x.UserID,
                        principalTable: "Users",
                        principalColumn: "UserID");
                });

            migrationBuilder.CreateTable(
                name: "TenderService",
                columns: table => new
                {
                    TenderId = table.Column<int>(type: "int", nullable: false),
                    ServiceID = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__TenderSe__0E4AF96661B872C5", x => new { x.TenderId, x.ServiceID });
                    table.ForeignKey(
                        name: "FK__TenderSer__Servi__67A95F59",
                        column: x => x.ServiceID,
                        principalTable: "Service",
                        principalColumn: "ServiceID");
                    table.ForeignKey(
                        name: "FK__TenderSer__Tende__66B53B20",
                        column: x => x.TenderId,
                        principalTable: "Tender",
                        principalColumn: "TenderId");
                });

            migrationBuilder.CreateTable(
                name: "OrderItems",
                columns: table => new
                {
                    OrderItemsId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    OrderId = table.Column<int>(type: "int", nullable: false),
                    ProductId = table.Column<int>(type: "int", nullable: false),
                    ProductPrice = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    Quantity = table.Column<int>(type: "int", nullable: false),
                    StoreId = table.Column<int>(type: "int", nullable: true),
                    UnitPrice = table.Column<decimal>(type: "decimal(18,2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__OrderIte__D5BB2555E439B0B6", x => x.OrderItemsId);
                    table.ForeignKey(
                        name: "FK_OrderItems_Orders",
                        column: x => x.OrderId,
                        principalTable: "Orders",
                        principalColumn: "OrderId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_OrderItems_Products",
                        column: x => x.ProductId,
                        principalTable: "Products",
                        principalColumn: "ProductId");
                    table.ForeignKey(
                        name: "FK_OrderItems_Stores",
                        column: x => x.StoreId,
                        principalTable: "Stores",
                        principalColumn: "StoreId");
                });

            migrationBuilder.CreateTable(
                name: "ProductsService",
                columns: table => new
                {
                    ProductID = table.Column<int>(type: "int", nullable: false),
                    ServiceID = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Products__085D7DE34C94B474", x => new { x.ProductID, x.ServiceID });
                    table.ForeignKey(
                        name: "FK__ProductsS__Produ__4DE98D56",
                        column: x => x.ProductID,
                        principalTable: "Products",
                        principalColumn: "ProductId");
                    table.ForeignKey(
                        name: "FK__ProductsS__Servi__4EDDB18F",
                        column: x => x.ServiceID,
                        principalTable: "Service",
                        principalColumn: "ServiceID");
                });

            migrationBuilder.InsertData(
                table: "Locations",
                columns: new[] { "LocationID", "IsDeleted", "LocationName" },
                values: new object[,]
                {
                    { 1, false, "Mostar" },
                    { 2, false, "Sarajevo" }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "RoleID", "IsDeleted", "RoleDescription", "RoleName" },
                values: new object[,]
                {
                    { 1, false, "Administrator for the application", "Admin" },
                    { 2, false, "Application User", "User" },
                    { 3, false, "Freelance worker", "Freelancer" },
                    { 4, false, "Company Administrator", "Company Admin" },
                    { 5, false, "Employee for a company", "CompanyEmployee" },
                    { 6, false, "Administrator for a store", "StoreAdministrator" }
                });

            migrationBuilder.InsertData(
                table: "Service",
                columns: new[] { "ServiceID", "Image", "IsDeleted", "ServiceName" },
                values: new object[,]
                {
                    { 1, null, false, "Keramika" },
                    { 2, null, false, "Elektrika" },
                    { 3, null, false, "Molereaj" },
                    { 4, null, false, "Mreže" },
                    { 5, null, false, "Staklarstvo" },
                    { 6, null, false, "Zidarstvo" },
                    { 7, null, false, "Higijena" }
                });

            migrationBuilder.InsertData(
                table: "Company",
                columns: new[] { "CompanyID", "Bio", "BusinessCertificate", "CompanyName", "Email", "EndTime", "ExperianceYears", "Image", "IsApplicant", "IsDeleted", "LocationID", "PhoneNumber", "Rating", "RatingSum", "StartTime", "TotalRatings", "WorkingDays" },
                values: new object[,]
                {
                    { 1, "Firma koja se bavi elektroinstalacijama i održavanjem električnih sistema.", null, "Elektroinženjering d.o.o.", "elektro@email.com", new TimeOnly(16, 0, 0), 5, null, false, false, 1, "+38761223226", 4.00m, 72.00m, new TimeOnly(8, 0, 0), 17, 54 },
                    { 2, "Firma koja se bavi elektroinstalacijama i održavanjem električnih sistema te keramikom.", null, "Elektroinženjering i Keramika d.o.o.", "elektroKeramika@email.com", new TimeOnly(16, 0, 0), 3, null, false, false, 1, "+38761223312", 3.00m, 72.00m, new TimeOnly(8, 0, 0), 17, 54 },
                    { 3, "Firma koja se bavi zidarstvom i molerajom.", null, "Zidarstvo i Moleraj d.o.o.", "zidarmoler@email.com", new TimeOnly(16, 0, 0), 7, null, false, false, 1, "+38761223317", 3.00m, 72.00m, new TimeOnly(8, 0, 0), 17, 54 },
                    { 4, "Firma koja se bavi molerajom i higijenom.", null, "Moleraj i Higijena d.o.o.", "higijenamoler@email.com", new TimeOnly(16, 0, 0), 7, null, false, false, 2, "+38761223327", 3.00m, 72.00m, new TimeOnly(8, 0, 0), 17, 54 },
                    { 5, "Firma koja se bavi umrežavanjem", null, "Umreži", "umreži@email.com", new TimeOnly(16, 0, 0), 7, null, false, false, 2, "+38761423327", 3.00m, 72.00m, new TimeOnly(8, 0, 0), 17, 54 },
                    { 6, "Firma koja se bavi staklarstvom", null, "Staklo Mostar", "staklo@email.com", new TimeOnly(16, 0, 0), 7, null, false, false, 1, "+38761433327", 3.00m, 72.00m, new TimeOnly(8, 0, 0), 17, 54 },
                    { 7, "Firma koja se bavi zidarstvom", null, "Zidarstvo Sarajevo", "zidari@email.com", new TimeOnly(16, 0, 0), 7, null, false, false, 2, "+38761434327", 3.00m, 72.00m, new TimeOnly(8, 0, 0), 17, 54 }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "UserID", "Address", "CreatedAt", "Email", "FirstName", "Image", "IsDeleted", "LastName", "LocationID", "PasswordHash", "PasswordSalt", "PhoneNumber" },
                values: new object[,]
                {
                    { 1, "Mostar, b.b.", new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "admin@email.com", "Admin", null, false, "Admin", 1, "5tJjrb/iLUCEc6wZo/o0Se14Cnk=", "OUJ+PWXNzP6V9uxMwP7FCg==", "+38761223223" },
                    { 2, "Mostar, b.b.", new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "korisnik@email.com", "Korisnik", null, false, "Aplikacije", 1, "oJyCENbGhk5rSYLZRG0FGb32ejw=", "gYMe5raFyV04jACZCJ7VIQ==", "+38761223224" },
                    { 3, "Sarajevo, b.b.", new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "korisnik2@email.com", "Aplikacijski", null, false, "Korisnik", 2, "oJyCENbGhk5rSYLZRG0FGb32ejw=", "gYMe5raFyV04jACZCJ7VIQ==", "+38761223224" },
                    { 4, "Mostar, b.b.", new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "struja@email.com", "Radnik", null, false, "Struja", 1, "oJyCENbGhk5rSYLZRG0FGb32ejw=", "gYMe5raFyV04jACZCJ7VIQ==", "+38761223225" },
                    { 5, "Mostar, b.b.", new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "vlasnik@email.com", "Administrator", null, false, "Firme", 1, "oJyCENbGhk5rSYLZRG0FGb32ejw=", "gYMe5raFyV04jACZCJ7VIQ==", "+38761223226" },
                    { 6, "Mostar, b.b.", new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "zaposlenik@email.com", "Zaposlenik", null, false, "Firme", 1, "oJyCENbGhk5rSYLZRG0FGb32ejw=", "gYMe5raFyV04jACZCJ7VIQ==", "+38761223227" },
                    { 7, "Mostar, b.b.", new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "trgovina@email.com", "Administrator", null, false, "Trgovine", 1, "oJyCENbGhk5rSYLZRG0FGb32ejw=", "gYMe5raFyV04jACZCJ7VIQ==", "+38761223228" },
                    { 8, "Mostar, b.b.", new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "trgovina2@email.com", "Keramika", null, false, "Trgovina", 1, "oJyCENbGhk5rSYLZRG0FGb32ejw=", "gYMe5raFyV04jACZCJ7VIQ==", "+38761223229" },
                    { 9, "Sarajevo, b.b.", new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "keramika@email.com", "Radnik", null, false, "Keramika", 2, "oJyCENbGhk5rSYLZRG0FGb32ejw=", "gYMe5raFyV04jACZCJ7VIQ==", "+38761223230" },
                    { 10, "Sarajevo, b.b.", new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "moler@email.com", "Radnik", null, false, "Moler", 2, "oJyCENbGhk5rSYLZRG0FGb32ejw=", "gYMe5raFyV04jACZCJ7VIQ==", "+38761223230" },
                    { 11, "Sarajevo, b.b.", new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "zidar@email.com", "Radnik", null, false, "Zidar", 2, "oJyCENbGhk5rSYLZRG0FGb32ejw=", "gYMe5raFyV04jACZCJ7VIQ==", "+38761223230" },
                    { 12, "Sarajevo, b.b.", new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "staklar@email.com", "Radnik", null, false, "Staklar", 2, "oJyCENbGhk5rSYLZRG0FGb32ejw=", "gYMe5raFyV04jACZCJ7VIQ==", "+38761223230" },
                    { 13, "Sarajevo, b.b.", new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "higijena@email.com", "Radnik", null, false, "Higijena", 2, "oJyCENbGhk5rSYLZRG0FGb32ejw=", "gYMe5raFyV04jACZCJ7VIQ==", "+38761223230" },
                    { 14, "Sarajevo, b.b.", new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "mreze@email.com", "Radnik", null, false, "Mreže", 2, "oJyCENbGhk5rSYLZRG0FGb32ejw=", "gYMe5raFyV04jACZCJ7VIQ==", "+38761223230" },
                    { 15, "Mostar, b.b.", new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "firma@email.com", "Vlasnik", null, false, "Firme", 2, "oJyCENbGhk5rSYLZRG0FGb32ejw=", "gYMe5raFyV04jACZCJ7VIQ==", "+38761223226" },
                    { 16, "Mostar, b.b.", new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "terenac@email.com", "Terenac", null, false, "Firme", 1, "oJyCENbGhk5rSYLZRG0FGb32ejw=", "gYMe5raFyV04jACZCJ7VIQ==", "+38761223226" },
                    { 17, "Mostar, b.b.", new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "monter@email.com", "Monter", null, false, "Firme", 1, "oJyCENbGhk5rSYLZRG0FGb32ejw=", "gYMe5raFyV04jACZCJ7VIQ==", "+38761223226" },
                    { 18, "Mostar, b.b.", new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "novi@email.com", "Novi", null, false, "Radnik", 1, "oJyCENbGhk5rSYLZRG0FGb32ejw=", "gYMe5raFyV04jACZCJ7VIQ==", "+38761223226" },
                    { 19, "Mostar, b.b.", new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "dva@email.com", "Zaposlenik", null, false, "FirmeDva", 1, "oJyCENbGhk5rSYLZRG0FGb32ejw=", "gYMe5raFyV04jACZCJ7VIQ==", "+38761223226" },
                    { 20, "Mostar, b.b.", new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "uposlenik@email.com", "Uposlenik", null, false, "Firme", 1, "oJyCENbGhk5rSYLZRG0FGb32ejw=", "gYMe5raFyV04jACZCJ7VIQ==", "+38761223226" },
                    { 21, "Mostar, b.b.", new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "test@email.com", "Test", null, false, "Tester", 1, "oJyCENbGhk5rSYLZRG0FGb32ejw=", "gYMe5raFyV04jACZCJ7VIQ==", "+38761223226" }
                });

            migrationBuilder.InsertData(
                table: "CompanyEmployee",
                columns: new[] { "CompanyEmployeeID", "CompanyID", "CompanyRoleId", "DateJoined", "IsApplicant", "IsDeleted", "IsOwner", "UserID" },
                values: new object[,]
                {
                    { 3, 3, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, true, 5 },
                    { 4, 5, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, true, 5 },
                    { 5, 7, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, true, 5 },
                    { 6, 2, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, true, 15 },
                    { 7, 4, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, true, 15 },
                    { 8, 6, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, true, 15 },
                    { 9, 2, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, false, 16 },
                    { 10, 1, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, false, 16 },
                    { 11, 2, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, false, 17 },
                    { 12, 1, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, false, 17 },
                    { 13, 2, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, false, 18 },
                    { 14, 1, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, false, 18 },
                    { 15, 2, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, false, 19 },
                    { 16, 1, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, false, 19 },
                    { 17, 2, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, false, 20 },
                    { 18, 1, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, false, 20 },
                    { 19, 3, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, false, 16 },
                    { 20, 4, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, false, 20 },
                    { 21, 5, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, false, 20 },
                    { 22, 6, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, false, 18 },
                    { 23, 1, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, false, 7 }
                });

            migrationBuilder.InsertData(
                table: "CompanyRole",
                columns: new[] { "CompanyRoleId", "CompanyID", "RoleName" },
                values: new object[,]
                {
                    { 1, 1, "Vlasnik" },
                    { 2, 1, "Terenac" },
                    { 3, 2, "Administrator" },
                    { 4, 2, "Terenac" }
                });

            migrationBuilder.InsertData(
                table: "CompanyService",
                columns: new[] { "CompanyID", "ServiceID", "CreatedAt" },
                values: new object[,]
                {
                    { 1, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 2, 1, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 2, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 3, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 3, 4, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 4, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 4, 5, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 5, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 5, 5, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 6, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 6, 6, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 7, 1, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 7, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) }
                });

            migrationBuilder.InsertData(
                table: "Freelancer",
                columns: new[] { "FreelancerID", "Bio", "CV", "EndTime", "ExperianceYears", "IsApplicant", "IsDeleted", "Rating", "RatingSum", "StartTime", "TotalRatings", "WorkingDays" },
                values: new object[,]
                {
                    { 4, "Iskusan električar sa 6 godina iskustva. Završen zanat u elektrotehničkoj školi u Mostaru.", null, new TimeOnly(16, 0, 0), 6, false, false, 3.63m, 0.0, new TimeOnly(8, 0, 0), 0, 54 },
                    { 9, "Iskusan keramičar sa 4 godina iskustva. Završen zanat u Mostaru.", null, new TimeOnly(16, 0, 0), 4, false, false, 4.00m, 0.0, new TimeOnly(8, 0, 0), 0, 54 },
                    { 10, "Iskusan moler sa 9 godina iskustva. Završen zanat u Mostaru.", null, new TimeOnly(16, 0, 0), 9, false, false, 4.00m, 0.0, new TimeOnly(8, 0, 0), 0, 54 },
                    { 11, "Iskusan zidar sa 5 godina iskustva. Završen zanat u Mostaru.", null, new TimeOnly(16, 0, 0), 5, false, false, 4.00m, 0.0, new TimeOnly(8, 0, 0), 0, 54 },
                    { 12, "Iskusan staklar sa 7 godina iskustva. Završen zanat u Mostaru.", null, new TimeOnly(16, 0, 0), 7, false, false, 4.00m, 0.0, new TimeOnly(8, 0, 0), 0, 54 },
                    { 13, "Iskusan radnik za higijenu sa 3 godine iskustva. Završen zanat u Mostaru.", null, new TimeOnly(16, 0, 0), 3, false, false, 4.00m, 0.0, new TimeOnly(8, 0, 0), 0, 54 },
                    { 14, "Iskusan radnik za mreže sa 4 godine iskustva. Završen zanat u Mostaru.", null, new TimeOnly(16, 0, 0), 4, false, false, 4.00m, 0.0, new TimeOnly(8, 0, 0), 0, 54 }
                });

            migrationBuilder.InsertData(
                table: "Jobs",
                columns: new[] { "JobId", "CompanyID", "DateFinished", "EndEstimate", "FreelancerID", "Image", "IsApproved", "IsDeleted", "IsDeletedWorker", "IsEdited", "isFreelancer", "IsInvoiced", "IsRated", "isTenderFinalized", "IsWorkerEdited", "JobDate", "JobDescription", "Job_Status", "JobTitle", "PayEstimate", "PayInvoice", "Pin", "RescheduleNote", "StartEstimate", "UserID" },
                values: new object[,]
                {
                    { 10, 1, new DateTime(2025, 6, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(16, 0, 0), null, null, false, false, false, false, false, true, true, false, false, new DateTime(2025, 6, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.", "finished", "Popravka elektroinstalacija", 105m, 105m, 123, null, new TimeOnly(8, 0, 0), 2 },
                    { 11, 2, new DateTime(2025, 6, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(16, 0, 0), null, null, false, false, false, false, false, true, true, false, false, new DateTime(2025, 6, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.", "finished", "Popravka elektroinstalacija", 105m, 105m, 123, null, new TimeOnly(8, 0, 0), 2 },
                    { 12, 4, new DateTime(2025, 6, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(16, 0, 0), null, null, false, false, false, false, false, true, true, false, false, new DateTime(2025, 6, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.", "finished", "Popravka elektroinstalacija", 105m, 105m, 123, null, new TimeOnly(8, 0, 0), 2 },
                    { 13, 1, new DateTime(2025, 6, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(16, 0, 0), null, null, false, false, false, false, false, true, true, false, false, new DateTime(2025, 6, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.", "finished", "Popravka elektroinstalacija", 105m, 105m, 123, null, new TimeOnly(8, 0, 0), 3 },
                    { 14, 5, new DateTime(2025, 6, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(16, 0, 0), null, null, false, false, false, false, false, true, true, false, false, new DateTime(2025, 6, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.", "finished", "Popravka elektroinstalacija", 105m, 105m, 123, null, new TimeOnly(8, 0, 0), 3 },
                    { 15, 7, new DateTime(2025, 6, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(16, 0, 0), null, null, false, false, false, false, false, true, true, false, false, new DateTime(2025, 6, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.", "finished", "Popravka elektroinstalacija", 105m, 105m, 123, null, new TimeOnly(8, 0, 0), 3 },
                    { 16, 1, new DateTime(2025, 6, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(16, 0, 0), null, null, false, false, false, false, false, true, true, false, false, new DateTime(2025, 6, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.", "finished", "Popravka elektroinstalacija", 105m, 105m, 123, null, new TimeOnly(8, 0, 0), 21 },
                    { 17, 2, new DateTime(2025, 6, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(16, 0, 0), null, null, false, false, false, false, false, true, true, false, false, new DateTime(2025, 6, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.", "finished", "Popravka elektroinstalacija", 105m, 105m, 123, null, new TimeOnly(8, 0, 0), 21 },
                    { 18, 4, new DateTime(2025, 6, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(16, 0, 0), null, null, false, false, false, false, false, true, true, false, false, new DateTime(2025, 6, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.", "finished", "Popravka elektroinstalacija", 105m, 105m, 123, null, new TimeOnly(8, 0, 0), 21 }
                });

            migrationBuilder.InsertData(
                table: "Orders",
                columns: new[] { "OrderId", "CreatedAt", "IsCancelled", "IsShipped", "OrderNumber", "Price", "UserId" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 20124, 0m, 2 },
                    { 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 20125, 0m, 3 },
                    { 3, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 20126, 0m, 2 },
                    { 4, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 20127, 0m, 3 }
                });

            migrationBuilder.InsertData(
                table: "Stores",
                columns: new[] { "StoreId", "Address", "BusinessCertificate", "Description", "EndTime", "Image", "IsApplicant", "IsDeleted", "LocationId", "Rating", "RatingSum", "StartTime", "StoreCatalogue", "StoreCataloguePublish", "StoreName", "TotalRatings", "UserId", "WorkingDays" },
                values: new object[,]
                {
                    { 1, "Mostar, b.b.", null, "Prodaja elektro materijala i alata.", new TimeOnly(16, 0, 0), null, false, false, 1, 0m, null, new TimeOnly(8, 0, 0), null, null, "Elektro Materijal", null, 7, 54 },
                    { 2, "Mostar, b.b.", null, "Prodaja keramike", new TimeOnly(16, 0, 0), null, false, false, 1, 0m, null, new TimeOnly(8, 0, 0), null, null, "Keramik Stop", null, 8, 54 },
                    { 3, "Sarajevo, b.b.", null, "Prodaja građevinskog materijala i alata.", new TimeOnly(16, 0, 0), null, false, false, 2, 0m, null, new TimeOnly(8, 0, 0), null, null, "Građevinski Materijal", null, 3, 54 },
                    { 4, "Sarajevo, b.b.", null, "Prodaja boja i lakova za molerske radove.", new TimeOnly(16, 0, 0), null, false, false, 2, 0m, null, new TimeOnly(8, 0, 0), null, null, "Moleraj Plus", null, 3, 54 }
                });

            migrationBuilder.InsertData(
                table: "UserRoles",
                columns: new[] { "UserRoleID", "ChangedAt", "CreatedAt", "RoleID", "UserID" },
                values: new object[,]
                {
                    { 1, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, 1 },
                    { 2, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 2 },
                    { 3, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 3 },
                    { 4, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 4 },
                    { 5, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, 4 },
                    { 6, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 5 },
                    { 7, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, 5 },
                    { 8, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 6 },
                    { 9, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 5, 6 },
                    { 10, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 7 },
                    { 11, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 6, 7 },
                    { 12, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 8 },
                    { 13, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 6, 8 },
                    { 14, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 9 },
                    { 15, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, 9 },
                    { 16, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 10 },
                    { 17, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, 10 },
                    { 18, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 11 },
                    { 19, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, 11 },
                    { 20, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 12 },
                    { 21, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, 12 },
                    { 22, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 13 },
                    { 23, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, 13 },
                    { 24, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 14 },
                    { 25, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, 14 },
                    { 26, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 15 },
                    { 27, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, 15 },
                    { 28, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 16 },
                    { 29, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 5, 16 },
                    { 30, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 17 },
                    { 31, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 5, 17 },
                    { 32, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 18 },
                    { 33, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 5, 18 },
                    { 34, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 19 },
                    { 35, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 5, 19 },
                    { 36, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 20 },
                    { 37, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 5, 20 },
                    { 38, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 21 },
                    { 39, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, 7 }
                });

            migrationBuilder.InsertData(
                table: "CompanyEmployee",
                columns: new[] { "CompanyEmployeeID", "CompanyID", "CompanyRoleId", "DateJoined", "IsApplicant", "IsDeleted", "IsOwner", "UserID" },
                values: new object[,]
                {
                    { 1, 1, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, false, 6 },
                    { 2, 1, 1, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, true, 5 }
                });

            migrationBuilder.InsertData(
                table: "FreelancerService",
                columns: new[] { "FreelancerID", "ServiceID", "CreatedAT" },
                values: new object[,]
                {
                    { 4, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 4, 3, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 4, 4, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 9, 1, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 9, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 9, 3, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 10, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 10, 3, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 10, 5, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 11, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 11, 6, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 11, 7, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 12, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 12, 4, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 12, 5, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 13, 1, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 13, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 13, 7, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 14, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 14, 4, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 14, 5, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) }
                });

            migrationBuilder.InsertData(
                table: "Jobs",
                columns: new[] { "JobId", "CompanyID", "DateFinished", "EndEstimate", "FreelancerID", "Image", "IsApproved", "IsDeleted", "IsDeletedWorker", "IsEdited", "isFreelancer", "IsInvoiced", "IsRated", "isTenderFinalized", "IsWorkerEdited", "JobDate", "JobDescription", "Job_Status", "JobTitle", "PayEstimate", "PayInvoice", "Pin", "RescheduleNote", "StartEstimate", "UserID" },
                values: new object[,]
                {
                    { 1, null, new DateTime(2025, 6, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(16, 0, 0), 4, null, false, false, false, false, false, true, true, false, false, new DateTime(2025, 6, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.", "finished", "Popravka elektroinstalacija", 105m, 105m, 123, null, new TimeOnly(8, 0, 0), 2 },
                    { 2, null, new DateTime(2025, 6, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(16, 0, 0), 9, null, false, false, false, false, false, true, true, false, false, new DateTime(2025, 6, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Potrebno postavljanje keramike na balkonu", "finished", "Postavljanje keramike", 105m, 105m, 123, null, new TimeOnly(8, 0, 0), 2 },
                    { 3, null, new DateTime(2025, 6, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(16, 0, 0), 10, null, false, false, false, false, false, true, true, false, false, new DateTime(2025, 6, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.", "finished", "Popravka elektroinstalacija", 105m, 105m, 123, null, new TimeOnly(8, 0, 0), 2 },
                    { 4, null, new DateTime(2025, 6, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(16, 0, 0), 4, null, false, false, false, false, false, true, true, false, false, new DateTime(2025, 6, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Potrebno postavljanje keramike na balkonu", "finished", "Postavljanje keramike", 105m, 105m, 123, null, new TimeOnly(8, 0, 0), 3 },
                    { 5, null, new DateTime(2025, 6, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(16, 0, 0), 11, null, false, false, false, false, false, true, true, false, false, new DateTime(2025, 6, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.", "finished", "Popravka elektroinstalacija", 105m, 105m, 123, null, new TimeOnly(8, 0, 0), 3 },
                    { 6, null, new DateTime(2025, 6, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(16, 0, 0), 12, null, false, false, false, false, false, true, true, false, false, new DateTime(2025, 6, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Potrebno postavljanje keramike na balkonu", "finished", "Postavljanje keramike", 105m, 105m, 123, null, new TimeOnly(8, 0, 0), 3 },
                    { 7, null, new DateTime(2025, 6, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(16, 0, 0), 9, null, false, false, false, false, false, true, true, false, false, new DateTime(2025, 6, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Potrebno krečenje i farbanje zidova u kući, uključujući pripremu površina i završne radove.", "finished", "Molerski radovi u kući", 105m, 105m, 123, null, new TimeOnly(8, 0, 0), 21 },
                    { 8, null, new DateTime(2025, 6, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(16, 0, 0), 11, null, false, false, false, false, false, true, true, false, false, new DateTime(2025, 6, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Potrebna hitna popravka krova zbog curenja vode, uključujući zamjenu oštećenih delova i hidroizolaciju.", "finished", "Popravka krova", 105m, 105m, 123, null, new TimeOnly(8, 0, 0), 21 },
                    { 9, null, new DateTime(2025, 6, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(16, 0, 0), 13, null, false, false, false, false, false, true, true, false, false, new DateTime(2025, 6, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Potrebna instalacija solarnih panela na krovu kuće, uključujući montažu i povezivanje sa električnim sistemom.", "finished", "Instalacija solarnih panela", 105m, 105m, 123, null, new TimeOnly(8, 0, 0), 21 }
                });

            migrationBuilder.InsertData(
                table: "JobsService",
                columns: new[] { "JobId", "ServiceId", "CreatedAt" },
                values: new object[,]
                {
                    { 10, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 11, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 12, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 13, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 14, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 15, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 16, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 17, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 18, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) }
                });

            migrationBuilder.InsertData(
                table: "Products",
                columns: new[] { "ProductId", "Image", "IsDeleted", "IsOnSale", "IsOutOfStock", "Price", "ProductDescription", "ProductName", "SaleExpires", "SalePrice", "StockQuantity", "StoreId" },
                values: new object[,]
                {
                    { 1, null, false, false, false, 25.00m, " Produžni kabl dužine 5 metara, idealan za kućnu i kancelarijsku upotrebu.", "Produžni kabl 5m", null, null, 15, 1 },
                    { 2, null, false, false, false, 45.00m, "Visokokvalitetni Ethernet kabal dužine 20 metara za pouzdanu mrežnu povezanost.", "Ethernet kabal 20m", null, null, 15, 1 },
                    { 3, null, false, false, false, 15.00m, "Standardni prekidač naizmenične struje za kućnu i industrijsku upotrebu.", "Prekidač naizmenične struje", null, null, 15, 1 },
                    { 4, null, false, false, false, 10.00m, "Energetski efikasna LED žarulja snage 9W, pruža jarko svetlo uz nisku potrošnju energije.", "LED žarulja 9W", null, null, 15, 1 },
                    { 5, null, false, false, false, 20.00m, "Visokokvalitetna ravna keramika dimenzija 30x30cm, idealna za podove i zidove.", "Ravna keramika 30x30cm", null, null, 15, 2 },
                    { 6, null, false, false, false, 15.00m, "Izdržljive keramičke pločice dimenzija 20x20cm, pogodne za različite površine.", "Keramičke pločice 20x20cm", null, null, 15, 2 },
                    { 7, null, false, false, false, 30.00m, "Kvalitetna fug masa u pakovanju od 5kg, idealna za popunjavanje spojeva između pločica.", "Fug masa 5kg", null, null, 15, 2 },
                    { 8, null, false, false, false, 50.00m, "Snažno ljepilo za keramiku u pakovanju od 10kg, pruža čvrsto prizemljivanje pločica na različite površine.", "Ljepilo za keramiku 10kg", null, null, 15, 2 },
                    { 9, null, false, false, false, 8.00m, "Visokokvalitetni cement u pakovanju od 25kg, pogodan za različite građevinske radove.", "Cement 25kg", null, null, 15, 3 },
                    { 10, null, false, false, false, 5.00m, "Fini pijesak u pakovanju od 50kg, idealan za malterisanje i druge građevinske primjene.", "Pijesak 50kg", null, null, 15, 3 },
                    { 11, null, false, false, false, 12.00m, "Kvalitetan malter u pakovanju od 30kg, pogodan za unutrašnje i vanjske zidove.", "Malter 30kg", null, null, 15, 3 },
                    { 12, null, false, false, false, 25.00m, "Unutrašnja boja za zidove u pakovanju od 5L, dostupna u različitim bojama.", "Boja za zidove 5L", null, null, 15, 4 },
                    { 13, null, false, false, false, 15.00m, "Visokokvalitetni lak za drvo u pakovanju od 1L, pruža zaštitu i sjaj drvenim površinama.", "Lak za drvo 1L", null, null, 15, 4 },
                    { 14, null, false, false, false, 7.00m, "Kvalitetan valjak za boju, idealan za brzo i ravnomerno nanošenje boje na zidove.", "Valjak za boju", null, null, 15, 4 },
                    { 15, null, false, false, false, 5.00m, "Izdržljiva četka za boju, pogodna za precizno nanošenje boje na različite površine.", "Četka za boju", null, null, 15, 4 },
                    { 16, null, false, false, false, 40.00m, "Velika kanta za boju u pakovanju od 10L, idealna za veće projekte farbanja.", "Kanta za boju 10L", null, null, 15, 4 }
                });

            migrationBuilder.InsertData(
                table: "UserRatings",
                columns: new[] { "UserRatingID", "CompanyID", "FreelancerID", "JobId", "Rating", "UserID" },
                values: new object[,]
                {
                    { 10, 1, null, 10, 5m, 2 },
                    { 11, 2, null, 11, 4m, 2 },
                    { 12, 4, null, 12, 3m, 2 },
                    { 13, 1, null, 13, 4m, 3 },
                    { 14, 5, null, 14, 5m, 3 },
                    { 15, 7, null, 15, 2m, 3 },
                    { 16, 1, null, 16, 5m, 21 },
                    { 17, 2, null, 17, 4m, 21 },
                    { 18, 4, null, 18, 3m, 21 }
                });

            migrationBuilder.InsertData(
                table: "JobsService",
                columns: new[] { "JobId", "ServiceId", "CreatedAt" },
                values: new object[,]
                {
                    { 1, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 2, 1, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 3, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 4, 1, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 5, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 6, 1, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 7, 3, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 8, 5, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 9, 4, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) }
                });

            migrationBuilder.InsertData(
                table: "OrderItems",
                columns: new[] { "OrderItemsId", "OrderId", "ProductId", "ProductPrice", "Quantity", "StoreId", "UnitPrice" },
                values: new object[,]
                {
                    { 1, 1, 1, 0m, 2, 1, 0m },
                    { 2, 1, 4, 0m, 5, 1, 0m },
                    { 3, 2, 2, 0m, 1, 1, 0m },
                    { 4, 2, 3, 0m, 3, 1, 0m },
                    { 5, 3, 5, 0m, 4, 2, 0m },
                    { 6, 3, 6, 0m, 2, 2, 0m },
                    { 7, 4, 7, 0m, 1, 2, 0m },
                    { 8, 4, 8, 0m, 3, 2, 0m }
                });

            migrationBuilder.InsertData(
                table: "ProductsService",
                columns: new[] { "ProductID", "ServiceID", "CreatedAt" },
                values: new object[,]
                {
                    { 1, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 2, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 3, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 4, 2, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 5, 1, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 6, 1, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 7, 1, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 8, 1, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 9, 6, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 10, 6, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 11, 6, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 12, 3, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 13, 3, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 14, 3, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 15, 3, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 16, 3, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) }
                });

            migrationBuilder.InsertData(
                table: "UserRatings",
                columns: new[] { "UserRatingID", "CompanyID", "FreelancerID", "JobId", "Rating", "UserID" },
                values: new object[,]
                {
                    { 1, null, 4, 1, 5m, 2 },
                    { 2, null, 9, 2, 4m, 2 },
                    { 3, null, 10, 3, 3m, 2 },
                    { 4, null, 4, 4, 4m, 3 },
                    { 5, null, 11, 5, 5m, 3 },
                    { 6, null, 12, 6, 2m, 3 },
                    { 7, null, 9, 7, 5m, 21 },
                    { 8, null, 11, 8, 4m, 21 },
                    { 9, null, 13, 9, 3m, 21 }
                });

            migrationBuilder.CreateIndex(
                name: "IX_Company_LocationID",
                table: "Company",
                column: "LocationID");

            migrationBuilder.CreateIndex(
                name: "UQ_Company_Email",
                table: "Company",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_CompanyEmployee_CompanyID",
                table: "CompanyEmployee",
                column: "CompanyID");

            migrationBuilder.CreateIndex(
                name: "IX_CompanyEmployee_CompanyRoleId",
                table: "CompanyEmployee",
                column: "CompanyRoleId");

            migrationBuilder.CreateIndex(
                name: "IX_CompanyEmployee_UserID",
                table: "CompanyEmployee",
                column: "UserID");

            migrationBuilder.CreateIndex(
                name: "IX_CompanyJobAssignment_CompanyEmployeeID",
                table: "CompanyJobAssignment",
                column: "CompanyEmployeeID");

            migrationBuilder.CreateIndex(
                name: "IX_CompanyJobAssignment_JobId",
                table: "CompanyJobAssignment",
                column: "JobId");

            migrationBuilder.CreateIndex(
                name: "IX_CompanyRole_CompanyID",
                table: "CompanyRole",
                column: "CompanyID");

            migrationBuilder.CreateIndex(
                name: "IX_CompanyService_ServiceID",
                table: "CompanyService",
                column: "ServiceID");

            migrationBuilder.CreateIndex(
                name: "IX_EmployeeTask_CompanyEmployeeId",
                table: "EmployeeTask",
                column: "CompanyEmployeeId");

            migrationBuilder.CreateIndex(
                name: "IX_EmployeeTask_CompanyId",
                table: "EmployeeTask",
                column: "CompanyId");

            migrationBuilder.CreateIndex(
                name: "IX_EmployeeTask_JobId",
                table: "EmployeeTask",
                column: "JobId");

            migrationBuilder.CreateIndex(
                name: "IX_FreelancerService_ServiceID",
                table: "FreelancerService",
                column: "ServiceID");

            migrationBuilder.CreateIndex(
                name: "IX_Jobs_CompanyID",
                table: "Jobs",
                column: "CompanyID");

            migrationBuilder.CreateIndex(
                name: "IX_Jobs_FreelancerID",
                table: "Jobs",
                column: "FreelancerID");

            migrationBuilder.CreateIndex(
                name: "IX_Jobs_UserID",
                table: "Jobs",
                column: "UserID");

            migrationBuilder.CreateIndex(
                name: "IX_JobsService_ServiceId",
                table: "JobsService",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_Messages_CompanyID",
                table: "Messages",
                column: "CompanyID");

            migrationBuilder.CreateIndex(
                name: "IX_Messages_StoreId",
                table: "Messages",
                column: "StoreId");

            migrationBuilder.CreateIndex(
                name: "IX_Messages_UserID",
                table: "Messages",
                column: "UserID");

            migrationBuilder.CreateIndex(
                name: "IX_OrderItems_OrderId",
                table: "OrderItems",
                column: "OrderId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderItems_ProductId",
                table: "OrderItems",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderItems_StoreId",
                table: "OrderItems",
                column: "StoreId");

            migrationBuilder.CreateIndex(
                name: "IX_Orders_UserId",
                table: "Orders",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Products_StoreId",
                table: "Products",
                column: "StoreId");

            migrationBuilder.CreateIndex(
                name: "IX_ProductsService_ServiceID",
                table: "ProductsService",
                column: "ServiceID");

            migrationBuilder.CreateIndex(
                name: "UQ__Roles__8A2B61606615CF66",
                table: "Roles",
                column: "RoleName",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Stores_LocationId",
                table: "Stores",
                column: "LocationId");

            migrationBuilder.CreateIndex(
                name: "IX_Stores_UserId",
                table: "Stores",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Tender_CompanyId",
                table: "Tender",
                column: "CompanyId");

            migrationBuilder.CreateIndex(
                name: "IX_Tender_FreelancerId",
                table: "Tender",
                column: "FreelancerId");

            migrationBuilder.CreateIndex(
                name: "IX_Tender_UserId",
                table: "Tender",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_TenderBid_CompanyId",
                table: "TenderBid",
                column: "CompanyId");

            migrationBuilder.CreateIndex(
                name: "IX_TenderBid_FreelancerId",
                table: "TenderBid",
                column: "FreelancerId");

            migrationBuilder.CreateIndex(
                name: "IX_TenderBid_JobId",
                table: "TenderBid",
                column: "JobId");

            migrationBuilder.CreateIndex(
                name: "IX_TenderService_ServiceID",
                table: "TenderService",
                column: "ServiceID");

            migrationBuilder.CreateIndex(
                name: "IX_UserRatings_CompanyID",
                table: "UserRatings",
                column: "CompanyID");

            migrationBuilder.CreateIndex(
                name: "IX_UserRatings_FreelancerID",
                table: "UserRatings",
                column: "FreelancerID");

            migrationBuilder.CreateIndex(
                name: "IX_UserRatings_JobId",
                table: "UserRatings",
                column: "JobId");

            migrationBuilder.CreateIndex(
                name: "IX_UserRatings_UserID",
                table: "UserRatings",
                column: "UserID");

            migrationBuilder.CreateIndex(
                name: "IX_UserRoles_RoleID",
                table: "UserRoles",
                column: "RoleID");

            migrationBuilder.CreateIndex(
                name: "IX_UserRoles_UserID",
                table: "UserRoles",
                column: "UserID");

            migrationBuilder.CreateIndex(
                name: "IX_Users_LocationID",
                table: "Users",
                column: "LocationID");

            migrationBuilder.CreateIndex(
                name: "UQ_Users_Email",
                table: "Users",
                column: "Email",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CompanyJobAssignment");

            migrationBuilder.DropTable(
                name: "CompanyService");

            migrationBuilder.DropTable(
                name: "EmployeeTask");

            migrationBuilder.DropTable(
                name: "FreelancerService");

            migrationBuilder.DropTable(
                name: "JobsService");

            migrationBuilder.DropTable(
                name: "Messages");

            migrationBuilder.DropTable(
                name: "OrderItems");

            migrationBuilder.DropTable(
                name: "ProductsService");

            migrationBuilder.DropTable(
                name: "TenderBid");

            migrationBuilder.DropTable(
                name: "TenderService");

            migrationBuilder.DropTable(
                name: "UserRatings");

            migrationBuilder.DropTable(
                name: "UserRoles");

            migrationBuilder.DropTable(
                name: "CompanyEmployee");

            migrationBuilder.DropTable(
                name: "Orders");

            migrationBuilder.DropTable(
                name: "Products");

            migrationBuilder.DropTable(
                name: "Service");

            migrationBuilder.DropTable(
                name: "Tender");

            migrationBuilder.DropTable(
                name: "Jobs");

            migrationBuilder.DropTable(
                name: "Roles");

            migrationBuilder.DropTable(
                name: "CompanyRole");

            migrationBuilder.DropTable(
                name: "Stores");

            migrationBuilder.DropTable(
                name: "Freelancer");

            migrationBuilder.DropTable(
                name: "Company");

            migrationBuilder.DropTable(
                name: "Users");

            migrationBuilder.DropTable(
                name: "Locations");
        }
    }
}
