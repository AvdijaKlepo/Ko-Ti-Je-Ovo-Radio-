using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace KoRadio.Services.Migrations
{
    /// <inheritdoc />
    public partial class orderItemProductPrice : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "ProductPrice",
                table: "OrderItems",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.UpdateData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 1,
                column: "ProductPrice",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 2,
                column: "ProductPrice",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 3,
                column: "ProductPrice",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 4,
                column: "ProductPrice",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 5,
                column: "ProductPrice",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 6,
                column: "ProductPrice",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 7,
                column: "ProductPrice",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 8,
                column: "ProductPrice",
                value: 0m);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ProductPrice",
                table: "OrderItems");
        }
    }
}
