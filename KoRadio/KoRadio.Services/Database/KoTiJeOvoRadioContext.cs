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

    public virtual DbSet<Job> Jobs { get; set; }

    public virtual DbSet<JobsService> JobsServices { get; set; }

    public virtual DbSet<Location> Locations { get; set; }

    public virtual DbSet<Message> Messages { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<Service> Services { get; set; }

    public virtual DbSet<User> Users { get; set; }

    public virtual DbSet<UserRole> UserRoles { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Data Source=localhost;Initial Catalog=KoTiJeOvoRadio;TrustServerCertificate=true;Trusted_Connection=true;");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Company>(entity =>
        {
            entity.HasKey(e => e.CompanyId).HasName("PK__Company__2D971C4CB07C8C16");

            entity.ToTable("Company");

            entity.Property(e => e.CompanyId).HasColumnName("CompanyID");
            entity.Property(e => e.Bio).HasMaxLength(255);
            entity.Property(e => e.LocationId).HasColumnName("LocationID");
            entity.Property(e => e.PhoneNumber).HasMaxLength(20);
            entity.Property(e => e.Rating).HasColumnType("decimal(3, 2)");

            entity.HasOne(d => d.Location).WithMany(p => p.Companies)
                .HasForeignKey(d => d.LocationId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Company__Locatio__0F2D40CE");
        });

        modelBuilder.Entity<CompanyEmployee>(entity =>
        {
            entity.HasKey(e => e.CompanyEmployeeId).HasName("PK__CompanyE__3916BD7B030D0A87");

            entity.ToTable("CompanyEmployee");

            entity.Property(e => e.CompanyEmployeeId).HasColumnName("CompanyEmployeeID");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.User).WithMany(p => p.CompanyEmployees)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__CompanyEm__UserI__17036CC0");
        });

        modelBuilder.Entity<CompanyService>(entity =>
        {
            entity.HasKey(e => new { e.CompanyId, e.ServiceId }).HasName("PK__CompanyS__91C6A7424FCFED49");

            entity.ToTable("CompanyService");

            entity.Property(e => e.CompanyId).HasColumnName("CompanyID");
            entity.Property(e => e.ServiceId).HasColumnName("ServiceID");
            entity.Property(e => e.CreatedAt).HasColumnType("datetime");

            entity.HasOne(d => d.Company).WithMany(p => p.CompanyServices)
                .HasForeignKey(d => d.CompanyId)
                .HasConstraintName("FK__CompanySe__Compa__1F98B2C1");

            entity.HasOne(d => d.Service).WithMany(p => p.CompanyServices)
                .HasForeignKey(d => d.ServiceId)
                .HasConstraintName("FK__CompanySe__Servi__208CD6FA");
        });

        modelBuilder.Entity<Freelancer>(entity =>
        {
            entity.HasKey(e => e.FreelancerId).HasName("PK__Freelanc__3D00E30C80E0E635");

            entity.ToTable("Freelancer");

            entity.Property(e => e.FreelancerId)
                .ValueGeneratedNever()
                .HasColumnName("FreelancerID");
            entity.Property(e => e.Bio).HasMaxLength(255);
            entity.Property(e => e.Rating).HasColumnType("decimal(3, 2)");
            entity.Property(e => e.RatingSum).HasDefaultValue(0.0);
            entity.Property(e => e.TotalRatings).HasDefaultValue(0);

            entity.HasOne(d => d.FreelancerNavigation).WithOne(p => p.Freelancer)
                .HasForeignKey<Freelancer>(d => d.FreelancerId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Freelance__Freel__1B9317B3");
        });

        modelBuilder.Entity<FreelancerService>(entity =>
        {
            entity.HasKey(e => new { e.FreelancerId, e.ServiceId }).HasName("PK__Freelanc__815158029BB39A82");

            entity.ToTable("FreelancerService");

            entity.Property(e => e.FreelancerId).HasColumnName("FreelancerID");
            entity.Property(e => e.ServiceId).HasColumnName("ServiceID");
            entity.Property(e => e.CreatedAt)
                .HasColumnType("datetime")
                .HasColumnName("CreatedAT");

            entity.HasOne(d => d.Freelancer).WithMany(p => p.FreelancerServices)
                .HasForeignKey(d => d.FreelancerId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Freelance__Freel__1F63A897");

            entity.HasOne(d => d.Service).WithMany(p => p.FreelancerServices)
                .HasForeignKey(d => d.ServiceId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Freelance__Servi__2057CCD0");
        });

        modelBuilder.Entity<Job>(entity =>
        {
            entity.HasKey(e => e.JobId).HasName("PK__Jobs__056690C234DE197E");

            entity.Property(e => e.FreelancerId).HasColumnName("FreelancerID");
            entity.Property(e => e.JobDate).HasColumnType("datetime");
            entity.Property(e => e.JobDescription).HasMaxLength(255);
            entity.Property(e => e.JobStatus)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasDefaultValue("unnaproved")
                .HasColumnName("Job_Status");
            entity.Property(e => e.PayEstimate).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.PayInvoice).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.Freelancer).WithMany(p => p.Jobs)
                .HasForeignKey(d => d.FreelancerId)
                .HasConstraintName("FK__Jobs__Freelancer__214BF109");

            entity.HasOne(d => d.User).WithMany(p => p.Jobs)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Jobs__UserID__4F47C5E3");
        });

        modelBuilder.Entity<JobsService>(entity =>
        {
            entity.HasKey(e => new { e.JobId, e.ServiceId }).HasName("PK__JobsServ__B9372BC2B802A0FE");

            entity.ToTable("JobsService");

            entity.Property(e => e.CreatedAt).HasColumnType("datetime");

            entity.HasOne(d => d.Job).WithMany(p => p.JobsServices)
                .HasForeignKey(d => d.JobId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__JobsServi__JobId__7849DB76");

            entity.HasOne(d => d.Service).WithMany(p => p.JobsServices)
                .HasForeignKey(d => d.ServiceId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__JobsServi__Servi__793DFFAF");
        });

        modelBuilder.Entity<Location>(entity =>
        {
            entity.HasKey(e => e.LocationId).HasName("PK__Location__E7FEA4779B95C597");

            entity.Property(e => e.LocationId).HasColumnName("LocationID");
            entity.Property(e => e.LocationName).HasMaxLength(30);
        });

        modelBuilder.Entity<Message>(entity =>
        {
            entity.HasKey(e => e.MessageId).HasName("PK__Messages__C87C0C9CD5627697");

            entity.Property(e => e.Message1)
                .HasMaxLength(255)
                .HasColumnName("Message");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.User).WithMany(p => p.Messages)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__Messages__UserID__2CBDA3B5");
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

            entity.HasIndex(e => e.Email, "UQ_Users_Email").IsUnique();

            entity.Property(e => e.UserId).HasColumnName("UserID");
            entity.Property(e => e.Address).HasMaxLength(50);
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Email).HasMaxLength(255);
            entity.Property(e => e.FirstName).HasMaxLength(100);
            entity.Property(e => e.LastName).HasMaxLength(100);
            entity.Property(e => e.LocationId).HasColumnName("LocationID");
            entity.Property(e => e.PasswordHash).HasMaxLength(255);
            entity.Property(e => e.PasswordSalt).HasMaxLength(255);
            entity.Property(e => e.PhoneNumber).HasMaxLength(255);

            entity.HasOne(d => d.Location).WithMany(p => p.Users)
                .HasForeignKey(d => d.LocationId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Users__LocationI__0E391C95");
        });

        modelBuilder.Entity<UserRole>(entity =>
        {
            entity.HasKey(e => e.UserRoleId).HasName("PK__UserRole__3D978A551693E34E");

            entity.Property(e => e.UserRoleId).HasColumnName("UserRoleID");
            entity.Property(e => e.ChangedAt).HasColumnType("datetime");
            entity.Property(e => e.CreatedAt).HasColumnType("datetime");
            entity.Property(e => e.RoleId).HasColumnName("RoleID");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.Role).WithMany(p => p.UserRoles)
                .HasForeignKey(d => d.RoleId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__UserRoles__RoleI__16CE6296");

            entity.HasOne(d => d.User).WithMany(p => p.UserRoles)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__UserRoles__UserI__15DA3E5D");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
