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

    public virtual DbSet<CompanyWorker> CompanyWorkers { get; set; }

    public virtual DbSet<Conflict> Conflicts { get; set; }

    public virtual DbSet<Estimate> Estimates { get; set; }

    public virtual DbSet<Freelancer> Freelancers { get; set; }

    public virtual DbSet<Invoice> Invoices { get; set; }

    public virtual DbSet<Job> Jobs { get; set; }

    public virtual DbSet<JobAvailability> JobAvailabilities { get; set; }

    public virtual DbSet<JobStatus> JobStatuses { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<Service> Services { get; set; }

    public virtual DbSet<User> Users { get; set; }

    public virtual DbSet<UserRole> UserRoles { get; set; }

    public virtual DbSet<Worker> Workers { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Data Source=localhost;Initial Catalog=KoTiJeOvoRadio;Trusted_Connection=true; TrustServerCertificate=True");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Company>(entity =>
        {
            entity.HasKey(e => e.CompanyId).HasName("PK__Companie__2D971C4C6BA2CBCD");

            entity.Property(e => e.CompanyId).HasColumnName("CompanyID");
            entity.Property(e => e.Bio).HasMaxLength(500);
            entity.Property(e => e.CompanyName).HasMaxLength(100);

            entity.HasMany(d => d.Users).WithMany(p => p.Companies)
                .UsingEntity<Dictionary<string, object>>(
                    "CompanyAdministrator",
                    r => r.HasOne<User>().WithMany()
                        .HasForeignKey("UserId")
                        .HasConstraintName("FK__CompanyAd__UserI__5CD6CB2B"),
                    l => l.HasOne<Company>().WithMany()
                        .HasForeignKey("CompanyId")
                        .HasConstraintName("FK__CompanyAd__Compa__5BE2A6F2"),
                    j =>
                    {
                        j.HasKey("CompanyId", "UserId").HasName("PK__CompanyA__FCEF90863465B45C");
                        j.ToTable("CompanyAdministrator");
                        j.IndexerProperty<int>("CompanyId").HasColumnName("CompanyID");
                        j.IndexerProperty<int>("UserId").HasColumnName("UserID");
                    });
        });

        modelBuilder.Entity<CompanyWorker>(entity =>
        {
            entity.HasKey(e => e.CompanyWorkersId).HasName("PK__CompanyW__F593AA8FEFAFED44");

            entity.Property(e => e.CompanyWorkersId).HasColumnName("CompanyWorkersID");
            entity.Property(e => e.CompanyId).HasColumnName("CompanyID");
            entity.Property(e => e.WorkerId).HasColumnName("WorkerID");

            entity.HasOne(d => d.Company).WithMany(p => p.CompanyWorkers)
                .HasForeignKey(d => d.CompanyId)
                .HasConstraintName("FK__CompanyWo__Compa__59063A47");

            entity.HasOne(d => d.Worker).WithMany(p => p.CompanyWorkers)
                .HasForeignKey(d => d.WorkerId)
                .HasConstraintName("FK__CompanyWo__Worke__5812160E");
        });

        modelBuilder.Entity<Conflict>(entity =>
        {
            entity.HasKey(e => e.ConflictId).HasName("PK__Conflict__FEE84A165B8815CC");

            entity.Property(e => e.ConflictId).HasColumnName("ConflictID");
            entity.Property(e => e.ConflictReason).HasMaxLength(500);
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.JobId).HasColumnName("JobID");

            entity.HasOne(d => d.Job).WithMany(p => p.Conflicts)
                .HasForeignKey(d => d.JobId)
                .HasConstraintName("FK__Conflicts__JobID__2FCF1A8A");
        });

        modelBuilder.Entity<Estimate>(entity =>
        {
            entity.HasKey(e => e.EstimateId).HasName("PK__Estimate__ABEBF4D51AFFC293");

            entity.Property(e => e.EstimateId).HasColumnName("EstimateID");
            entity.Property(e => e.CompanyId).HasColumnName("CompanyID");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime")
                .HasColumnName("CreatedAT");
            entity.Property(e => e.Description).HasMaxLength(1000);
            entity.Property(e => e.EstimatedCost).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.FreelancerId).HasColumnName("FreelancerID");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.Company).WithMany(p => p.Estimates)
                .HasForeignKey(d => d.CompanyId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__Estimates__Compa__6EF57B66");

            entity.HasOne(d => d.Freelancer).WithMany(p => p.Estimates)
                .HasForeignKey(d => d.FreelancerId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Estimates__Freel__6E01572D");

            entity.HasOne(d => d.User).WithMany(p => p.Estimates)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__Estimates__UserI__6D0D32F4");
        });

        modelBuilder.Entity<Freelancer>(entity =>
        {
            entity.HasKey(e => e.WorkerId).HasName("PK__Freelanc__077C880650C2883E");

            entity.Property(e => e.WorkerId)
                .ValueGeneratedNever()
                .HasColumnName("WorkerID");
            entity.Property(e => e.Bio).HasMaxLength(500);

            entity.HasOne(d => d.Worker).WithOne(p => p.Freelancer)
                .HasForeignKey<Freelancer>(d => d.WorkerId)
                .HasConstraintName("FK__Freelance__Worke__4AB81AF0");
        });

        modelBuilder.Entity<Invoice>(entity =>
        {
            entity.HasKey(e => e.InvoiceId).HasName("PK__Invoices__D796AAD5FDAAEED1");

            entity.Property(e => e.InvoiceId).HasColumnName("InvoiceID");
            entity.Property(e => e.Amount).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.CompanyId).HasColumnName("CompanyID");
            entity.Property(e => e.FreelancerId).HasColumnName("FreelancerID");
            entity.Property(e => e.IssuedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.StatusId).HasColumnName("StatusID");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.Company).WithMany(p => p.Invoices)
                .HasForeignKey(d => d.CompanyId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__Invoices__Compan__02084FDA");

            entity.HasOne(d => d.Freelancer).WithMany(p => p.Invoices)
                .HasForeignKey(d => d.FreelancerId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Invoices__Freela__01142BA1");

            entity.HasOne(d => d.Status).WithMany(p => p.Invoices)
                .HasForeignKey(d => d.StatusId)
                .HasConstraintName("FK__Invoices__Status__7F2BE32F");

            entity.HasOne(d => d.User).WithMany(p => p.Invoices)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__Invoices__UserID__00200768");
        });

        modelBuilder.Entity<Job>(entity =>
        {
            entity.HasKey(e => e.JobId).HasName("PK__Jobs__056690E258E4BCA7");

            entity.Property(e => e.JobId).HasColumnName("JobID");
            entity.Property(e => e.CompanyId).HasColumnName("CompanyID");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.EstimateId).HasColumnName("EstimateID");
            entity.Property(e => e.FreelancerId).HasColumnName("FreelancerID");
            entity.Property(e => e.InvoiceId).HasColumnName("InvoiceID");
            entity.Property(e => e.StatusId)
                .HasDefaultValue(1)
                .HasColumnName("StatusID");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.Company).WithMany(p => p.Jobs)
                .HasForeignKey(d => d.CompanyId)
                .HasConstraintName("FK__Jobs__CompanyID__2BFE89A6");

            entity.HasOne(d => d.Estimate).WithMany(p => p.Jobs)
                .HasForeignKey(d => d.EstimateId)
                .HasConstraintName("FK__Jobs__EstimateID__2739D489");

            entity.HasOne(d => d.Freelancer).WithMany(p => p.Jobs)
                .HasForeignKey(d => d.FreelancerId)
                .HasConstraintName("FK__Jobs__Freelancer__2B0A656D");

            entity.HasOne(d => d.Invoice).WithMany(p => p.Jobs)
                .HasForeignKey(d => d.InvoiceId)
                .HasConstraintName("FK__Jobs__InvoiceID__29221CFB");

            entity.HasOne(d => d.Status).WithMany(p => p.Jobs)
                .HasForeignKey(d => d.StatusId)
                .HasConstraintName("FK__Jobs__StatusID__282DF8C2");

            entity.HasOne(d => d.User).WithMany(p => p.Jobs)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Jobs__UserID__2A164134");
        });

        modelBuilder.Entity<JobAvailability>(entity =>
        {
            entity.HasKey(e => e.JobAvailabilityId).HasName("PK__JobAvail__0E1EFD63B843CAE1");

            entity.ToTable("JobAvailability");

            entity.Property(e => e.JobAvailabilityId).HasColumnName("JobAvailabilityID");
            entity.Property(e => e.CompanyId).HasColumnName("CompanyID");
            entity.Property(e => e.EndTime).HasColumnType("datetime");
            entity.Property(e => e.FreelancerId).HasColumnName("FreelancerID");
            entity.Property(e => e.StartTime).HasColumnType("datetime");

            entity.HasOne(d => d.Company).WithMany(p => p.JobAvailabilities)
                .HasForeignKey(d => d.CompanyId)
                .HasConstraintName("FK__JobAvaila__Compa__52593CB8");

            entity.HasOne(d => d.Freelancer).WithMany(p => p.JobAvailabilities)
                .HasForeignKey(d => d.FreelancerId)
                .HasConstraintName("FK__JobAvaila__Freel__5165187F");
        });

        modelBuilder.Entity<JobStatus>(entity =>
        {
            entity.HasKey(e => e.StatusId).HasName("PK__JobStatu__C8EE2043DA05F66B");

            entity.HasIndex(e => e.StatusName, "UQ__JobStatu__05E7698ADA5572F0").IsUnique();

            entity.Property(e => e.StatusId).HasColumnName("StatusID");
            entity.Property(e => e.StatusName).HasMaxLength(50);
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
            entity.HasKey(e => e.ServiceId).HasName("PK__Services__C51BB0EAD9D99D16");

            entity.Property(e => e.ServiceId).HasColumnName("ServiceID");
            entity.Property(e => e.CompanyId).HasColumnName("CompanyID");
            entity.Property(e => e.FreelancerId).HasColumnName("FreelancerID");
            entity.Property(e => e.ServiceName).HasMaxLength(50);

            entity.HasOne(d => d.Company).WithMany(p => p.Services)
                .HasForeignKey(d => d.CompanyId)
                .HasConstraintName("FK__Services__Compan__4E88ABD4");

            entity.HasOne(d => d.Freelancer).WithMany(p => p.Services)
                .HasForeignKey(d => d.FreelancerId)
                .HasConstraintName("FK__Services__Freela__4D94879B");
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

            entity.Property(e => e.UserRolesId).HasColumnName("UserRolesID");
            entity.Property(e => e.ChangedAt).HasColumnType("datetime");
            entity.Property(e => e.RoleId).HasColumnName("RoleID");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.Role).WithMany(p => p.UserRoles)
                .HasForeignKey(d => d.RoleId)
                .HasConstraintName("FK__UserRoles__RoleI__3E52440B");

            entity.HasOne(d => d.User).WithMany(p => p.UserRoles)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__UserRoles__UserI__3D5E1FD2");
        });

        modelBuilder.Entity<Worker>(entity =>
        {
            entity.HasKey(e => e.WorkerId).HasName("PK__Workers__077C8806A96A869A");

            entity.HasIndex(e => e.UserId, "UQ__Workers__1788CCAD93F5CE3F").IsUnique();

            entity.Property(e => e.WorkerId).HasColumnName("WorkerID");
            entity.Property(e => e.Rating)
                .HasDefaultValue(0m)
                .HasColumnType("decimal(3, 2)");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.User).WithOne(p => p.Worker)
                .HasForeignKey<Worker>(d => d.UserId)
                .HasConstraintName("FK__Workers__UserID__45F365D3");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
