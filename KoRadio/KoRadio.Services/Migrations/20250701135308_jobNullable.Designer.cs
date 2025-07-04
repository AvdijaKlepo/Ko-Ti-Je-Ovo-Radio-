﻿// <auto-generated />
using System;
using KoRadio.Services.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

#nullable disable

namespace KoRadio.Services.Migrations
{
    [DbContext(typeof(KoTiJeOvoRadioContext))]
    [Migration("20250701135308_jobNullable")]
    partial class jobNullable
    {
        /// <inheritdoc />
        protected override void BuildTargetModel(ModelBuilder modelBuilder)
        {
#pragma warning disable 612, 618
            modelBuilder
                .HasAnnotation("ProductVersion", "9.0.0")
                .HasAnnotation("Relational:MaxIdentifierLength", 128);

            SqlServerModelBuilderExtensions.UseIdentityColumns(modelBuilder);

            modelBuilder.Entity("KoRadio.Services.Database.Company", b =>
                {
                    b.Property<int>("CompanyId")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int")
                        .HasColumnName("CompanyID");

                    SqlServerPropertyBuilderExtensions.UseIdentityColumn(b.Property<int>("CompanyId"));

                    b.Property<string>("Bio")
                        .IsRequired()
                        .HasMaxLength(255)
                        .HasColumnType("nvarchar(255)");

                    b.Property<string>("CompanyName")
                        .IsRequired()
                        .HasMaxLength(50)
                        .HasColumnType("nvarchar(50)");

                    b.Property<string>("Email")
                        .IsRequired()
                        .HasMaxLength(255)
                        .HasColumnType("nvarchar(255)");

                    b.Property<TimeOnly>("EndTime")
                        .HasColumnType("time");

                    b.Property<int>("ExperianceYears")
                        .HasColumnType("int");

                    b.Property<byte[]>("Image")
                        .HasColumnType("varbinary(max)");

                    b.Property<bool>("IsApplicant")
                        .HasColumnType("bit");

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("bit");

                    b.Property<int>("LocationId")
                        .HasColumnType("int")
                        .HasColumnName("LocationID");

                    b.Property<string>("PhoneNumber")
                        .IsRequired()
                        .HasMaxLength(20)
                        .HasColumnType("nvarchar(20)");

                    b.Property<decimal?>("Rating")
                        .HasColumnType("decimal(3, 2)");

                    b.Property<TimeOnly>("StartTime")
                        .HasColumnType("time");

                    b.Property<int>("WorkingDays")
                        .HasColumnType("int");

                    b.HasKey("CompanyId")
                        .HasName("PK__Company__2D971C4CB07C8C16");

                    b.HasIndex("LocationId");

                    b.HasIndex(new[] { "Email" }, "UQ_Company_Email")
                        .IsUnique();

                    b.ToTable("Company", (string)null);
                });

            modelBuilder.Entity("KoRadio.Services.Database.CompanyEmployee", b =>
                {
                    b.Property<int>("CompanyEmployeeId")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int")
                        .HasColumnName("CompanyEmployeeID");

                    SqlServerPropertyBuilderExtensions.UseIdentityColumn(b.Property<int>("CompanyEmployeeId"));

                    b.Property<int>("CompanyId")
                        .HasColumnType("int")
                        .HasColumnName("CompanyID");

                    b.Property<int?>("CompanyRoleId")
                        .HasColumnType("int");

                    b.Property<DateTime>("DateJoined")
                        .HasColumnType("datetime");

                    b.Property<bool>("IsApplicant")
                        .HasColumnType("bit");

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("bit");

                    b.Property<int>("UserId")
                        .HasColumnType("int")
                        .HasColumnName("UserID");

                    b.HasKey("CompanyEmployeeId")
                        .HasName("PK__CompanyE__3916BD7B00AC7565");

                    b.HasIndex("CompanyId");

                    b.HasIndex("CompanyRoleId");

                    b.HasIndex("UserId");

                    b.ToTable("CompanyEmployee", (string)null);
                });

            modelBuilder.Entity("KoRadio.Services.Database.CompanyJobAssignment", b =>
                {
                    b.Property<int>("CompanyJobId")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int")
                        .HasColumnName("CompanyJobID");

                    SqlServerPropertyBuilderExtensions.UseIdentityColumn(b.Property<int>("CompanyJobId"));

                    b.Property<DateTime>("AssignedAt")
                        .HasColumnType("datetime");

                    b.Property<int?>("CompanyEmployeeId")
                        .HasColumnType("int")
                        .HasColumnName("CompanyEmployeeID");

                    b.Property<int?>("JobId")
                        .HasColumnType("int");

                    b.HasKey("CompanyJobId")
                        .HasName("PK__CompanyJ__B783C37E390DA91B");

                    b.HasIndex("CompanyEmployeeId");

                    b.HasIndex("JobId");

                    b.ToTable("CompanyJobAssignment", (string)null);
                });

            modelBuilder.Entity("KoRadio.Services.Database.CompanyRole", b =>
                {
                    b.Property<int>("CompanyRoleId")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int");

                    SqlServerPropertyBuilderExtensions.UseIdentityColumn(b.Property<int>("CompanyRoleId"));

                    b.Property<int?>("CompanyId")
                        .HasColumnType("int")
                        .HasColumnName("CompanyID");

                    b.Property<string>("RoleName")
                        .HasMaxLength(50)
                        .HasColumnType("nvarchar(50)");

                    b.HasKey("CompanyRoleId")
                        .HasName("PK__CompanyR__9CF06B50EF6710FD");

                    b.HasIndex("CompanyId");

                    b.ToTable("CompanyRole", (string)null);
                });

            modelBuilder.Entity("KoRadio.Services.Database.CompanyService", b =>
                {
                    b.Property<int>("CompanyId")
                        .HasColumnType("int")
                        .HasColumnName("CompanyID");

                    b.Property<int>("ServiceId")
                        .HasColumnType("int")
                        .HasColumnName("ServiceID");

                    b.Property<DateTime>("CreatedAt")
                        .HasColumnType("datetime");

                    b.HasKey("CompanyId", "ServiceId")
                        .HasName("PK__CompanyS__91C6A7424FCFED49");

                    b.HasIndex("ServiceId");

                    b.ToTable("CompanyService", (string)null);
                });

            modelBuilder.Entity("KoRadio.Services.Database.Freelancer", b =>
                {
                    b.Property<int>("FreelancerId")
                        .HasColumnType("int")
                        .HasColumnName("FreelancerID");

                    b.Property<string>("Bio")
                        .IsRequired()
                        .HasMaxLength(255)
                        .HasColumnType("nvarchar(255)");

                    b.Property<TimeOnly>("EndTime")
                        .HasColumnType("time");

                    b.Property<int>("ExperianceYears")
                        .HasColumnType("int");

                    b.Property<bool>("IsApplicant")
                        .HasColumnType("bit");

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("bit");

                    b.Property<decimal>("Rating")
                        .HasColumnType("decimal(3, 2)");

                    b.Property<double?>("RatingSum")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("float")
                        .HasDefaultValue(0.0);

                    b.Property<TimeOnly>("StartTime")
                        .HasColumnType("time");

                    b.Property<int?>("TotalRatings")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int")
                        .HasDefaultValue(0);

                    b.Property<int>("WorkingDays")
                        .HasColumnType("int");

                    b.HasKey("FreelancerId")
                        .HasName("PK__Freelanc__3D00E30C80E0E635");

                    b.ToTable("Freelancer", (string)null);
                });

            modelBuilder.Entity("KoRadio.Services.Database.FreelancerService", b =>
                {
                    b.Property<int>("FreelancerId")
                        .HasColumnType("int")
                        .HasColumnName("FreelancerID");

                    b.Property<int>("ServiceId")
                        .HasColumnType("int")
                        .HasColumnName("ServiceID");

                    b.Property<DateTime>("CreatedAt")
                        .HasColumnType("datetime")
                        .HasColumnName("CreatedAT");

                    b.HasKey("FreelancerId", "ServiceId")
                        .HasName("PK__Freelanc__815158029BB39A82");

                    b.HasIndex("ServiceId");

                    b.ToTable("FreelancerService", (string)null);
                });

            modelBuilder.Entity("KoRadio.Services.Database.Job", b =>
                {
                    b.Property<int>("JobId")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int");

                    SqlServerPropertyBuilderExtensions.UseIdentityColumn(b.Property<int>("JobId"));

                    b.Property<int?>("CompanyId")
                        .HasColumnType("int")
                        .HasColumnName("CompanyID");

                    b.Property<TimeOnly?>("EndEstimate")
                        .HasColumnType("time");

                    b.Property<int?>("FreelancerId")
                        .HasColumnType("int")
                        .HasColumnName("FreelancerID");

                    b.Property<byte[]>("Image")
                        .HasColumnType("varbinary(max)");

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("bit");

                    b.Property<DateTime>("JobDate")
                        .HasColumnType("datetime");

                    b.Property<string>("JobDescription")
                        .IsRequired()
                        .HasMaxLength(255)
                        .HasColumnType("nvarchar(255)");

                    b.Property<string>("JobStatus")
                        .IsRequired()
                        .ValueGeneratedOnAdd()
                        .HasMaxLength(20)
                        .IsUnicode(false)
                        .HasColumnType("varchar(20)")
                        .HasDefaultValue("unnaproved")
                        .HasColumnName("Job_Status");

                    b.Property<decimal?>("PayEstimate")
                        .HasColumnType("decimal(10, 2)");

                    b.Property<decimal?>("PayInvoice")
                        .HasColumnType("decimal(10, 2)");

                    b.Property<TimeOnly?>("StartEstimate")
                        .HasColumnType("time");

                    b.Property<int>("UserId")
                        .HasColumnType("int")
                        .HasColumnName("UserID");

                    b.HasKey("JobId")
                        .HasName("PK__Jobs__056690C234DE197E");

                    b.HasIndex("CompanyId");

                    b.HasIndex("FreelancerId");

                    b.HasIndex("UserId");

                    b.ToTable("Jobs");
                });

            modelBuilder.Entity("KoRadio.Services.Database.JobsService", b =>
                {
                    b.Property<int>("JobId")
                        .HasColumnType("int");

                    b.Property<int>("ServiceId")
                        .HasColumnType("int");

                    b.Property<DateTime?>("CreatedAt")
                        .HasColumnType("datetime");

                    b.HasKey("JobId", "ServiceId")
                        .HasName("PK__JobsServ__B9372BC2B802A0FE");

                    b.HasIndex("ServiceId");

                    b.ToTable("JobsService", (string)null);
                });

            modelBuilder.Entity("KoRadio.Services.Database.Location", b =>
                {
                    b.Property<int>("LocationId")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int")
                        .HasColumnName("LocationID");

                    SqlServerPropertyBuilderExtensions.UseIdentityColumn(b.Property<int>("LocationId"));

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("bit");

                    b.Property<string>("LocationName")
                        .IsRequired()
                        .HasMaxLength(30)
                        .HasColumnType("nvarchar(30)");

                    b.HasKey("LocationId")
                        .HasName("PK__Location__E7FEA4779B95C597");

                    b.ToTable("Locations");
                });

            modelBuilder.Entity("KoRadio.Services.Database.Message", b =>
                {
                    b.Property<int>("MessageId")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int");

                    SqlServerPropertyBuilderExtensions.UseIdentityColumn(b.Property<int>("MessageId"));

                    b.Property<string>("Message1")
                        .HasMaxLength(255)
                        .HasColumnType("nvarchar(255)")
                        .HasColumnName("Message");

                    b.Property<int?>("UserId")
                        .HasColumnType("int")
                        .HasColumnName("UserID");

                    b.HasKey("MessageId")
                        .HasName("PK__Messages__C87C0C9CD5627697");

                    b.HasIndex("UserId");

                    b.ToTable("Messages");
                });

            modelBuilder.Entity("KoRadio.Services.Database.Role", b =>
                {
                    b.Property<int>("RoleId")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int")
                        .HasColumnName("RoleID");

                    SqlServerPropertyBuilderExtensions.UseIdentityColumn(b.Property<int>("RoleId"));

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("bit");

                    b.Property<string>("RoleDescription")
                        .IsRequired()
                        .HasMaxLength(100)
                        .HasColumnType("nvarchar(100)");

                    b.Property<string>("RoleName")
                        .IsRequired()
                        .HasMaxLength(50)
                        .HasColumnType("nvarchar(50)");

                    b.HasKey("RoleId")
                        .HasName("PK__Roles__8AFACE3A92DD3D4B");

                    b.HasIndex(new[] { "RoleName" }, "UQ__Roles__8A2B61606615CF66")
                        .IsUnique();

                    b.ToTable("Roles");
                });

            modelBuilder.Entity("KoRadio.Services.Database.Service", b =>
                {
                    b.Property<int>("ServiceId")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int")
                        .HasColumnName("ServiceID");

                    SqlServerPropertyBuilderExtensions.UseIdentityColumn(b.Property<int>("ServiceId"));

                    b.Property<byte[]>("Image")
                        .IsRequired()
                        .HasColumnType("varbinary(max)");

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("bit");

                    b.Property<string>("ServiceName")
                        .IsRequired()
                        .HasMaxLength(255)
                        .HasColumnType("nvarchar(255)");

                    b.HasKey("ServiceId")
                        .HasName("PK__Service__C51BB0EAAC6763C6");

                    b.ToTable("Service", (string)null);
                });

            modelBuilder.Entity("KoRadio.Services.Database.User", b =>
                {
                    b.Property<int>("UserId")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int")
                        .HasColumnName("UserID");

                    SqlServerPropertyBuilderExtensions.UseIdentityColumn(b.Property<int>("UserId"));

                    b.Property<string>("Address")
                        .IsRequired()
                        .HasMaxLength(50)
                        .HasColumnType("nvarchar(50)");

                    b.Property<DateTime>("CreatedAt")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("datetime")
                        .HasDefaultValueSql("(getdate())");

                    b.Property<string>("Email")
                        .IsRequired()
                        .HasMaxLength(255)
                        .HasColumnType("nvarchar(255)");

                    b.Property<string>("FirstName")
                        .IsRequired()
                        .HasMaxLength(100)
                        .HasColumnType("nvarchar(100)");

                    b.Property<byte[]>("Image")
                        .HasColumnType("varbinary(max)");

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("bit");

                    b.Property<string>("LastName")
                        .IsRequired()
                        .HasMaxLength(100)
                        .HasColumnType("nvarchar(100)");

                    b.Property<int>("LocationId")
                        .HasColumnType("int")
                        .HasColumnName("LocationID");

                    b.Property<string>("PasswordHash")
                        .IsRequired()
                        .HasMaxLength(255)
                        .HasColumnType("nvarchar(255)");

                    b.Property<string>("PasswordSalt")
                        .IsRequired()
                        .HasMaxLength(255)
                        .HasColumnType("nvarchar(255)");

                    b.Property<string>("PhoneNumber")
                        .IsRequired()
                        .HasMaxLength(255)
                        .HasColumnType("nvarchar(255)");

                    b.HasKey("UserId")
                        .HasName("PK__Users__1788CCACDE55EC71");

                    b.HasIndex("LocationId");

                    b.HasIndex(new[] { "Email" }, "UQ_Users_Email")
                        .IsUnique();

                    b.ToTable("Users");
                });

            modelBuilder.Entity("KoRadio.Services.Database.UserRating", b =>
                {
                    b.Property<int>("UserRatingId")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int")
                        .HasColumnName("UserRatingID");

                    SqlServerPropertyBuilderExtensions.UseIdentityColumn(b.Property<int>("UserRatingId"));

                    b.Property<int?>("FreelancerId")
                        .HasColumnType("int")
                        .HasColumnName("FreelancerID");

                    b.Property<int?>("JobId")
                        .HasColumnType("int");

                    b.Property<decimal>("Rating")
                        .HasColumnType("decimal(3, 2)");

                    b.Property<int?>("UserId")
                        .HasColumnType("int")
                        .HasColumnName("UserID");

                    b.HasKey("UserRatingId")
                        .HasName("PK__UserRati__9E5FEAAA63E96E4C");

                    b.HasIndex("FreelancerId");

                    b.HasIndex("JobId");

                    b.HasIndex("UserId");

                    b.ToTable("UserRatings");
                });

            modelBuilder.Entity("KoRadio.Services.Database.UserRole", b =>
                {
                    b.Property<int>("UserRoleId")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int")
                        .HasColumnName("UserRoleID");

                    SqlServerPropertyBuilderExtensions.UseIdentityColumn(b.Property<int>("UserRoleId"));

                    b.Property<DateTime?>("ChangedAt")
                        .HasColumnType("datetime");

                    b.Property<DateTime>("CreatedAt")
                        .HasColumnType("datetime");

                    b.Property<int>("RoleId")
                        .HasColumnType("int")
                        .HasColumnName("RoleID");

                    b.Property<int>("UserId")
                        .HasColumnType("int")
                        .HasColumnName("UserID");

                    b.HasKey("UserRoleId")
                        .HasName("PK__UserRole__3D978A551693E34E");

                    b.HasIndex("RoleId");

                    b.HasIndex("UserId");

                    b.ToTable("UserRoles");
                });

            modelBuilder.Entity("KoRadio.Services.Database.Company", b =>
                {
                    b.HasOne("KoRadio.Services.Database.Location", "Location")
                        .WithMany("Companies")
                        .HasForeignKey("LocationId")
                        .IsRequired()
                        .HasConstraintName("FK__Company__Locatio__0F2D40CE");

                    b.Navigation("Location");
                });

            modelBuilder.Entity("KoRadio.Services.Database.CompanyEmployee", b =>
                {
                    b.HasOne("KoRadio.Services.Database.Company", "Company")
                        .WithMany("CompanyEmployees")
                        .HasForeignKey("CompanyId")
                        .IsRequired()
                        .HasConstraintName("FK__CompanyEm__Compa__69C6B1F5");

                    b.HasOne("KoRadio.Services.Database.CompanyRole", "CompanyRole")
                        .WithMany("CompanyEmployees")
                        .HasForeignKey("CompanyRoleId")
                        .HasConstraintName("FK__CompanyEm__Compa__7BE56230");

                    b.HasOne("KoRadio.Services.Database.User", "User")
                        .WithMany("CompanyEmployees")
                        .HasForeignKey("UserId")
                        .IsRequired()
                        .HasConstraintName("FK__CompanyEm__UserI__68D28DBC");

                    b.Navigation("Company");

                    b.Navigation("CompanyRole");

                    b.Navigation("User");
                });

            modelBuilder.Entity("KoRadio.Services.Database.CompanyJobAssignment", b =>
                {
                    b.HasOne("KoRadio.Services.Database.CompanyEmployee", "CompanyEmployee")
                        .WithMany("CompanyJobAssignments")
                        .HasForeignKey("CompanyEmployeeId")
                        .HasConstraintName("FK__CompanyJo__Compa__019E3B86");

                    b.HasOne("KoRadio.Services.Database.Job", "Job")
                        .WithMany("CompanyJobAssignments")
                        .HasForeignKey("JobId")
                        .HasConstraintName("FK__CompanyJo__JobId__02925FBF");

                    b.Navigation("CompanyEmployee");

                    b.Navigation("Job");
                });

            modelBuilder.Entity("KoRadio.Services.Database.CompanyRole", b =>
                {
                    b.HasOne("KoRadio.Services.Database.Company", "Company")
                        .WithMany("CompanyRoles")
                        .HasForeignKey("CompanyId")
                        .HasConstraintName("FK__CompanyRo__Compa__7AF13DF7");

                    b.Navigation("Company");
                });

            modelBuilder.Entity("KoRadio.Services.Database.CompanyService", b =>
                {
                    b.HasOne("KoRadio.Services.Database.Company", "Company")
                        .WithMany("CompanyServices")
                        .HasForeignKey("CompanyId")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired()
                        .HasConstraintName("FK__CompanySe__Compa__1F98B2C1");

                    b.HasOne("KoRadio.Services.Database.Service", "Service")
                        .WithMany("CompanyServices")
                        .HasForeignKey("ServiceId")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired()
                        .HasConstraintName("FK__CompanySe__Servi__208CD6FA");

                    b.Navigation("Company");

                    b.Navigation("Service");
                });

            modelBuilder.Entity("KoRadio.Services.Database.Freelancer", b =>
                {
                    b.HasOne("KoRadio.Services.Database.User", "FreelancerNavigation")
                        .WithOne("Freelancer")
                        .HasForeignKey("KoRadio.Services.Database.Freelancer", "FreelancerId")
                        .IsRequired()
                        .HasConstraintName("FK__Freelance__Freel__1B9317B3");

                    b.Navigation("FreelancerNavigation");
                });

            modelBuilder.Entity("KoRadio.Services.Database.FreelancerService", b =>
                {
                    b.HasOne("KoRadio.Services.Database.Freelancer", "Freelancer")
                        .WithMany("FreelancerServices")
                        .HasForeignKey("FreelancerId")
                        .IsRequired()
                        .HasConstraintName("FK__Freelance__Freel__1F63A897");

                    b.HasOne("KoRadio.Services.Database.Service", "Service")
                        .WithMany("FreelancerServices")
                        .HasForeignKey("ServiceId")
                        .IsRequired()
                        .HasConstraintName("FK__Freelance__Servi__2057CCD0");

                    b.Navigation("Freelancer");

                    b.Navigation("Service");
                });

            modelBuilder.Entity("KoRadio.Services.Database.Job", b =>
                {
                    b.HasOne("KoRadio.Services.Database.Company", "Company")
                        .WithMany("Jobs")
                        .HasForeignKey("CompanyId")
                        .HasConstraintName("FK__Jobs__CompanyID__7EC1CEDB");

                    b.HasOne("KoRadio.Services.Database.Freelancer", "Freelancer")
                        .WithMany("Jobs")
                        .HasForeignKey("FreelancerId")
                        .HasConstraintName("FK__Jobs__Freelancer__214BF109");

                    b.HasOne("KoRadio.Services.Database.User", "User")
                        .WithMany("Jobs")
                        .HasForeignKey("UserId")
                        .IsRequired()
                        .HasConstraintName("FK__Jobs__UserID__4F47C5E3");

                    b.Navigation("Company");

                    b.Navigation("Freelancer");

                    b.Navigation("User");
                });

            modelBuilder.Entity("KoRadio.Services.Database.JobsService", b =>
                {
                    b.HasOne("KoRadio.Services.Database.Job", "Job")
                        .WithMany("JobsServices")
                        .HasForeignKey("JobId")
                        .IsRequired()
                        .HasConstraintName("FK__JobsServi__JobId__7849DB76");

                    b.HasOne("KoRadio.Services.Database.Service", "Service")
                        .WithMany("JobsServices")
                        .HasForeignKey("ServiceId")
                        .IsRequired()
                        .HasConstraintName("FK__JobsServi__Servi__793DFFAF");

                    b.Navigation("Job");

                    b.Navigation("Service");
                });

            modelBuilder.Entity("KoRadio.Services.Database.Message", b =>
                {
                    b.HasOne("KoRadio.Services.Database.User", "User")
                        .WithMany("Messages")
                        .HasForeignKey("UserId")
                        .HasConstraintName("FK__Messages__UserID__2CBDA3B5");

                    b.Navigation("User");
                });

            modelBuilder.Entity("KoRadio.Services.Database.User", b =>
                {
                    b.HasOne("KoRadio.Services.Database.Location", "Location")
                        .WithMany("Users")
                        .HasForeignKey("LocationId")
                        .IsRequired()
                        .HasConstraintName("FK__Users__LocationI__0E391C95");

                    b.Navigation("Location");
                });

            modelBuilder.Entity("KoRadio.Services.Database.UserRating", b =>
                {
                    b.HasOne("KoRadio.Services.Database.Freelancer", "Freelancer")
                        .WithMany("UserRatings")
                        .HasForeignKey("FreelancerId")
                        .HasConstraintName("FK__UserRatin__Freel__42ACE4D4");

                    b.HasOne("KoRadio.Services.Database.Job", "Job")
                        .WithMany("UserRatings")
                        .HasForeignKey("JobId")
                        .HasConstraintName("FK__UserRatin__JobId__4589517F");

                    b.HasOne("KoRadio.Services.Database.User", "User")
                        .WithMany("UserRatings")
                        .HasForeignKey("UserId")
                        .HasConstraintName("FK__UserRatin__UserI__41B8C09B");

                    b.Navigation("Freelancer");

                    b.Navigation("Job");

                    b.Navigation("User");
                });

            modelBuilder.Entity("KoRadio.Services.Database.UserRole", b =>
                {
                    b.HasOne("KoRadio.Services.Database.Role", "Role")
                        .WithMany("UserRoles")
                        .HasForeignKey("RoleId")
                        .IsRequired()
                        .HasConstraintName("FK__UserRoles__RoleI__16CE6296");

                    b.HasOne("KoRadio.Services.Database.User", "User")
                        .WithMany("UserRoles")
                        .HasForeignKey("UserId")
                        .IsRequired()
                        .HasConstraintName("FK__UserRoles__UserI__15DA3E5D");

                    b.Navigation("Role");

                    b.Navigation("User");
                });

            modelBuilder.Entity("KoRadio.Services.Database.Company", b =>
                {
                    b.Navigation("CompanyEmployees");

                    b.Navigation("CompanyRoles");

                    b.Navigation("CompanyServices");

                    b.Navigation("Jobs");
                });

            modelBuilder.Entity("KoRadio.Services.Database.CompanyEmployee", b =>
                {
                    b.Navigation("CompanyJobAssignments");
                });

            modelBuilder.Entity("KoRadio.Services.Database.CompanyRole", b =>
                {
                    b.Navigation("CompanyEmployees");
                });

            modelBuilder.Entity("KoRadio.Services.Database.Freelancer", b =>
                {
                    b.Navigation("FreelancerServices");

                    b.Navigation("Jobs");

                    b.Navigation("UserRatings");
                });

            modelBuilder.Entity("KoRadio.Services.Database.Job", b =>
                {
                    b.Navigation("CompanyJobAssignments");

                    b.Navigation("JobsServices");

                    b.Navigation("UserRatings");
                });

            modelBuilder.Entity("KoRadio.Services.Database.Location", b =>
                {
                    b.Navigation("Companies");

                    b.Navigation("Users");
                });

            modelBuilder.Entity("KoRadio.Services.Database.Role", b =>
                {
                    b.Navigation("UserRoles");
                });

            modelBuilder.Entity("KoRadio.Services.Database.Service", b =>
                {
                    b.Navigation("CompanyServices");

                    b.Navigation("FreelancerServices");

                    b.Navigation("JobsServices");
                });

            modelBuilder.Entity("KoRadio.Services.Database.User", b =>
                {
                    b.Navigation("CompanyEmployees");

                    b.Navigation("Freelancer");

                    b.Navigation("Jobs");

                    b.Navigation("Messages");

                    b.Navigation("UserRatings");

                    b.Navigation("UserRoles");
                });
#pragma warning restore 612, 618
        }
    }
}
