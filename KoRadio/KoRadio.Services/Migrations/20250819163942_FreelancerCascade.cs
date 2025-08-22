using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace KoRadio.Services.Migrations
{
    /// <inheritdoc />
    public partial class FreelancerCascade : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__Freelance__Freel__1F63A897",
                table: "FreelancerService");

            migrationBuilder.AddForeignKey(
                name: "FK__Freelance__Freel__1F63A897",
                table: "FreelancerService",
                column: "FreelancerID",
                principalTable: "Freelancer",
                principalColumn: "FreelancerID",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__Freelance__Freel__1F63A897",
                table: "FreelancerService");

            migrationBuilder.AddForeignKey(
                name: "FK__Freelance__Freel__1F63A897",
                table: "FreelancerService",
                column: "FreelancerID",
                principalTable: "Freelancer",
                principalColumn: "FreelancerID");
        }
    }
}
