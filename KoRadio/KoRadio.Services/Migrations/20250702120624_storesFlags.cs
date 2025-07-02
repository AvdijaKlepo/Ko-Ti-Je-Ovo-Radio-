using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace KoRadio.Services.Migrations
{
    /// <inheritdoc />
    public partial class storesFlags : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_OrderItems_Orders_OrderId",
                table: "OrderItems");

            migrationBuilder.DropForeignKey(
                name: "FK_OrderItems_Products_ProductId",
                table: "OrderItems");

            migrationBuilder.DropForeignKey(
                name: "FK_Orders_Users_UserId",
                table: "Orders");

            migrationBuilder.DropForeignKey(
                name: "FK_Products_Service_ServiceId",
                table: "Products");

            migrationBuilder.DropForeignKey(
                name: "FK_Products_Store_StoreId",
                table: "Products");

            migrationBuilder.DropForeignKey(
                name: "FK_Store_Users_UserId",
                table: "Store");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Products",
                table: "Products");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Orders",
                table: "Orders");

            migrationBuilder.DropPrimaryKey(
                name: "PK_OrderItems",
                table: "OrderItems");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Store",
                table: "Store");

            migrationBuilder.RenameTable(
                name: "Store",
                newName: "Stores");

            migrationBuilder.RenameIndex(
                name: "IX_Store_UserId",
                table: "Stores",
                newName: "IX_Stores_UserId");

            migrationBuilder.AlterColumn<string>(
                name: "ProductName",
                table: "Products",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.AlterColumn<string>(
                name: "StoreName",
                table: "Stores",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.AddPrimaryKey(
                name: "PK__Products__B40CC6CDDC48DB00",
                table: "Products",
                column: "ProductId");

            migrationBuilder.AddPrimaryKey(
                name: "PK__Orders__C3905BCF591ED19A",
                table: "Orders",
                column: "OrderId");

            migrationBuilder.AddPrimaryKey(
                name: "PK__OrderIte__D5BB2555E439B0B6",
                table: "OrderItems",
                column: "OrderItemsId");

            migrationBuilder.AddPrimaryKey(
                name: "PK__Stores__3B82F10142B7B44A",
                table: "Stores",
                column: "StoreId");

            migrationBuilder.AddForeignKey(
                name: "FK_OrderItems_Orders",
                table: "OrderItems",
                column: "OrderId",
                principalTable: "Orders",
                principalColumn: "OrderId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_OrderItems_Products",
                table: "OrderItems",
                column: "ProductId",
                principalTable: "Products",
                principalColumn: "ProductId");

            migrationBuilder.AddForeignKey(
                name: "FK_Orders_Users",
                table: "Orders",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "UserID");

            migrationBuilder.AddForeignKey(
                name: "FK_Products_Services",
                table: "Products",
                column: "ServiceId",
                principalTable: "Service",
                principalColumn: "ServiceID");

            migrationBuilder.AddForeignKey(
                name: "FK_Products_Stores",
                table: "Products",
                column: "StoreId",
                principalTable: "Stores",
                principalColumn: "StoreId");

            migrationBuilder.AddForeignKey(
                name: "FK_Stores_Users",
                table: "Stores",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "UserID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_OrderItems_Orders",
                table: "OrderItems");

            migrationBuilder.DropForeignKey(
                name: "FK_OrderItems_Products",
                table: "OrderItems");

            migrationBuilder.DropForeignKey(
                name: "FK_Orders_Users",
                table: "Orders");

            migrationBuilder.DropForeignKey(
                name: "FK_Products_Services",
                table: "Products");

            migrationBuilder.DropForeignKey(
                name: "FK_Products_Stores",
                table: "Products");

            migrationBuilder.DropForeignKey(
                name: "FK_Stores_Users",
                table: "Stores");

            migrationBuilder.DropPrimaryKey(
                name: "PK__Products__B40CC6CDDC48DB00",
                table: "Products");

            migrationBuilder.DropPrimaryKey(
                name: "PK__Orders__C3905BCF591ED19A",
                table: "Orders");

            migrationBuilder.DropPrimaryKey(
                name: "PK__OrderIte__D5BB2555E439B0B6",
                table: "OrderItems");

            migrationBuilder.DropPrimaryKey(
                name: "PK__Stores__3B82F10142B7B44A",
                table: "Stores");

            migrationBuilder.RenameTable(
                name: "Stores",
                newName: "Store");

            migrationBuilder.RenameIndex(
                name: "IX_Stores_UserId",
                table: "Store",
                newName: "IX_Store_UserId");

            migrationBuilder.AlterColumn<string>(
                name: "ProductName",
                table: "Products",
                type: "nvarchar(max)",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(100)",
                oldMaxLength: 100);

            migrationBuilder.AlterColumn<string>(
                name: "StoreName",
                table: "Store",
                type: "nvarchar(max)",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(100)",
                oldMaxLength: 100);

            migrationBuilder.AddPrimaryKey(
                name: "PK_Products",
                table: "Products",
                column: "ProductId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Orders",
                table: "Orders",
                column: "OrderId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_OrderItems",
                table: "OrderItems",
                column: "OrderItemsId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Store",
                table: "Store",
                column: "StoreId");

            migrationBuilder.AddForeignKey(
                name: "FK_OrderItems_Orders_OrderId",
                table: "OrderItems",
                column: "OrderId",
                principalTable: "Orders",
                principalColumn: "OrderId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_OrderItems_Products_ProductId",
                table: "OrderItems",
                column: "ProductId",
                principalTable: "Products",
                principalColumn: "ProductId",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Orders_Users_UserId",
                table: "Orders",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "UserID",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Products_Service_ServiceId",
                table: "Products",
                column: "ServiceId",
                principalTable: "Service",
                principalColumn: "ServiceID",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Products_Store_StoreId",
                table: "Products",
                column: "StoreId",
                principalTable: "Store",
                principalColumn: "StoreId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Store_Users_UserId",
                table: "Store",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "UserID",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
