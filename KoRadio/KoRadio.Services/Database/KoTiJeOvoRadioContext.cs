using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace KoRadio.Services.Database;

public partial class KoTiJeOvoRadioContext : DbContext
{
    public KoTiJeOvoRadioContext()
    {
    }

    public KoTiJeOvoRadioContext(DbContextOptions<KoTiJeOvoRadioContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Company> Companies { get; set; }

    public virtual DbSet<CompanyEmployee> CompanyEmployees { get; set; }

    public virtual DbSet<CompanyService> CompanyServices { get; set; }

    public virtual DbSet<Freelancer> Freelancers { get; set; }

    public virtual DbSet<FreelancerService> FreelancerServices { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<Service> Services { get; set; }

    public virtual DbSet<User> Users { get; set; }

    public virtual DbSet<UserRole> UserRoles { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Data Source=localhost;Initial Catalog=KoTiJeOvoRadio;TrustServerCertificate=true;Trusted_Connection=true");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Company>(entity =>
        {
            entity.HasKey(e => e.CompanyId).HasName("PK__Company__2D971C4CB07C8C16");

            entity.ToTable("Company");

            entity.Property(e => e.CompanyId).HasColumnName("CompanyID");
            entity.Property(e => e.Availability).HasMaxLength(255);
            entity.Property(e => e.Bio).HasMaxLength(255);
            entity.Property(e => e.Location).HasMaxLength(255);
            entity.Property(e => e.PhoneNumber).HasMaxLength(20);
            entity.Property(e => e.Rating).HasColumnType("decimal(3, 2)");
        });

        modelBuilder.Entity<CompanyEmployee>(entity =>
        {
            entity.HasKey(e => e.CompanyEmployeeId).HasName("PK__CompanyE__3916BD7B030D0A87");

            entity.ToTable("CompanyEmployee");

            entity.Property(e => e.CompanyEmployeeId).HasColumnName("CompanyEmployeeID");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.User).WithMany(p => p.CompanyEmployees)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__CompanyEm__UserI__17036CC0");
        });

        modelBuilder.Entity<CompanyService>(entity =>
        {
            entity.HasKey(e => new { e.CompanyId, e.ServiceId }).HasName("PK__CompanyS__91C6A7424FCFED49");

            entity.ToTable("CompanyService");

            entity.Property(e => e.CompanyId).HasColumnName("CompanyID");
            entity.Property(e => e.ServiceId).HasColumnName("ServiceID");
            entity.Property(e => e.CreatedAt).HasColumnType("datetime");
            entity.Property(e => e.IsDeleted).HasColumnName("isDeleted");

            entity.HasOne(d => d.Company).WithMany(p => p.CompanyServices)
                .HasForeignKey(d => d.CompanyId)
                .HasConstraintName("FK__CompanySe__Compa__1F98B2C1");

            entity.HasOne(d => d.Service).WithMany(p => p.CompanyServices)
                .HasForeignKey(d => d.ServiceId)
                .HasConstraintName("FK__CompanySe__Servi__208CD6FA");
        });

        modelBuilder.Entity<Freelancer>(entity =>
        {
            entity.HasKey(e => e.FreelancerId).HasName("PK__Freelanc__3D00E30C2F2F998D");

            entity.ToTable("Freelancer");

            entity.Property(e => e.FreelancerId).HasColumnName("FreelancerID");
            entity.Property(e => e.Availability).HasMaxLength(255);
            entity.Property(e => e.Bio).HasMaxLength(255);
            entity.Property(e => e.HourlyRate).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.Location).HasMaxLength(255);
            entity.Property(e => e.Rating).HasColumnType("decimal(3, 2)");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.User).WithMany(p => p.Freelancers)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__Freelance__UserI__123EB7A3");
        });

        modelBuilder.Entity<FreelancerService>(entity =>
        {
            entity.HasKey(e => new { e.FreelancerId, e.ServiceId }).HasName("PK__Freelanc__81515802354FEB8B");

            entity.ToTable("FreelancerService");

            entity.Property(e => e.FreelancerId).HasColumnName("FreelancerID");
            entity.Property(e => e.ServiceId).HasColumnName("ServiceID");
            entity.Property(e => e.CreatedAt).HasColumnType("datetime");
            entity.Property(e => e.IsDeleted).HasColumnName("isDeleted");

            entity.HasOne(d => d.Freelancer).WithMany(p => p.FreelancerServices)
                .HasForeignKey(d => d.FreelancerId)
                .HasConstraintName("FK__Freelance__Freel__1BC821DD");

            entity.HasOne(d => d.Service).WithMany(p => p.FreelancerServices)
                .HasForeignKey(d => d.ServiceId)
                .HasConstraintName("FK__Freelance__Servi__1CBC4616");
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasKey(e => e.RoleId).HasName("PK__Roles__8AFACE3A92DD3D4B");

            entity.HasIndex(e => e.RoleName, "UQ__Roles__8A2B61606615CF66").IsUnique();

            entity.Property(e => e.RoleId).HasColumnName("RoleID");
            entity.Property(e => e.RoleDescription).HasMaxLength(100);
            entity.Property(e => e.RoleName).HasMaxLength(50);
        });

        modelBuilder.Entity<Service>(entity =>
        {
            entity.HasKey(e => e.ServiceId).HasName("PK__Service__C51BB0EAAC6763C6");

            entity.ToTable("Service");

            entity.Property(e => e.ServiceId).HasColumnName("ServiceID");
            entity.Property(e => e.ServiceName).HasMaxLength(255);
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.UserId).HasName("PK__Users__1788CCACDE55EC71");

            entity.Property(e => e.UserId).HasColumnName("UserID");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Email).HasMaxLength(255);
            entity.Property(e => e.FirstName).HasMaxLength(100);
            entity.Property(e => e.LastName).HasMaxLength(100);
            entity.Property(e => e.PasswordHash).HasMaxLength(255);
            entity.Property(e => e.PasswordSalt).HasMaxLength(255);
        });

        modelBuilder.Entity<UserRole>(entity =>
        {
            entity.HasKey(e => e.UserRolesId).HasName("PK__UserRole__43D8C0CDAC829069");

            entity.HasIndex(e => e.RoleId, "IX_UserRoles_RoleID");

            entity.HasIndex(e => e.UserId, "IX_UserRoles_UserID");

            entity.Property(e => e.UserRolesId).HasColumnName("UserRolesID");
            entity.Property(e => e.ChangedAt).HasColumnType("datetime");
            entity.Property(e => e.RoleId).HasColumnName("RoleID");
            entity.Property(e => e.UserId).HasColumnName("UserID");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
