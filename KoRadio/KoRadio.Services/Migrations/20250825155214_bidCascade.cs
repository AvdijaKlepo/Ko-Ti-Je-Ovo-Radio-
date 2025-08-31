using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace KoRadio.Services.Migrations
{
    /// <inheritdoc />
    public partial class bidCascade : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__TenderBid__JobId__6A85CC04",
                table: "TenderBid");

            migrationBuilder.AddForeignKey(
                name: "FK__TenderBid__JobId__6A85CC04",
                table: "TenderBid",
                column: "JobId",
                principalTable: "Jobs",
                principalColumn: "JobId",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__TenderBid__JobId__6A85CC04",
                table: "TenderBid");

            migrationBuilder.AddForeignKey(
                name: "FK__TenderBid__JobId__6A85CC04",
                table: "TenderBid",
                column: "JobId",
                principalTable: "Jobs",
                principalColumn: "JobId");
        }
    }
}
