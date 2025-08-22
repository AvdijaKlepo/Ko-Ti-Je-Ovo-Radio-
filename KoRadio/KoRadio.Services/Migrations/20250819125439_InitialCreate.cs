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
                name: "FK_Products_Services",
                table: "Products");

            migrationBuilder.DropPrimaryKey(
                name: "PK__Products__B40CC6CDDC48DB00",
                table: "Products");

            migrationBuilder.DropIndex(
                name: "IX_Products_ServiceId",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "ServiceId",
                table: "Products");

            migrationBuilder.AddColumn<int>(
                name: "CompanyID",
                table: "UserRatings",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Address",
                table: "Stores",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.AddColumn<byte[]>(
                name: "Image",
                table: "Stores",
                type: "varbinary(max)",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsApplicant",
                table: "Stores",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsDeleted",
                table: "Stores",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "LocationId",
                table: "Stores",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<byte[]>(
                name: "Image",
                table: "Products",
                type: "varbinary(max)",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsDeleted",
                table: "Products",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "Orders",
                type: "datetime",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<bool>(
                name: "IsCancelled",
                table: "Orders",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsShipped",
                table: "Orders",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "StoreId",
                table: "OrderItems",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "CompanyID",
                table: "Messages",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "Messages",
                type: "datetime",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<bool>(
                name: "IsOpened",
                table: "Messages",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "StoreId",
                table: "Messages",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsApproved",
                table: "Jobs",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsDeletedWorker",
                table: "Jobs",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsEdited",
                table: "Jobs",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsInvoiced",
                table: "Jobs",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsRated",
                table: "Jobs",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "JobTitle",
                table: "Jobs",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "RescheduleNote",
                table: "Jobs",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "isFreelancer",
                table: "Jobs",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "isTenderFinalized",
                table: "Jobs",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsFinished",
                table: "CompanyJobAssignment",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<decimal>(
                name: "RatingSum",
                table: "Company",
                type: "decimal(10,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<int>(
                name: "TotalRatings",
                table: "Company",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddPrimaryKey(
                name: "PK__Products__B40CC6CDD7BA1DD8",
                table: "Products",
                column: "ProductId");

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
                        principalColumn: "JobId");
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

            migrationBuilder.CreateIndex(
                name: "IX_UserRatings_CompanyID",
                table: "UserRatings",
                column: "CompanyID");

            migrationBuilder.CreateIndex(
                name: "IX_Stores_LocationId",
                table: "Stores",
                column: "LocationId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderItems_StoreId",
                table: "OrderItems",
                column: "StoreId");

            migrationBuilder.CreateIndex(
                name: "IX_Messages_CompanyID",
                table: "Messages",
                column: "CompanyID");

            migrationBuilder.CreateIndex(
                name: "IX_Messages_StoreId",
                table: "Messages",
                column: "StoreId");

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
                name: "IX_ProductsService_ServiceID",
                table: "ProductsService",
                column: "ServiceID");

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

            migrationBuilder.AddForeignKey(
                name: "FK__Messages__Compan__7E8CC4B1",
                table: "Messages",
                column: "CompanyID",
                principalTable: "Company",
                principalColumn: "CompanyID");

            migrationBuilder.AddForeignKey(
                name: "FK__Messages__StoreI__7F80E8EA",
                table: "Messages",
                column: "StoreId",
                principalTable: "Stores",
                principalColumn: "StoreId");

            migrationBuilder.AddForeignKey(
                name: "FK_OrderItems_Stores",
                table: "OrderItems",
                column: "StoreId",
                principalTable: "Stores",
                principalColumn: "StoreId");

            migrationBuilder.AddForeignKey(
                name: "FK__Stores__Location__4460231C",
                table: "Stores",
                column: "LocationId",
                principalTable: "Locations",
                principalColumn: "LocationID");

            migrationBuilder.AddForeignKey(
                name: "FK__UserRatin__Compa__6B79F03D",
                table: "UserRatings",
                column: "CompanyID",
                principalTable: "Company",
                principalColumn: "CompanyID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__Messages__Compan__7E8CC4B1",
                table: "Messages");

            migrationBuilder.DropForeignKey(
                name: "FK__Messages__StoreI__7F80E8EA",
                table: "Messages");

            migrationBuilder.DropForeignKey(
                name: "FK_OrderItems_Stores",
                table: "OrderItems");

            migrationBuilder.DropForeignKey(
                name: "FK__Stores__Location__4460231C",
                table: "Stores");

            migrationBuilder.DropForeignKey(
                name: "FK__UserRatin__Compa__6B79F03D",
                table: "UserRatings");

            migrationBuilder.DropTable(
                name: "EmployeeTask");

            migrationBuilder.DropTable(
                name: "ProductsService");

            migrationBuilder.DropTable(
                name: "TenderBid");

            migrationBuilder.DropTable(
                name: "TenderService");

            migrationBuilder.DropTable(
                name: "Tender");

            migrationBuilder.DropIndex(
                name: "IX_UserRatings_CompanyID",
                table: "UserRatings");

            migrationBuilder.DropIndex(
                name: "IX_Stores_LocationId",
                table: "Stores");

            migrationBuilder.DropPrimaryKey(
                name: "PK__Products__B40CC6CDD7BA1DD8",
                table: "Products");

            migrationBuilder.DropIndex(
                name: "IX_OrderItems_StoreId",
                table: "OrderItems");

            migrationBuilder.DropIndex(
                name: "IX_Messages_CompanyID",
                table: "Messages");

            migrationBuilder.DropIndex(
                name: "IX_Messages_StoreId",
                table: "Messages");

            migrationBuilder.DropColumn(
                name: "CompanyID",
                table: "UserRatings");

            migrationBuilder.DropColumn(
                name: "Address",
                table: "Stores");

            migrationBuilder.DropColumn(
                name: "Image",
                table: "Stores");

            migrationBuilder.DropColumn(
                name: "IsApplicant",
                table: "Stores");

            migrationBuilder.DropColumn(
                name: "IsDeleted",
                table: "Stores");

            migrationBuilder.DropColumn(
                name: "LocationId",
                table: "Stores");

            migrationBuilder.DropColumn(
                name: "Image",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "IsDeleted",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "IsCancelled",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "IsShipped",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "StoreId",
                table: "OrderItems");

            migrationBuilder.DropColumn(
                name: "CompanyID",
                table: "Messages");

            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "Messages");

            migrationBuilder.DropColumn(
                name: "IsOpened",
                table: "Messages");

            migrationBuilder.DropColumn(
                name: "StoreId",
                table: "Messages");

            migrationBuilder.DropColumn(
                name: "IsApproved",
                table: "Jobs");

            migrationBuilder.DropColumn(
                name: "IsDeletedWorker",
                table: "Jobs");

            migrationBuilder.DropColumn(
                name: "IsEdited",
                table: "Jobs");

            migrationBuilder.DropColumn(
                name: "IsInvoiced",
                table: "Jobs");

            migrationBuilder.DropColumn(
                name: "IsRated",
                table: "Jobs");

            migrationBuilder.DropColumn(
                name: "JobTitle",
                table: "Jobs");

            migrationBuilder.DropColumn(
                name: "RescheduleNote",
                table: "Jobs");

            migrationBuilder.DropColumn(
                name: "isFreelancer",
                table: "Jobs");

            migrationBuilder.DropColumn(
                name: "isTenderFinalized",
                table: "Jobs");

            migrationBuilder.DropColumn(
                name: "IsFinished",
                table: "CompanyJobAssignment");

            migrationBuilder.DropColumn(
                name: "RatingSum",
                table: "Company");

            migrationBuilder.DropColumn(
                name: "TotalRatings",
                table: "Company");

            migrationBuilder.AddColumn<int>(
                name: "ServiceId",
                table: "Products",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddPrimaryKey(
                name: "PK__Products__B40CC6CDDC48DB00",
                table: "Products",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_Products_ServiceId",
                table: "Products",
                column: "ServiceId");

            migrationBuilder.AddForeignKey(
                name: "FK_Products_Services",
                table: "Products",
                column: "ServiceId",
                principalTable: "Service",
                principalColumn: "ServiceID");
        }
    }
}
