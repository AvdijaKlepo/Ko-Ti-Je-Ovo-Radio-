using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace KoRadio.Services.Migrations
{
    /// <inheritdoc />
    public partial class init : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Companies",
                columns: table => new
                {
                    CompanyID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CompanyName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    Bio = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Companie__2D971C4C6BA2CBCD", x => x.CompanyID);
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
                name: "Roles",
                columns: table => new
                {
                    RoleID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    RoleName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    RoleDescription = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Roles__8AFACE3A92DD3D4B", x => x.RoleID);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    UserID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FirstName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    LastName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    Email = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    PasswordHash = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    PasswordSalt = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: true, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Users__1788CCACDE55EC71", x => x.UserID);
                });

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
                name: "UserRoles",
                columns: table => new
                {
                    UserRolesID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserID = table.Column<int>(type: "int", nullable: true),
                    RoleID = table.Column<int>(type: "int", nullable: true),
                    ChangedAt = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__UserRole__43D8C0CDAC829069", x => x.UserRolesID);
                    table.ForeignKey(
                        name: "FK__UserRoles__RoleI__3E52440B",
                        column: x => x.RoleID,
                        principalTable: "Roles",
                        principalColumn: "RoleID");
                    table.ForeignKey(
                        name: "FK__UserRoles__UserI__3D5E1FD2",
                        column: x => x.UserID,
                        principalTable: "Users",
                        principalColumn: "UserID");
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
                name: "CompanyWorkers",
                columns: table => new
                {
                    CompanyWorkersID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    WorkerID = table.Column<int>(type: "int", nullable: false),
                    CompanyID = table.Column<int>(type: "int", nullable: false)
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
                name: "Freelancers",
                columns: table => new
                {
                    WorkerID = table.Column<int>(type: "int", nullable: false),
                    Bio = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Freelanc__077C880650C2883E", x => x.WorkerID);
                    table.ForeignKey(
                        name: "FK__Freelance__Worke__4AB81AF0",
                        column: x => x.WorkerID,
                        principalTable: "Workers",
                        principalColumn: "WorkerID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Estimates",
                columns: table => new
                {
                    EstimateID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserID = table.Column<int>(type: "int", nullable: false),
                    FreelancerID = table.Column<int>(type: "int", nullable: false),
                    CompanyID = table.Column<int>(type: "int", nullable: true),
                    Description = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: false),
                    EstimatedCost = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    CreatedAT = table.Column<DateTime>(type: "datetime", nullable: true, defaultValueSql: "(getdate())")
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
                name: "Invoices",
                columns: table => new
                {
                    InvoiceID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserID = table.Column<int>(type: "int", nullable: false),
                    FreelancerID = table.Column<int>(type: "int", nullable: false),
                    CompanyID = table.Column<int>(type: "int", nullable: true),
                    Amount = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    StatusID = table.Column<int>(type: "int", nullable: false),
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
                name: "JobAvailability",
                columns: table => new
                {
                    JobAvailabilityID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FreelancerID = table.Column<int>(type: "int", nullable: true),
                    CompanyID = table.Column<int>(type: "int", nullable: true),
                    StartTime = table.Column<DateTime>(type: "datetime", nullable: false),
                    EndTime = table.Column<DateTime>(type: "datetime", nullable: false),
                    IsAvailable = table.Column<bool>(type: "bit", nullable: true)
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
                name: "Services",
                columns: table => new
                {
                    ServiceID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    FreelancerID = table.Column<int>(type: "int", nullable: true),
                    CompanyID = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Services__C51BB0EAD9D99D16", x => x.ServiceID);
                    table.ForeignKey(
                        name: "FK__Services__Compan__4E88ABD4",
                        column: x => x.CompanyID,
                        principalTable: "Companies",
                        principalColumn: "CompanyID");
                    table.ForeignKey(
                        name: "FK__Services__Freela__4D94879B",
                        column: x => x.FreelancerID,
                        principalTable: "Freelancers",
                        principalColumn: "WorkerID");
                });

            migrationBuilder.CreateTable(
                name: "Jobs",
                columns: table => new
                {
                    JobID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserID = table.Column<int>(type: "int", nullable: false),
                    FreelancerID = table.Column<int>(type: "int", nullable: true),
                    CompanyID = table.Column<int>(type: "int", nullable: true),
                    EstimateID = table.Column<int>(type: "int", nullable: false),
                    InvoiceID = table.Column<int>(type: "int", nullable: true),
                    StatusID = table.Column<int>(type: "int", nullable: false, defaultValue: 1),
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
                name: "UQ__Roles__8A2B61606615CF66",
                table: "Roles",
                column: "RoleName",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Services_CompanyID",
                table: "Services",
                column: "CompanyID");

            migrationBuilder.CreateIndex(
                name: "IX_Services_FreelancerID",
                table: "Services",
                column: "FreelancerID");

            migrationBuilder.CreateIndex(
                name: "IX_UserRoles_RoleID",
                table: "UserRoles",
                column: "RoleID");

            migrationBuilder.CreateIndex(
                name: "IX_UserRoles_UserID",
                table: "UserRoles",
                column: "UserID");

            migrationBuilder.CreateIndex(
                name: "UQ__Workers__1788CCAD93F5CE3F",
                table: "Workers",
                column: "UserID",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CompanyAdministrator");

            migrationBuilder.DropTable(
                name: "CompanyWorkers");

            migrationBuilder.DropTable(
                name: "Conflicts");

            migrationBuilder.DropTable(
                name: "JobAvailability");

            migrationBuilder.DropTable(
                name: "Services");

            migrationBuilder.DropTable(
                name: "UserRoles");

            migrationBuilder.DropTable(
                name: "Jobs");

            migrationBuilder.DropTable(
                name: "Roles");

            migrationBuilder.DropTable(
                name: "Estimates");

            migrationBuilder.DropTable(
                name: "Invoices");

            migrationBuilder.DropTable(
                name: "Companies");

            migrationBuilder.DropTable(
                name: "Freelancers");

            migrationBuilder.DropTable(
                name: "JobStatuses");

            migrationBuilder.DropTable(
                name: "Workers");

            migrationBuilder.DropTable(
                name: "Users");
        }
    }
}
