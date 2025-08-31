using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace KoRadio.Services.Migrations
{
    /// <inheritdoc />
    public partial class jobsCascade : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__JobsServi__JobId__7849DB76",
                table: "JobsService");

            migrationBuilder.AddForeignKey(
                name: "FK__JobsServi__JobId__7849DB76",
                table: "JobsService",
                column: "JobId",
                principalTable: "Jobs",
                principalColumn: "JobId",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__JobsServi__JobId__7849DB76",
                table: "JobsService");

            migrationBuilder.AddForeignKey(
                name: "FK__JobsServi__JobId__7849DB76",
                table: "JobsService",
                column: "JobId",
                principalTable: "Jobs",
                principalColumn: "JobId");
        }
    }
}
