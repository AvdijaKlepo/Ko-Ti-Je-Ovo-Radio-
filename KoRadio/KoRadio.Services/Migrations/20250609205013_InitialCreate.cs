using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace KoRadio.Services.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__Freelance__UserI__123EB7A3",
                table: "Freelancer");

            migrationBuilder.DropForeignKey(
                name: "FK__Freelance__Freel__1BC821DD",
                table: "FreelancerService");

            migrationBuilder.DropForeignKey(
                name: "FK__Freelance__Servi__1CBC4616",
                table: "FreelancerService");

            migrationBuilder.DropForeignKey(
                name: "FK_UserRoles_Roles_RoleID",
                table: "UserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK_UserRoles_Users_UserID",
                table: "UserRoles");

            migrationBuilder.DropPrimaryKey(
                name: "PK__UserRole__43D8C0CDAC829069",
                table: "UserRoles");

            migrationBuilder.DropPrimaryKey(
                name: "PK__Freelanc__81515802354FEB8B",
                table: "FreelancerService");

            migrationBuilder.DropPrimaryKey(
                name: "PK__Freelanc__3D00E30C2F2F998D",
                table: "Freelancer");

            migrationBuilder.DropIndex(
                name: "IX_Freelancer_UserID",
                table: "Freelancer");

            migrationBuilder.DropColumn(
                name: "Slika",
                table: "Service");

            migrationBuilder.DropColumn(
                name: "SlikaThumb",
                table: "Service");

            migrationBuilder.DropColumn(
                name: "isDeleted",
                table: "FreelancerService");

            migrationBuilder.DropColumn(
                name: "Availability",
                table: "Freelancer");

            migrationBuilder.DropColumn(
                name: "HourlyRate",
                table: "Freelancer");

            migrationBuilder.DropColumn(
                name: "Location",
                table: "Freelancer");

            migrationBuilder.DropColumn(
                name: "UserID",
                table: "Freelancer");

            migrationBuilder.DropColumn(
                name: "isDeleted",
                table: "CompanyService");

            migrationBuilder.DropColumn(
                name: "Availability",
                table: "Company");

            migrationBuilder.DropColumn(
                name: "Location",
                table: "Company");

            migrationBuilder.RenameColumn(
                name: "UserRolesID",
                table: "UserRoles",
                newName: "UserRoleID");

            migrationBuilder.RenameColumn(
                name: "CreatedAt",
                table: "FreelancerService",
                newName: "CreatedAT");

            migrationBuilder.AlterColumn<string>(
                name: "PasswordSalt",
                table: "Users",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(255)",
                oldMaxLength: 255,
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "PasswordHash",
                table: "Users",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(255)",
                oldMaxLength: 255,
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "LastName",
                table: "Users",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(100)",
                oldMaxLength: 100,
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "FirstName",
                table: "Users",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(100)",
                oldMaxLength: 100,
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Email",
                table: "Users",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(255)",
                oldMaxLength: 255,
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "CreatedAt",
                table: "Users",
                type: "datetime",
                nullable: false,
                defaultValueSql: "(getdate())",
                oldClrType: typeof(DateTime),
                oldType: "datetime",
                oldNullable: true,
                oldDefaultValueSql: "(getdate())");

            migrationBuilder.AddColumn<string>(
                name: "Address",
                table: "Users",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<byte[]>(
                name: "Image",
                table: "Users",
                type: "varbinary(max)",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsDeleted",
                table: "Users",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "LocationID",
                table: "Users",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "PhoneNumber",
                table: "Users",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AlterColumn<int>(
                name: "UserID",
                table: "UserRoles",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "RoleID",
                table: "UserRoles",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "UserRoles",
                type: "datetime",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AlterColumn<string>(
                name: "ServiceName",
                table: "Service",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(255)",
                oldMaxLength: 255,
                oldNullable: true);

            migrationBuilder.AddColumn<byte[]>(
                name: "Image",
                table: "Service",
                type: "varbinary(max)",
                nullable: false,
                defaultValue: new byte[0]);

            migrationBuilder.AddColumn<bool>(
                name: "IsDeleted",
                table: "Service",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsDeleted",
                table: "Roles",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AlterColumn<DateTime>(
                name: "CreatedAT",
                table: "FreelancerService",
                type: "datetime",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified),
                oldClrType: typeof(DateTime),
                oldType: "datetime",
                oldNullable: true);

            migrationBuilder.AlterColumn<decimal>(
                name: "Rating",
                table: "Freelancer",
                type: "decimal(3,2)",
                nullable: false,
                defaultValue: 0m,
                oldClrType: typeof(decimal),
                oldType: "decimal(3,2)",
                oldNullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "ExperianceYears",
                table: "Freelancer",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Bio",
                table: "Freelancer",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(255)",
                oldMaxLength: 255,
                oldNullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "FreelancerID",
                table: "Freelancer",
                type: "int",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "int")
                .OldAnnotation("SqlServer:Identity", "1, 1");

            migrationBuilder.AddColumn<TimeOnly>(
                name: "EndTime",
                table: "Freelancer",
                type: "time",
                nullable: false,
                defaultValue: new TimeOnly(0, 0, 0));

            migrationBuilder.AddColumn<bool>(
                name: "IsApplicant",
                table: "Freelancer",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsDeleted",
                table: "Freelancer",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<TimeOnly>(
                name: "StartTime",
                table: "Freelancer",
                type: "time",
                nullable: false,
                defaultValue: new TimeOnly(0, 0, 0));

            migrationBuilder.AddColumn<int>(
                name: "WorkingDays",
                table: "Freelancer",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AlterColumn<DateTime>(
                name: "CreatedAt",
                table: "CompanyService",
                type: "datetime",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified),
                oldClrType: typeof(DateTime),
                oldType: "datetime",
                oldNullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "UserID",
                table: "CompanyEmployee",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsDeleted",
                table: "CompanyEmployee",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AlterColumn<string>(
                name: "PhoneNumber",
                table: "Company",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(20)",
                oldMaxLength: 20,
                oldNullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "ExperianceYears",
                table: "Company",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Bio",
                table: "Company",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(255)",
                oldMaxLength: 255,
                oldNullable: true);

            migrationBuilder.AddColumn<TimeOnly>(
                name: "EndTime",
                table: "Company",
                type: "time",
                nullable: false,
                defaultValue: new TimeOnly(0, 0, 0));

            migrationBuilder.AddColumn<byte[]>(
                name: "Image",
                table: "Company",
                type: "varbinary(max)",
                nullable: false,
                defaultValue: new byte[0]);

            migrationBuilder.AddColumn<bool>(
                name: "IsDeleted",
                table: "Company",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "LocationID",
                table: "Company",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<TimeOnly>(
                name: "StartTime",
                table: "Company",
                type: "time",
                nullable: false,
                defaultValue: new TimeOnly(0, 0, 0));

            migrationBuilder.AddColumn<int>(
                name: "WorkingDays",
                table: "Company",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddPrimaryKey(
                name: "PK__UserRole__3D978A551693E34E",
                table: "UserRoles",
                column: "UserRoleID");

            migrationBuilder.AddPrimaryKey(
                name: "PK__Freelanc__815158029BB39A82",
                table: "FreelancerService",
                columns: new[] { "FreelancerID", "ServiceID" });

            migrationBuilder.AddPrimaryKey(
                name: "PK__Freelanc__3D00E30C80E0E635",
                table: "Freelancer",
                column: "FreelancerID");

            migrationBuilder.CreateTable(
                name: "Jobs",
                columns: table => new
                {
                    JobId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserID = table.Column<int>(type: "int", nullable: false),
                    StartEstimate = table.Column<TimeOnly>(type: "time", nullable: false),
                    EndEstimate = table.Column<TimeOnly>(type: "time", nullable: true),
                    PayEstimate = table.Column<decimal>(type: "decimal(10,2)", nullable: true),
                    PayInvoice = table.Column<decimal>(type: "decimal(10,2)", nullable: true),
                    JobDate = table.Column<DateTime>(type: "datetime", nullable: false),
                    JobDescription = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Image = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    Job_Status = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: false, defaultValue: "unnaproved"),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    FreelancerID = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Jobs__056690C234DE197E", x => x.JobId);
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
                        principalColumn: "JobId");
                    table.ForeignKey(
                        name: "FK__JobsServi__Servi__793DFFAF",
                        column: x => x.ServiceId,
                        principalTable: "Service",
                        principalColumn: "ServiceID");
                });

            migrationBuilder.CreateIndex(
                name: "IX_Users_LocationID",
                table: "Users",
                column: "LocationID");

            migrationBuilder.CreateIndex(
                name: "UQ_Users_Email",
                table: "Users",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Company_LocationID",
                table: "Company",
                column: "LocationID");

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

            migrationBuilder.AddForeignKey(
                name: "FK__Company__Locatio__0F2D40CE",
                table: "Company",
                column: "LocationID",
                principalTable: "Locations",
                principalColumn: "LocationID");

            migrationBuilder.AddForeignKey(
                name: "FK__Freelance__Freel__1B9317B3",
                table: "Freelancer",
                column: "FreelancerID",
                principalTable: "Users",
                principalColumn: "UserID");

            migrationBuilder.AddForeignKey(
                name: "FK__Freelance__Freel__1F63A897",
                table: "FreelancerService",
                column: "FreelancerID",
                principalTable: "Freelancer",
                principalColumn: "FreelancerID");

            migrationBuilder.AddForeignKey(
                name: "FK__Freelance__Servi__2057CCD0",
                table: "FreelancerService",
                column: "ServiceID",
                principalTable: "Service",
                principalColumn: "ServiceID");

            migrationBuilder.AddForeignKey(
                name: "FK__UserRoles__RoleI__16CE6296",
                table: "UserRoles",
                column: "RoleID",
                principalTable: "Roles",
                principalColumn: "RoleID");

            migrationBuilder.AddForeignKey(
                name: "FK__UserRoles__UserI__15DA3E5D",
                table: "UserRoles",
                column: "UserID",
                principalTable: "Users",
                principalColumn: "UserID");

            migrationBuilder.AddForeignKey(
                name: "FK__Users__LocationI__0E391C95",
                table: "Users",
                column: "LocationID",
                principalTable: "Locations",
                principalColumn: "LocationID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__Company__Locatio__0F2D40CE",
                table: "Company");

            migrationBuilder.DropForeignKey(
                name: "FK__Freelance__Freel__1B9317B3",
                table: "Freelancer");

            migrationBuilder.DropForeignKey(
                name: "FK__Freelance__Freel__1F63A897",
                table: "FreelancerService");

            migrationBuilder.DropForeignKey(
                name: "FK__Freelance__Servi__2057CCD0",
                table: "FreelancerService");

            migrationBuilder.DropForeignKey(
                name: "FK__UserRoles__RoleI__16CE6296",
                table: "UserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK__UserRoles__UserI__15DA3E5D",
                table: "UserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK__Users__LocationI__0E391C95",
                table: "Users");

            migrationBuilder.DropTable(
                name: "JobsService");

            migrationBuilder.DropTable(
                name: "Locations");

            migrationBuilder.DropTable(
                name: "Jobs");

            migrationBuilder.DropIndex(
                name: "IX_Users_LocationID",
                table: "Users");

            migrationBuilder.DropIndex(
                name: "UQ_Users_Email",
                table: "Users");

            migrationBuilder.DropPrimaryKey(
                name: "PK__UserRole__3D978A551693E34E",
                table: "UserRoles");

            migrationBuilder.DropPrimaryKey(
                name: "PK__Freelanc__815158029BB39A82",
                table: "FreelancerService");

            migrationBuilder.DropPrimaryKey(
                name: "PK__Freelanc__3D00E30C80E0E635",
                table: "Freelancer");

            migrationBuilder.DropIndex(
                name: "IX_Company_LocationID",
                table: "Company");

            migrationBuilder.DropColumn(
                name: "Address",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "Image",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "IsDeleted",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "LocationID",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "PhoneNumber",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "UserRoles");

            migrationBuilder.DropColumn(
                name: "Image",
                table: "Service");

            migrationBuilder.DropColumn(
                name: "IsDeleted",
                table: "Service");

            migrationBuilder.DropColumn(
                name: "IsDeleted",
                table: "Roles");

            migrationBuilder.DropColumn(
                name: "EndTime",
                table: "Freelancer");

            migrationBuilder.DropColumn(
                name: "IsApplicant",
                table: "Freelancer");

            migrationBuilder.DropColumn(
                name: "IsDeleted",
                table: "Freelancer");

            migrationBuilder.DropColumn(
                name: "StartTime",
                table: "Freelancer");

            migrationBuilder.DropColumn(
                name: "WorkingDays",
                table: "Freelancer");

            migrationBuilder.DropColumn(
                name: "IsDeleted",
                table: "CompanyEmployee");

            migrationBuilder.DropColumn(
                name: "EndTime",
                table: "Company");

            migrationBuilder.DropColumn(
                name: "Image",
                table: "Company");

            migrationBuilder.DropColumn(
                name: "IsDeleted",
                table: "Company");

            migrationBuilder.DropColumn(
                name: "LocationID",
                table: "Company");

            migrationBuilder.DropColumn(
                name: "StartTime",
                table: "Company");

            migrationBuilder.DropColumn(
                name: "WorkingDays",
                table: "Company");

            migrationBuilder.RenameColumn(
                name: "UserRoleID",
                table: "UserRoles",
                newName: "UserRolesID");

            migrationBuilder.RenameColumn(
                name: "CreatedAT",
                table: "FreelancerService",
                newName: "CreatedAt");

            migrationBuilder.AlterColumn<string>(
                name: "PasswordSalt",
                table: "Users",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(255)",
                oldMaxLength: 255);

            migrationBuilder.AlterColumn<string>(
                name: "PasswordHash",
                table: "Users",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(255)",
                oldMaxLength: 255);

            migrationBuilder.AlterColumn<string>(
                name: "LastName",
                table: "Users",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(100)",
                oldMaxLength: 100);

            migrationBuilder.AlterColumn<string>(
                name: "FirstName",
                table: "Users",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(100)",
                oldMaxLength: 100);

            migrationBuilder.AlterColumn<string>(
                name: "Email",
                table: "Users",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(255)",
                oldMaxLength: 255);

            migrationBuilder.AlterColumn<DateTime>(
                name: "CreatedAt",
                table: "Users",
                type: "datetime",
                nullable: true,
                defaultValueSql: "(getdate())",
                oldClrType: typeof(DateTime),
                oldType: "datetime",
                oldDefaultValueSql: "(getdate())");

            migrationBuilder.AlterColumn<int>(
                name: "UserID",
                table: "UserRoles",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AlterColumn<int>(
                name: "RoleID",
                table: "UserRoles",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AlterColumn<string>(
                name: "ServiceName",
                table: "Service",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(255)",
                oldMaxLength: 255);

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

            migrationBuilder.AlterColumn<DateTime>(
                name: "CreatedAt",
                table: "FreelancerService",
                type: "datetime",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "datetime");

            migrationBuilder.AddColumn<bool>(
                name: "isDeleted",
                table: "FreelancerService",
                type: "bit",
                nullable: true);

            migrationBuilder.AlterColumn<decimal>(
                name: "Rating",
                table: "Freelancer",
                type: "decimal(3,2)",
                nullable: true,
                oldClrType: typeof(decimal),
                oldType: "decimal(3,2)");

            migrationBuilder.AlterColumn<int>(
                name: "ExperianceYears",
                table: "Freelancer",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AlterColumn<string>(
                name: "Bio",
                table: "Freelancer",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(255)",
                oldMaxLength: 255);

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

            migrationBuilder.AddColumn<int>(
                name: "UserID",
                table: "Freelancer",
                type: "int",
                nullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "CreatedAt",
                table: "CompanyService",
                type: "datetime",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "datetime");

            migrationBuilder.AddColumn<bool>(
                name: "isDeleted",
                table: "CompanyService",
                type: "bit",
                nullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "UserID",
                table: "CompanyEmployee",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AlterColumn<string>(
                name: "PhoneNumber",
                table: "Company",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(20)",
                oldMaxLength: 20);

            migrationBuilder.AlterColumn<int>(
                name: "ExperianceYears",
                table: "Company",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AlterColumn<string>(
                name: "Bio",
                table: "Company",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(255)",
                oldMaxLength: 255);

            migrationBuilder.AddColumn<string>(
                name: "Availability",
                table: "Company",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Location",
                table: "Company",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK__UserRole__43D8C0CDAC829069",
                table: "UserRoles",
                column: "UserRolesID");

            migrationBuilder.AddPrimaryKey(
                name: "PK__Freelanc__81515802354FEB8B",
                table: "FreelancerService",
                columns: new[] { "FreelancerID", "ServiceID" });

            migrationBuilder.AddPrimaryKey(
                name: "PK__Freelanc__3D00E30C2F2F998D",
                table: "Freelancer",
                column: "FreelancerID");

            migrationBuilder.CreateIndex(
                name: "IX_Freelancer_UserID",
                table: "Freelancer",
                column: "UserID");

            migrationBuilder.AddForeignKey(
                name: "FK__Freelance__UserI__123EB7A3",
                table: "Freelancer",
                column: "UserID",
                principalTable: "Users",
                principalColumn: "UserID");

            migrationBuilder.AddForeignKey(
                name: "FK__Freelance__Freel__1BC821DD",
                table: "FreelancerService",
                column: "FreelancerID",
                principalTable: "Freelancer",
                principalColumn: "FreelancerID",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK__Freelance__Servi__1CBC4616",
                table: "FreelancerService",
                column: "ServiceID",
                principalTable: "Service",
                principalColumn: "ServiceID",
                onDelete: ReferentialAction.Cascade);

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
    }
}
