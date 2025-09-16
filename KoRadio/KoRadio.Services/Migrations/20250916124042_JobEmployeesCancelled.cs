using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace KoRadio.Services.Migrations
{
    /// <inheritdoc />
    public partial class JobEmployeesCancelled : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsCancelled",
                table: "CompanyJobAssignment",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsCancelled",
                table: "CompanyJobAssignment");
        }
    }
}
