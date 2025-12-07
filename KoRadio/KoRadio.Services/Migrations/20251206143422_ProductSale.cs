using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace KoRadio.Services.Migrations
{
    /// <inheritdoc />
    public partial class ProductSale : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "OrderItems",
                keyColumn: "OrderItemsId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "UserRoles",
                keyColumn: "UserRoleID",
                keyValue: 39);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "OrderId",
                keyValue: 4);

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 1,
                column: "ProductDescription",
                value: " Produžni kabal 5m.");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 2,
                column: "ProductDescription",
                value: "Cat6 Ethernet kabal");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 3,
                columns: new[] { "ProductDescription", "ProductName" },
                values: new object[] { "Standardni prekidač naizmjenične struje.", "Prekidač naizmjenične struje" });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 4,
                columns: new[] { "ProductDescription", "ProductName" },
                values: new object[] { "Energetski efikasna LED sijalica.", "LED sijalica 9W" });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 5,
                columns: new[] { "ProductDescription", "ProductName" },
                values: new object[] { "Visokokvalitetna ravna keramika.", "Ravna keramika" });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 6,
                column: "ProductDescription",
                value: "Izdržljive keramičke pločice.");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 7,
                column: "ProductDescription",
                value: "Kvalitetna fug masa u pakovanju od 5kg.");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 8,
                column: "ProductDescription",
                value: "Snažno ljepilo za keramiku.");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 9,
                column: "ProductDescription",
                value: "Visokokvalitetni cement u pakovanju od 25kg.");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 10,
                column: "ProductDescription",
                value: "Fini pijesak u pakovanju od 50kg.");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 11,
                column: "ProductDescription",
                value: "Kvalitetan malter u pakovanju od 30kg.");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 12,
                column: "ProductDescription",
                value: "Unutrašnja boja za zidove u pakovanju od 5L.");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 13,
                column: "ProductDescription",
                value: "Visokokvalitetni lak za drvo u pakovanju od 1L.");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
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

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 1,
                column: "ProductDescription",
                value: " Produžni kabl dužine 5 metara, idealan za kućnu i kancelarijsku upotrebu.");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 2,
                column: "ProductDescription",
                value: "Visokokvalitetni Ethernet kabal dužine 20 metara za pouzdanu mrežnu povezanost.");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 3,
                columns: new[] { "ProductDescription", "ProductName" },
                values: new object[] { "Standardni prekidač naizmenične struje za kućnu i industrijsku upotrebu.", "Prekidač naizmenične struje" });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 4,
                columns: new[] { "ProductDescription", "ProductName" },
                values: new object[] { "Energetski efikasna LED žarulja snage 9W, pruža jarko svetlo uz nisku potrošnju energije.", "LED žarulja 9W" });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 5,
                columns: new[] { "ProductDescription", "ProductName" },
                values: new object[] { "Visokokvalitetna ravna keramika dimenzija 30x30cm, idealna za podove i zidove.", "Ravna keramika 30x30cm" });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 6,
                column: "ProductDescription",
                value: "Izdržljive keramičke pločice dimenzija 20x20cm, pogodne za različite površine.");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 7,
                column: "ProductDescription",
                value: "Kvalitetna fug masa u pakovanju od 5kg, idealna za popunjavanje spojeva između pločica.");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 8,
                column: "ProductDescription",
                value: "Snažno ljepilo za keramiku u pakovanju od 10kg, pruža čvrsto prizemljivanje pločica na različite površine.");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 9,
                column: "ProductDescription",
                value: "Visokokvalitetni cement u pakovanju od 25kg, pogodan za različite građevinske radove.");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 10,
                column: "ProductDescription",
                value: "Fini pijesak u pakovanju od 50kg, idealan za malterisanje i druge građevinske primjene.");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 11,
                column: "ProductDescription",
                value: "Kvalitetan malter u pakovanju od 30kg, pogodan za unutrašnje i vanjske zidove.");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 12,
                column: "ProductDescription",
                value: "Unutrašnja boja za zidove u pakovanju od 5L, dostupna u različitim bojama.");

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 13,
                column: "ProductDescription",
                value: "Visokokvalitetni lak za drvo u pakovanju od 1L, pruža zaštitu i sjaj drvenim površinama.");

            migrationBuilder.InsertData(
                table: "UserRoles",
                columns: new[] { "UserRoleID", "ChangedAt", "CreatedAt", "RoleID", "UserID" },
                values: new object[] { 39, null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, 7 });

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
        }
    }
}
