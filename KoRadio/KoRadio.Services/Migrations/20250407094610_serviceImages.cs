using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace KoRadio.Services.Migrations
{
    /// <inheritdoc />
    public partial class serviceImages : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__Freelance__Worke__4AB81AF0",
                table: "Freelancers");

            migrationBuilder.DropForeignKey(
                name: "FK__Services__Compan__4E88ABD4",
                table: "Services");

            migrationBuilder.DropForeignKey(
                name: "FK__Services__Freela__4D94879B",
                table: "Services");

            migrationBuilder.DropForeignKey(
                name: "FK__UserRoles__RoleI__3E52440B",
                table: "UserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK__UserRoles__UserI__3D5E1FD2",
                table: "UserRoles");

            migrationBuilder.DropTable(
                name: "CompanyAdministrator");

            migrationBuilder.DropTable(
                name: "CompanyWorkers");

            migrationBuilder.DropTable(
                name: "Conflicts");

            migrationBuilder.DropTable(
                name: "JobAvailability");

            migrationBuilder.DropTable(
                name: "Workers");

            migrationBuilder.DropTable(
                name: "Jobs");

            migrationBuilder.DropTable(
                name: "Estimates");

            migrationBuilder.DropTable(
                name: "Invoices");

            migrationBuilder.DropTable(
                name: "JobStatuses");

            migrationBuilder.DropPrimaryKey(
                name: "PK__Services__C51BB0EAD9D99D16",
                table: "Services");

            migrationBuilder.DropIndex(
                name: "IX_Services_CompanyID",
                table: "Services");

            migrationBuilder.DropIndex(
                name: "IX_Services_FreelancerID",
                table: "Services");

            migrationBuilder.DropPrimaryKey(
                name: "PK__Freelanc__077C880650C2883E",
                table: "Freelancers");

            migrationBuilder.DropPrimaryKey(
                name: "PK__Companie__2D971C4C6BA2CBCD",
                table: "Companies");

            migrationBuilder.DropColumn(
                name: "CompanyID",
                table: "Services");

            migrationBuilder.DropColumn(
                name: "FreelancerID",
                table: "Services");

            migrationBuilder.DropColumn(
                name: "CompanyName",
                table: "Companies");

            migrationBuilder.RenameTable(
                name: "Services",
                newName: "Service");

            migrationBuilder.RenameTable(
                name: "Freelancers",
                newName: "Freelancer");

            migrationBuilder.RenameTable(
                name: "Companies",
                newName: "Company");

            migrationBuilder.RenameColumn(
                name: "WorkerID",
                table: "Freelancer",
                newName: "FreelancerID");

            migrationBuilder.AlterColumn<string>(
                name: "ServiceName",
                table: "Service",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(50)",
                oldMaxLength: 50,
                oldNullable: true);

            migrationBuilder.AddColumn<byte[]>(
                name: "Slika",
                table: "Service",
                type: "varbinary(max)",
                nullable: true);

            migrationBuilder.AddColumn<byte[]>(
                name: "SlikaThumb",
                table: "Service",
                type: "varbinary(max)",
                nullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Bio",
                table: "Freelancer",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(500)",
                oldMaxLength: 500,
                oldNullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "FreelancerID",
                table: "Freelancer",
                type: "int",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "int")
                .Annotation("SqlServer:Identity", "1, 1");

            migrationBuilder.AddColumn<string>(
                name: "Availability",
                table: "Freelancer",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ExperianceYears",
                table: "Freelancer",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "HourlyRate",
                table: "Freelancer",
                type: "decimal(10,2)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Location",
                table: "Freelancer",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "Rating",
                table: "Freelancer",
                type: "decimal(3,2)",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "UserID",
                table: "Freelancer",
                type: "int",
                nullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Bio",
                table: "Company",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(500)",
                oldMaxLength: 500,
                oldNullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Availability",
                table: "Company",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ExperianceYears",
                table: "Company",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Location",
                table: "Company",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PhoneNumber",
                table: "Company",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "Rating",
                table: "Company",
                type: "decimal(3,2)",
                nullable: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK__Service__C51BB0EAAC6763C6",
                table: "Service",
                column: "ServiceID");

            migrationBuilder.AddPrimaryKey(
                name: "PK__Freelanc__3D00E30C2F2F998D",
                table: "Freelancer",
                column: "FreelancerID");

            migrationBuilder.AddPrimaryKey(
                name: "PK__Company__2D971C4CB07C8C16",
                table: "Company",
                column: "CompanyID");

            migrationBuilder.CreateTable(
                name: "CompanyEmployee",
                columns: table => new
                {
                    CompanyEmployeeID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserID = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__CompanyE__3916BD7B030D0A87", x => x.CompanyEmployeeID);
                    table.ForeignKey(
                        name: "FK__CompanyEm__UserI__17036CC0",
                        column: x => x.UserID,
                        principalTable: "Users",
                        principalColumn: "UserID");
                });

            migrationBuilder.CreateTable(
                name: "CompanyService",
                columns: table => new
                {
                    CompanyID = table.Column<int>(type: "int", nullable: false),
                    ServiceID = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: true),
                    isDeleted = table.Column<bool>(type: "bit", nullable: true)
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
                name: "FreelancerService",
                columns: table => new
                {
                    FreelancerID = table.Column<int>(type: "int", nullable: false),
                    ServiceID = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: true),
                    isDeleted = table.Column<bool>(type: "bit", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Freelanc__81515802354FEB8B", x => new { x.FreelancerID, x.ServiceID });
                    table.ForeignKey(
                        name: "FK__Freelance__Freel__1BC821DD",
                        column: x => x.FreelancerID,
                        principalTable: "Freelancer",
                        principalColumn: "FreelancerID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK__Freelance__Servi__1CBC4616",
                        column: x => x.ServiceID,
                        principalTable: "Service",
                        principalColumn: "ServiceID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Freelancer_UserID",
                table: "Freelancer",
                column: "UserID");

            migrationBuilder.CreateIndex(
                name: "IX_CompanyEmployee_UserID",
                table: "CompanyEmployee",
                column: "UserID");

            migrationBuilder.CreateIndex(
                name: "IX_CompanyService_ServiceID",
                table: "CompanyService",
                column: "ServiceID");

            migrationBuilder.CreateIndex(
                name: "IX_FreelancerService_ServiceID",
                table: "FreelancerService",
                column: "ServiceID");

            migrationBuilder.AddForeignKey(
                name: "FK__Freelance__UserI__123EB7A3",
                table: "Freelancer",
                column: "UserID",
                principalTable: "Users",
                principalColumn: "UserID");

            migrationBuilder.AddForeignKey(
                name: "FK_UserRoles_Roles_RoleID",
                table: "UserRoles",
                column: "RoleID",
                principalTable: "Roles",
                principalColumn: "RoleID");

            migrationBuilder.AddForeignKey(
                name: "FK_UserRoles_Users_UserID",
                table: "UserRoles",
                column: "UserID",
                principalTable: "Users",
                principalColumn: "UserID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__Freelance__UserI__123EB7A3",
                table: "Freelancer");

            migrationBuilder.DropForeignKey(
                name: "FK_UserRoles_Roles_RoleID",
                table: "UserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK_UserRoles_Users_UserID",
                table: "UserRoles");

            migrationBuilder.DropTable(
                name: "CompanyEmployee");

            migrationBuilder.DropTable(
                name: "CompanyService");

            migrationBuilder.DropTable(
                name: "FreelancerService");

            migrationBuilder.DropPrimaryKey(
                name: "PK__Service__C51BB0EAAC6763C6",
                table: "Service");

            migrationBuilder.DropPrimaryKey(
                name: "PK__Freelanc__3D00E30C2F2F998D",
                table: "Freelancer");

            migrationBuilder.DropIndex(
                name: "IX_Freelancer_UserID",
                table: "Freelancer");

            migrationBuilder.DropPrimaryKey(
                name: "PK__Company__2D971C4CB07C8C16",
                table: "Company");

            migrationBuilder.DropColumn(
                name: "Slika",
                table: "Service");

            migrationBuilder.DropColumn(
                name: "SlikaThumb",
                table: "Service");

            migrationBuilder.DropColumn(
                name: "Availability",
                table: "Freelancer");

            migrationBuilder.DropColumn(
                name: "ExperianceYears",
                table: "Freelancer");

            migrationBuilder.DropColumn(
                name: "HourlyRate",
                table: "Freelancer");

            migrationBuilder.DropColumn(
                name: "Location",
                table: "Freelancer");

            migrationBuilder.DropColumn(
                name: "Rating",
                table: "Freelancer");

            migrationBuilder.DropColumn(
                name: "UserID",
                table: "Freelancer");

            migrationBuilder.DropColumn(
                name: "Availability",
                table: "Company");

            migrationBuilder.DropColumn(
                name: "ExperianceYears",
                table: "Company");

            migrationBuilder.DropColumn(
                name: "Location",
                table: "Company");

            migrationBuilder.DropColumn(
                name: "PhoneNumber",
                table: "Company");

            migrationBuilder.DropColumn(
                name: "Rating",
                table: "Company");

            migrationBuilder.RenameTable(
                name: "Service",
                newName: "Services");

            migrationBuilder.RenameTable(
                name: "Freelancer",
                newName: "Freelancers");

            migrationBuilder.RenameTable(
                name: "Company",
                newName: "Companies");

            migrationBuilder.RenameColumn(
                name: "FreelancerID",
                table: "Freelancers",
                newName: "WorkerID");

            migrationBuilder.AlterColumn<string>(
                name: "ServiceName",
                table: "Services",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(255)",
                oldMaxLength: 255,
                oldNullable: true);

            migrationBuilder.AddColumn<int>(
                name: "CompanyID",
                table: "Services",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "FreelancerID",
                table: "Services",
                type: "int",
                nullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Bio",
                table: "Freelancers",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(255)",
                oldMaxLength: 255,
                oldNullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "WorkerID",
                table: "Freelancers",
                type: "int",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "int")
                .OldAnnotation("SqlServer:Identity", "1, 1");

            migrationBuilder.AlterColumn<string>(
                name: "Bio",
                table: "Companies",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(255)",
                oldMaxLength: 255,
                oldNullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CompanyName",
                table: "Companies",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK__Services__C51BB0EAD9D99D16",
                table: "Services",
                column: "ServiceID");

            migrationBuilder.AddPrimaryKey(
                name: "PK__Freelanc__077C880650C2883E",
                table: "Freelancers",
                column: "WorkerID");

            migrationBuilder.AddPrimaryKey(
                name: "PK__Companie__2D971C4C6BA2CBCD",
                table: "Companies",
                column: "CompanyID");

            migrationBuilder.CreateTable(
                name: "CompanyAdministrator",
                columns: table => new
                {
                    CompanyID = table.Column<int>(type: "int", nullable: false),
                    UserID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__CompanyA__FCEF90863465B45C", x => new { x.CompanyID, x.UserID });
                    table.ForeignKey(
                        name: "FK__CompanyAd__Compa__5BE2A6F2",
                        column: x => x.CompanyID,
                        principalTable: "Companies",
                        principalColumn: "CompanyID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK__CompanyAd__UserI__5CD6CB2B",
                        column: x => x.UserID,
                        principalTable: "Users",
                        principalColumn: "UserID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Estimates",
                columns: table => new
                {
                    EstimateID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CompanyID = table.Column<int>(type: "int", nullable: true),
                    FreelancerID = table.Column<int>(type: "int", nullable: false),
                    UserID = table.Column<int>(type: "int", nullable: false),
                    CreatedAT = table.Column<DateTime>(type: "datetime", nullable: true, defaultValueSql: "(getdate())"),
                    Description = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: false),
                    EstimatedCost = table.Column<decimal>(type: "decimal(10,2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Estimate__ABEBF4D51AFFC293", x => x.EstimateID);
                    table.ForeignKey(
                        name: "FK__Estimates__Compa__6EF57B66",
                        column: x => x.CompanyID,
                        principalTable: "Companies",
                        principalColumn: "CompanyID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK__Estimates__Freel__6E01572D",
                        column: x => x.FreelancerID,
                        principalTable: "Freelancers",
                        principalColumn: "WorkerID");
                    table.ForeignKey(
                        name: "FK__Estimates__UserI__6D0D32F4",
                        column: x => x.UserID,
                        principalTable: "Users",
                        principalColumn: "UserID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "JobAvailability",
                columns: table => new
                {
                    JobAvailabilityID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CompanyID = table.Column<int>(type: "int", nullable: true),
                    FreelancerID = table.Column<int>(type: "int", nullable: true),
                    EndTime = table.Column<DateTime>(type: "datetime", nullable: false),
                    IsAvailable = table.Column<bool>(type: "bit", nullable: true),
                    StartTime = table.Column<DateTime>(type: "datetime", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__JobAvail__0E1EFD63B843CAE1", x => x.JobAvailabilityID);
                    table.ForeignKey(
                        name: "FK__JobAvaila__Compa__52593CB8",
                        column: x => x.CompanyID,
                        principalTable: "Companies",
                        principalColumn: "CompanyID");
                    table.ForeignKey(
                        name: "FK__JobAvaila__Freel__5165187F",
                        column: x => x.FreelancerID,
                        principalTable: "Freelancers",
                        principalColumn: "WorkerID");
                });

            migrationBuilder.CreateTable(
                name: "JobStatuses",
                columns: table => new
                {
                    StatusID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    StatusName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__JobStatu__C8EE2043DA05F66B", x => x.StatusID);
                });

            migrationBuilder.CreateTable(
                name: "Workers",
                columns: table => new
                {
                    WorkerID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserID = table.Column<int>(type: "int", nullable: false),
                    Rating = table.Column<decimal>(type: "decimal(3,2)", nullable: true, defaultValue: 0m)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Workers__077C8806A96A869A", x => x.WorkerID);
                    table.ForeignKey(
                        name: "FK__Workers__UserID__45F365D3",
                        column: x => x.UserID,
                        principalTable: "Users",
                        principalColumn: "UserID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Invoices",
                columns: table => new
                {
                    InvoiceID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CompanyID = table.Column<int>(type: "int", nullable: true),
                    FreelancerID = table.Column<int>(type: "int", nullable: false),
                    StatusID = table.Column<int>(type: "int", nullable: false),
                    UserID = table.Column<int>(type: "int", nullable: false),
                    Amount = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    IssuedAt = table.Column<DateTime>(type: "datetime", nullable: true, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Invoices__D796AAD5FDAAEED1", x => x.InvoiceID);
                    table.ForeignKey(
                        name: "FK__Invoices__Compan__02084FDA",
                        column: x => x.CompanyID,
                        principalTable: "Companies",
                        principalColumn: "CompanyID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK__Invoices__Freela__01142BA1",
                        column: x => x.FreelancerID,
                        principalTable: "Freelancers",
                        principalColumn: "WorkerID");
                    table.ForeignKey(
                        name: "FK__Invoices__Status__7F2BE32F",
                        column: x => x.StatusID,
                        principalTable: "JobStatuses",
                        principalColumn: "StatusID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK__Invoices__UserID__00200768",
                        column: x => x.UserID,
                        principalTable: "Users",
                        principalColumn: "UserID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "CompanyWorkers",
                columns: table => new
                {
                    CompanyWorkersID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CompanyID = table.Column<int>(type: "int", nullable: false),
                    WorkerID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__CompanyW__F593AA8FEFAFED44", x => x.CompanyWorkersID);
                    table.ForeignKey(
                        name: "FK__CompanyWo__Compa__59063A47",
                        column: x => x.CompanyID,
                        principalTable: "Companies",
                        principalColumn: "CompanyID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK__CompanyWo__Worke__5812160E",
                        column: x => x.WorkerID,
                        principalTable: "Workers",
                        principalColumn: "WorkerID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Jobs",
                columns: table => new
                {
                    JobID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CompanyID = table.Column<int>(type: "int", nullable: true),
                    EstimateID = table.Column<int>(type: "int", nullable: false),
                    FreelancerID = table.Column<int>(type: "int", nullable: true),
                    InvoiceID = table.Column<int>(type: "int", nullable: true),
                    StatusID = table.Column<int>(type: "int", nullable: false, defaultValue: 1),
                    UserID = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: true, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Jobs__056690E258E4BCA7", x => x.JobID);
                    table.ForeignKey(
                        name: "FK__Jobs__CompanyID__2BFE89A6",
                        column: x => x.CompanyID,
                        principalTable: "Companies",
                        principalColumn: "CompanyID");
                    table.ForeignKey(
                        name: "FK__Jobs__EstimateID__2739D489",
                        column: x => x.EstimateID,
                        principalTable: "Estimates",
                        principalColumn: "EstimateID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK__Jobs__Freelancer__2B0A656D",
                        column: x => x.FreelancerID,
                        principalTable: "Freelancers",
                        principalColumn: "WorkerID");
                    table.ForeignKey(
                        name: "FK__Jobs__InvoiceID__29221CFB",
                        column: x => x.InvoiceID,
                        principalTable: "Invoices",
                        principalColumn: "InvoiceID");
                    table.ForeignKey(
                        name: "FK__Jobs__StatusID__282DF8C2",
                        column: x => x.StatusID,
                        principalTable: "JobStatuses",
                        principalColumn: "StatusID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK__Jobs__UserID__2A164134",
                        column: x => x.UserID,
                        principalTable: "Users",
                        principalColumn: "UserID");
                });

            migrationBuilder.CreateTable(
                name: "Conflicts",
                columns: table => new
                {
                    ConflictID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    JobID = table.Column<int>(type: "int", nullable: false),
                    ConflictReason = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: true, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Conflict__FEE84A165B8815CC", x => x.ConflictID);
                    table.ForeignKey(
                        name: "FK__Conflicts__JobID__2FCF1A8A",
                        column: x => x.JobID,
                        principalTable: "Jobs",
                        principalColumn: "JobID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Services_CompanyID",
                table: "Services",
                column: "CompanyID");

            migrationBuilder.CreateIndex(
                name: "IX_Services_FreelancerID",
                table: "Services",
                column: "FreelancerID");

            migrationBuilder.CreateIndex(
                name: "IX_CompanyAdministrator_UserID",
                table: "CompanyAdministrator",
                column: "UserID");

            migrationBuilder.CreateIndex(
                name: "IX_CompanyWorkers_CompanyID",
                table: "CompanyWorkers",
                column: "CompanyID");

            migrationBuilder.CreateIndex(
                name: "IX_CompanyWorkers_WorkerID",
                table: "CompanyWorkers",
                column: "WorkerID");

            migrationBuilder.CreateIndex(
                name: "IX_Conflicts_JobID",
                table: "Conflicts",
                column: "JobID");

            migrationBuilder.CreateIndex(
                name: "IX_Estimates_CompanyID",
                table: "Estimates",
                column: "CompanyID");

            migrationBuilder.CreateIndex(
                name: "IX_Estimates_FreelancerID",
                table: "Estimates",
                column: "FreelancerID");

            migrationBuilder.CreateIndex(
                name: "IX_Estimates_UserID",
                table: "Estimates",
                column: "UserID");

            migrationBuilder.CreateIndex(
                name: "IX_Invoices_CompanyID",
                table: "Invoices",
                column: "CompanyID");

            migrationBuilder.CreateIndex(
                name: "IX_Invoices_FreelancerID",
                table: "Invoices",
                column: "FreelancerID");

            migrationBuilder.CreateIndex(
                name: "IX_Invoices_StatusID",
                table: "Invoices",
                column: "StatusID");

            migrationBuilder.CreateIndex(
                name: "IX_Invoices_UserID",
                table: "Invoices",
                column: "UserID");

            migrationBuilder.CreateIndex(
                name: "IX_JobAvailability_CompanyID",
                table: "JobAvailability",
                column: "CompanyID");

            migrationBuilder.CreateIndex(
                name: "IX_JobAvailability_FreelancerID",
                table: "JobAvailability",
                column: "FreelancerID");

            migrationBuilder.CreateIndex(
                name: "IX_Jobs_CompanyID",
                table: "Jobs",
                column: "CompanyID");

            migrationBuilder.CreateIndex(
                name: "IX_Jobs_EstimateID",
                table: "Jobs",
                column: "EstimateID");

            migrationBuilder.CreateIndex(
                name: "IX_Jobs_FreelancerID",
                table: "Jobs",
                column: "FreelancerID");

            migrationBuilder.CreateIndex(
                name: "IX_Jobs_InvoiceID",
                table: "Jobs",
                column: "InvoiceID");

            migrationBuilder.CreateIndex(
                name: "IX_Jobs_StatusID",
                table: "Jobs",
                column: "StatusID");

            migrationBuilder.CreateIndex(
                name: "IX_Jobs_UserID",
                table: "Jobs",
                column: "UserID");

            migrationBuilder.CreateIndex(
                name: "UQ__JobStatu__05E7698ADA5572F0",
                table: "JobStatuses",
                column: "StatusName",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "UQ__Workers__1788CCAD93F5CE3F",
                table: "Workers",
                column: "UserID",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK__Freelance__Worke__4AB81AF0",
                table: "Freelancers",
                column: "WorkerID",
                principalTable: "Workers",
                principalColumn: "WorkerID",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK__Services__Compan__4E88ABD4",
                table: "Services",
                column: "CompanyID",
                principalTable: "Companies",
                principalColumn: "CompanyID");

            migrationBuilder.AddForeignKey(
                name: "FK__Services__Freela__4D94879B",
                table: "Services",
                column: "FreelancerID",
                principalTable: "Freelancers",
                principalColumn: "WorkerID");

            migrationBuilder.AddForeignKey(
                name: "FK__UserRoles__RoleI__3E52440B",
                table: "UserRoles",
                column: "RoleID",
                principalTable: "Roles",
                principalColumn: "RoleID");

            migrationBuilder.AddForeignKey(
                name: "FK__UserRoles__UserI__3D5E1FD2",
                table: "UserRoles",
                column: "UserID",
                principalTable: "Users",
                principalColumn: "UserID");
        }
    }
}
