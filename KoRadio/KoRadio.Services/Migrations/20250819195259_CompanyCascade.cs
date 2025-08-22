using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace KoRadio.Services.Migrations
{
    /// <inheritdoc />
    public partial class CompanyCascade : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__CompanyEm__Compa__69C6B1F5",
                table: "CompanyEmployee");

            migrationBuilder.AddForeignKey(
                name: "FK__CompanyEm__Compa__69C6B1F5",
                table: "CompanyEmployee",
                column: "CompanyID",
                principalTable: "Company",
                principalColumn: "CompanyID",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__CompanyEm__Compa__69C6B1F5",
                table: "CompanyEmployee");

            migrationBuilder.AddForeignKey(
                name: "FK__CompanyEm__Compa__69C6B1F5",
                table: "CompanyEmployee",
                column: "CompanyID",
                principalTable: "Company",
                principalColumn: "CompanyID");
        }
    }
}
