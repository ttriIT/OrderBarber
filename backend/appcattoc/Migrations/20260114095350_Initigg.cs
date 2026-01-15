using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace appcattoc.Migrations
{
    /// <inheritdoc />
    public partial class Initigg : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "StaffTimeSlots",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    StaffId = table.Column<int>(type: "int", nullable: false),
                    Date = table.Column<DateTime>(type: "datetime2", nullable: false),
                    StartTime = table.Column<TimeSpan>(type: "time", nullable: false),
                    EndTime = table.Column<TimeSpan>(type: "time", nullable: false),
                    IsAvailable = table.Column<bool>(type: "bit", nullable: false),
                    IsDayOff = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StaffTimeSlots", x => x.Id);
                    table.ForeignKey(
                        name: "FK_StaffTimeSlots_StaffProfiles_StaffId",
                        column: x => x.StaffId,
                        principalTable: "StaffProfiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_StaffTimeSlots_StaffId",
                table: "StaffTimeSlots",
                column: "StaffId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "StaffTimeSlots");
        }
    }
}
