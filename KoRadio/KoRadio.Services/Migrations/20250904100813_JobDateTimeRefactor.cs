using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace KoRadio.Services.Migrations
{
    /// <inheritdoc />
    public partial class JobDateTimeRefactor : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DateFinished",
                table: "Jobs");

            migrationBuilder.DropColumn(
                name: "JobDate",
                table: "Jobs");

            migrationBuilder.AlterColumn<DateTime>(
                name: "StartEstimate",
                table: "Jobs",
                type: "datetime2",
                nullable: true,
                oldClrType: typeof(TimeOnly),
                oldType: "time",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "EndEstimate",
                table: "Jobs",
                type: "datetime2",
                nullable: true,
                oldClrType: typeof(TimeOnly),
                oldType: "time",
                oldNullable: true);

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 1,
                columns: new[] { "EndEstimate", "StartEstimate" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 2,
                columns: new[] { "EndEstimate", "StartEstimate" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 3,
                columns: new[] { "EndEstimate", "StartEstimate" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 4,
                columns: new[] { "EndEstimate", "StartEstimate" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 5,
                columns: new[] { "EndEstimate", "StartEstimate" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 6,
                columns: new[] { "EndEstimate", "StartEstimate" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 7,
                columns: new[] { "EndEstimate", "StartEstimate" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 8,
                columns: new[] { "EndEstimate", "StartEstimate" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 9,
                columns: new[] { "EndEstimate", "StartEstimate" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 10,
                columns: new[] { "EndEstimate", "StartEstimate" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 11,
                columns: new[] { "EndEstimate", "StartEstimate" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 12,
                columns: new[] { "EndEstimate", "StartEstimate" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 13,
                columns: new[] { "EndEstimate", "StartEstimate" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 14,
                columns: new[] { "EndEstimate", "StartEstimate" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 15,
                columns: new[] { "EndEstimate", "StartEstimate" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 16,
                columns: new[] { "EndEstimate", "StartEstimate" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 17,
                columns: new[] { "EndEstimate", "StartEstimate" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 18,
                columns: new[] { "EndEstimate", "StartEstimate" },
                values: new object[] { null, null });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<TimeOnly>(
                name: "StartEstimate",
                table: "Jobs",
                type: "time",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldNullable: true);

            migrationBuilder.AlterColumn<TimeOnly>(
                name: "EndEstimate",
                table: "Jobs",
                type: "time",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldNullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "DateFinished",
                table: "Jobs",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "JobDate",
                table: "Jobs",
                type: "datetime",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 1,
                columns: new[] { "DateFinished", "EndEstimate", "JobDate", "StartEstimate" },
                values: new object[] { null, new TimeOnly(18, 0, 0), new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(10, 0, 0) });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 2,
                columns: new[] { "DateFinished", "EndEstimate", "JobDate", "StartEstimate" },
                values: new object[] { null, new TimeOnly(18, 0, 0), new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(10, 0, 0) });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 3,
                columns: new[] { "DateFinished", "EndEstimate", "JobDate", "StartEstimate" },
                values: new object[] { null, new TimeOnly(18, 0, 0), new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(10, 0, 0) });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 4,
                columns: new[] { "DateFinished", "EndEstimate", "JobDate", "StartEstimate" },
                values: new object[] { new DateTime(2025, 8, 24, 0, 0, 0, 0, DateTimeKind.Unspecified), null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 5,
                columns: new[] { "DateFinished", "EndEstimate", "JobDate", "StartEstimate" },
                values: new object[] { null, new TimeOnly(18, 0, 0), new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(10, 0, 0) });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 6,
                columns: new[] { "DateFinished", "EndEstimate", "JobDate", "StartEstimate" },
                values: new object[] { new DateTime(2025, 8, 24, 0, 0, 0, 0, DateTimeKind.Unspecified), null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 7,
                columns: new[] { "DateFinished", "EndEstimate", "JobDate", "StartEstimate" },
                values: new object[] { null, new TimeOnly(17, 0, 0), new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(9, 0, 0) });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 8,
                columns: new[] { "DateFinished", "EndEstimate", "JobDate", "StartEstimate" },
                values: new object[] { null, new TimeOnly(16, 0, 0), new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(8, 0, 0) });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 9,
                columns: new[] { "DateFinished", "EndEstimate", "JobDate", "StartEstimate" },
                values: new object[] { null, new TimeOnly(15, 0, 0), new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeOnly(7, 0, 0) });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 10,
                columns: new[] { "DateFinished", "EndEstimate", "JobDate", "StartEstimate" },
                values: new object[] { new DateTime(2025, 8, 24, 0, 0, 0, 0, DateTimeKind.Unspecified), null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 11,
                columns: new[] { "DateFinished", "EndEstimate", "JobDate", "StartEstimate" },
                values: new object[] { new DateTime(2025, 8, 24, 0, 0, 0, 0, DateTimeKind.Unspecified), null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 12,
                columns: new[] { "DateFinished", "EndEstimate", "JobDate", "StartEstimate" },
                values: new object[] { new DateTime(2025, 8, 24, 0, 0, 0, 0, DateTimeKind.Unspecified), null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 13,
                columns: new[] { "DateFinished", "EndEstimate", "JobDate", "StartEstimate" },
                values: new object[] { new DateTime(2025, 8, 24, 0, 0, 0, 0, DateTimeKind.Unspecified), null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 14,
                columns: new[] { "DateFinished", "EndEstimate", "JobDate", "StartEstimate" },
                values: new object[] { new DateTime(2025, 8, 24, 0, 0, 0, 0, DateTimeKind.Unspecified), null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 15,
                columns: new[] { "DateFinished", "EndEstimate", "JobDate", "StartEstimate" },
                values: new object[] { new DateTime(2025, 8, 24, 0, 0, 0, 0, DateTimeKind.Unspecified), null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 16,
                columns: new[] { "DateFinished", "EndEstimate", "JobDate", "StartEstimate" },
                values: new object[] { new DateTime(2025, 8, 24, 0, 0, 0, 0, DateTimeKind.Unspecified), null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 17,
                columns: new[] { "DateFinished", "EndEstimate", "JobDate", "StartEstimate" },
                values: new object[] { new DateTime(2025, 8, 24, 0, 0, 0, 0, DateTimeKind.Unspecified), null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Jobs",
                keyColumn: "JobId",
                keyValue: 18,
                columns: new[] { "DateFinished", "EndEstimate", "JobDate", "StartEstimate" },
                values: new object[] { new DateTime(2025, 8, 24, 0, 0, 0, 0, DateTimeKind.Unspecified), null, new DateTime(2025, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), null });
        }
    }
}
