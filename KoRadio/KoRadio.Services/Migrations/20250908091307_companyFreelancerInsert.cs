using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace KoRadio.Services.Migrations
{
    /// <inheritdoc />
    public partial class companyFreelancerInsert : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<byte[]>(
                name: "CV",
                table: "Freelancer",
                type: "varbinary(max)",
                nullable: true);

            migrationBuilder.AddColumn<byte[]>(
                name: "BusinessCertificate",
                table: "Company",
                type: "varbinary(max)",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "Company",
                keyColumn: "CompanyID",
                keyValue: 1,
                column: "BusinessCertificate",
                value: null);

            migrationBuilder.UpdateData(
                table: "Company",
                keyColumn: "CompanyID",
                keyValue: 2,
                column: "BusinessCertificate",
                value: null);

            migrationBuilder.UpdateData(
                table: "Company",
                keyColumn: "CompanyID",
                keyValue: 3,
                column: "BusinessCertificate",
                value: null);

            migrationBuilder.UpdateData(
                table: "Company",
                keyColumn: "CompanyID",
                keyValue: 4,
                column: "BusinessCertificate",
                value: null);

            migrationBuilder.UpdateData(
                table: "Company",
                keyColumn: "CompanyID",
                keyValue: 5,
                column: "BusinessCertificate",
                value: null);

            migrationBuilder.UpdateData(
                table: "Company",
                keyColumn: "CompanyID",
                keyValue: 6,
                column: "BusinessCertificate",
                value: null);

            migrationBuilder.UpdateData(
                table: "Company",
                keyColumn: "CompanyID",
                keyValue: 7,
                column: "BusinessCertificate",
                value: null);

            migrationBuilder.UpdateData(
                table: "Freelancer",
                keyColumn: "FreelancerID",
                keyValue: 4,
                column: "CV",
                value: null);

            migrationBuilder.UpdateData(
                table: "Freelancer",
                keyColumn: "FreelancerID",
                keyValue: 9,
                column: "CV",
                value: null);

            migrationBuilder.UpdateData(
                table: "Freelancer",
                keyColumn: "FreelancerID",
                keyValue: 10,
                column: "CV",
                value: null);

            migrationBuilder.UpdateData(
                table: "Freelancer",
                keyColumn: "FreelancerID",
                keyValue: 11,
                column: "CV",
                value: null);

            migrationBuilder.UpdateData(
                table: "Freelancer",
                keyColumn: "FreelancerID",
                keyValue: 12,
                column: "CV",
                value: null);

            migrationBuilder.UpdateData(
                table: "Freelancer",
                keyColumn: "FreelancerID",
                keyValue: 13,
                column: "CV",
                value: null);

            migrationBuilder.UpdateData(
                table: "Freelancer",
                keyColumn: "FreelancerID",
                keyValue: 14,
                column: "CV",
                value: null);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CV",
                table: "Freelancer");

            migrationBuilder.DropColumn(
                name: "BusinessCertificate",
                table: "Company");
        }
    }
}
