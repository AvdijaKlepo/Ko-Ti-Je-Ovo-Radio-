using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace KoRadio.Services.Migrations
{
    /// <inheritdoc />
    public partial class StoresRefactor : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsOnSale",
                table: "Products",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<decimal>(
                name: "SalePrice",
                table: "Products",
                type: "decimal(18,2)",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StockQuantity",
                table: "Products",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<decimal>(
                name: "Price",
                table: "Orders",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "UnitPrice",
                table: "OrderItems",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.UpdateData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 1,
                column: "UnitPrice",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 2,
                column: "UnitPrice",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 3,
                column: "UnitPrice",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 4,
                column: "UnitPrice",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 5,
                column: "UnitPrice",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 6,
                column: "UnitPrice",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 7,
                column: "UnitPrice",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 8,
                column: "UnitPrice",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 1,
                column: "Price",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 2,
                column: "Price",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 3,
                column: "Price",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 4,
                column: "Price",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 1,
                columns: new[] { "IsOnSale", "SalePrice", "StockQuantity" },
                values: new object[] { false, null, 0 });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 2,
                columns: new[] { "IsOnSale", "SalePrice", "StockQuantity" },
                values: new object[] { false, null, 0 });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 3,
                columns: new[] { "IsOnSale", "SalePrice", "StockQuantity" },
                values: new object[] { false, null, 0 });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 4,
                columns: new[] { "IsOnSale", "SalePrice", "StockQuantity" },
                values: new object[] { false, null, 0 });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 5,
                columns: new[] { "IsOnSale", "SalePrice", "StockQuantity" },
                values: new object[] { false, null, 0 });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 6,
                columns: new[] { "IsOnSale", "SalePrice", "StockQuantity" },
                values: new object[] { false, null, 0 });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 7,
                columns: new[] { "IsOnSale", "SalePrice", "StockQuantity" },
                values: new object[] { false, null, 0 });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 8,
                columns: new[] { "IsOnSale", "SalePrice", "StockQuantity" },
                values: new object[] { false, null, 0 });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 9,
                columns: new[] { "IsOnSale", "SalePrice", "StockQuantity" },
                values: new object[] { false, null, 0 });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 10,
                columns: new[] { "IsOnSale", "SalePrice", "StockQuantity" },
                values: new object[] { false, null, 0 });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 11,
                columns: new[] { "IsOnSale", "SalePrice", "StockQuantity" },
                values: new object[] { false, null, 0 });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 12,
                columns: new[] { "IsOnSale", "SalePrice", "StockQuantity" },
                values: new object[] { false, null, 0 });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 13,
                columns: new[] { "IsOnSale", "SalePrice", "StockQuantity" },
                values: new object[] { false, null, 0 });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 14,
                columns: new[] { "IsOnSale", "SalePrice", "StockQuantity" },
                values: new object[] { false, null, 0 });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 15,
                columns: new[] { "IsOnSale", "SalePrice", "StockQuantity" },
                values: new object[] { false, null, 0 });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 16,
                columns: new[] { "IsOnSale", "SalePrice", "StockQuantity" },
                values: new object[] { false, null, 0 });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsOnSale",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "SalePrice",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "StockQuantity",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "Price",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "UnitPrice",
                table: "OrderItems");
        }
    }
}
