using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace KoRadio.Services.Migrations
{
    /// <inheritdoc />
    public partial class StoresRefactorFix2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<TimeOnly>(
                name: "EndTime",
                table: "Stores",
                type: "time",
                nullable: false,
                defaultValue: new TimeOnly(0, 0, 0));

            migrationBuilder.AddColumn<TimeOnly>(
                name: "StartTime",
                table: "Stores",
                type: "time",
                nullable: false,
                defaultValue: new TimeOnly(0, 0, 0));

            migrationBuilder.AddColumn<int>(
                name: "WorkingDays",
                table: "Stores",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.UpdateData(
                table: "Stores",
                keyColumn: "StoreId",
                keyValue: 1,
                columns: new[] { "EndTime", "StartTime", "WorkingDays" },
                values: new object[] { new TimeOnly(0, 0, 0), new TimeOnly(0, 0, 0), 0 });

            migrationBuilder.UpdateData(
                table: "Stores",
                keyColumn: "StoreId",
                keyValue: 2,
                columns: new[] { "EndTime", "StartTime", "WorkingDays" },
                values: new object[] { new TimeOnly(0, 0, 0), new TimeOnly(0, 0, 0), 0 });

            migrationBuilder.UpdateData(
                table: "Stores",
                keyColumn: "StoreId",
                keyValue: 3,
                columns: new[] { "EndTime", "StartTime", "WorkingDays" },
                values: new object[] { new TimeOnly(0, 0, 0), new TimeOnly(0, 0, 0), 0 });

            migrationBuilder.UpdateData(
                table: "Stores",
                keyColumn: "StoreId",
                keyValue: 4,
                columns: new[] { "EndTime", "StartTime", "WorkingDays" },
                values: new object[] { new TimeOnly(0, 0, 0), new TimeOnly(0, 0, 0), 0 });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "EndTime",
                table: "Stores");

            migrationBuilder.DropColumn(
                name: "StartTime",
                table: "Stores");

            migrationBuilder.DropColumn(
                name: "WorkingDays",
                table: "Stores");
        }
    }
}
