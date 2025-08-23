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

    public virtual DbSet<CompanyJobAssignment> CompanyJobAssignments { get; set; }

    public virtual DbSet<CompanyRole> CompanyRoles { get; set; }

    public virtual DbSet<CompanyService> CompanyServices { get; set; }

    public virtual DbSet<EmployeeTask> EmployeeTasks { get; set; }

    public virtual DbSet<Freelancer> Freelancers { get; set; }

    public virtual DbSet<FreelancerService> FreelancerServices { get; set; }

    public virtual DbSet<Job> Jobs { get; set; }

    public virtual DbSet<JobsService> JobsServices { get; set; }

    public virtual DbSet<Location> Locations { get; set; }

    public virtual DbSet<Message> Messages { get; set; }

    public virtual DbSet<Order> Orders { get; set; }

    public virtual DbSet<OrderItem> OrderItems { get; set; }

    public virtual DbSet<Product> Products { get; set; }

    public virtual DbSet<ProductsService> ProductsServices { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<Service> Services { get; set; }

    public virtual DbSet<Store> Stores { get; set; }

    public virtual DbSet<Tender> Tenders { get; set; }

    public virtual DbSet<TenderBid> TenderBids { get; set; }

    public virtual DbSet<TenderService> TenderServices { get; set; }

    public virtual DbSet<User> Users { get; set; }

    public virtual DbSet<UserRating> UserRatings { get; set; }

    public virtual DbSet<UserRole> UserRoles { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Data Source=localhost;Initial Catalog=IB190091;TrustServerCertificate=true;Trusted_Connection=true;");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Company>(entity =>
        {
            entity.HasKey(e => e.CompanyId).HasName("PK__Company__2D971C4CB07C8C16");

            entity.ToTable("Company");

            entity.HasIndex(e => e.Email, "UQ_Company_Email").IsUnique();

            entity.Property(e => e.CompanyId).HasColumnName("CompanyID");
            entity.Property(e => e.Bio).HasMaxLength(255);
            entity.Property(e => e.CompanyName).HasMaxLength(50);
            entity.Property(e => e.Email).HasMaxLength(255);
            entity.Property(e => e.LocationId).HasColumnName("LocationID");
            entity.Property(e => e.PhoneNumber).HasMaxLength(20);
            entity.Property(e => e.Rating).HasColumnType("decimal(3, 2)");
            entity.Property(e => e.RatingSum).HasColumnType("decimal(10, 2)");

            entity.HasOne(d => d.Location).WithMany(p => p.Companies)
                .HasForeignKey(d => d.LocationId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Company__Locatio__0F2D40CE");
        });

        modelBuilder.Entity<CompanyEmployee>(entity =>
        {
            entity.HasKey(e => e.CompanyEmployeeId).HasName("PK__CompanyE__3916BD7B00AC7565");

            entity.ToTable("CompanyEmployee");

            entity.Property(e => e.CompanyEmployeeId).HasColumnName("CompanyEmployeeID");
            entity.Property(e => e.CompanyId).HasColumnName("CompanyID");
            entity.Property(e => e.DateJoined).HasColumnType("datetime");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.Company).WithMany(p => p.CompanyEmployees)
                .HasForeignKey(d => d.CompanyId)
                .OnDelete(DeleteBehavior.Cascade)
				.HasConstraintName("FK__CompanyEm__Compa__69C6B1F5");

            entity.HasOne(d => d.CompanyRole).WithMany(p => p.CompanyEmployees)
                .HasForeignKey(d => d.CompanyRoleId)
                .HasConstraintName("FK__CompanyEm__Compa__7BE56230");

            entity.HasOne(d => d.User).WithMany(p => p.CompanyEmployees)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__CompanyEm__UserI__68D28DBC");
        });

        modelBuilder.Entity<CompanyJobAssignment>(entity =>
        {
            entity.HasKey(e => e.CompanyJobId).HasName("PK__CompanyJ__B783C37E390DA91B");

            entity.ToTable("CompanyJobAssignment");

            entity.Property(e => e.CompanyJobId).HasColumnName("CompanyJobID");
            entity.Property(e => e.AssignedAt).HasColumnType("datetime");
            entity.Property(e => e.CompanyEmployeeId).HasColumnName("CompanyEmployeeID");

            entity.HasOne(d => d.CompanyEmployee).WithMany(p => p.CompanyJobAssignments)
                .HasForeignKey(d => d.CompanyEmployeeId)
                .HasConstraintName("FK__CompanyJo__Compa__019E3B86");

            entity.HasOne(d => d.Job).WithMany(p => p.CompanyJobAssignments)
                .HasForeignKey(d => d.JobId)
                .HasConstraintName("FK__CompanyJo__JobId__02925FBF");
        });

        modelBuilder.Entity<CompanyRole>(entity =>
        {
            entity.HasKey(e => e.CompanyRoleId).HasName("PK__CompanyR__9CF06B50EF6710FD");

            entity.ToTable("CompanyRole");

            entity.Property(e => e.CompanyId).HasColumnName("CompanyID");
            entity.Property(e => e.RoleName).HasMaxLength(50);

            entity.HasOne(d => d.Company).WithMany(p => p.CompanyRoles)
                .HasForeignKey(d => d.CompanyId)
                .HasConstraintName("FK__CompanyRo__Compa__7AF13DF7");
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

				.OnDelete(DeleteBehavior.Cascade)
				.HasConstraintName("FK__CompanySe__Compa__1F98B2C1");

            entity.HasOne(d => d.Service).WithMany(p => p.CompanyServices)
                .HasForeignKey(d => d.ServiceId)
                .HasConstraintName("FK__CompanySe__Servi__208CD6FA");
        });

        modelBuilder.Entity<EmployeeTask>(entity =>
        {
            entity.HasKey(e => e.EmployeeTaskId).HasName("PK__Employee__47942B9E0BC0A370");

            entity.ToTable("EmployeeTask");

            entity.Property(e => e.CreatedAt).HasColumnType("datetime");
            entity.Property(e => e.Task).HasMaxLength(255);

            entity.HasOne(d => d.CompanyEmployee).WithMany(p => p.EmployeeTasks)
                .HasForeignKey(d => d.CompanyEmployeeId)
                .HasConstraintName("FK__EmployeeT__Compa__1387E197");

            entity.HasOne(d => d.Company).WithMany(p => p.EmployeeTasks)
                .HasForeignKey(d => d.CompanyId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__EmployeeT__Compa__269AB60B");

            entity.HasOne(d => d.Job).WithMany(p => p.EmployeeTasks)
                .HasForeignKey(d => d.JobId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__EmployeeT__JobId__25A691D2");
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
				.OnDelete(DeleteBehavior.Cascade) 
				.HasConstraintName("FK__Freelance__Freel__1F63A897");

            entity.HasOne(d => d.Service).WithMany(p => p.FreelancerServices)
                .HasForeignKey(d => d.ServiceId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Freelance__Servi__2057CCD0");
        });

        modelBuilder.Entity<Job>(entity =>
        {
            entity.HasKey(e => e.JobId).HasName("PK__Jobs__056690C234DE197E");

            entity.Property(e => e.CompanyId).HasColumnName("CompanyID");
            entity.Property(e => e.FreelancerId).HasColumnName("FreelancerID");
            entity.Property(e => e.IsFreelancer).HasColumnName("isFreelancer");
            entity.Property(e => e.IsTenderFinalized).HasColumnName("isTenderFinalized");
            entity.Property(e => e.JobDate).HasColumnType("datetime");
            entity.Property(e => e.JobDescription).HasMaxLength(255);
            entity.Property(e => e.JobStatus)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasDefaultValue("unnaproved")
                .HasColumnName("Job_Status");
            entity.Property(e => e.JobTitle).HasMaxLength(255);
            entity.Property(e => e.PayEstimate).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.PayInvoice).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.RescheduleNote).HasMaxLength(255);
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.Company).WithMany(p => p.Jobs)
                .HasForeignKey(d => d.CompanyId)
                .HasConstraintName("FK__Jobs__CompanyID__7EC1CEDB");

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

            entity.Property(e => e.CompanyId).HasColumnName("CompanyID");
            entity.Property(e => e.CreatedAt).HasColumnType("datetime");
            entity.Property(e => e.Message1)
                .HasMaxLength(255)
                .HasColumnName("Message");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.Company).WithMany(p => p.Messages)
                .HasForeignKey(d => d.CompanyId)
                .HasConstraintName("FK__Messages__Compan__7E8CC4B1");

            entity.HasOne(d => d.Store).WithMany(p => p.Messages)
                .HasForeignKey(d => d.StoreId)
                .HasConstraintName("FK__Messages__StoreI__7F80E8EA");

            entity.HasOne(d => d.User).WithMany(p => p.Messages)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__Messages__UserID__2CBDA3B5");
        });

        modelBuilder.Entity<Order>(entity =>
        {
            entity.HasKey(e => e.OrderId).HasName("PK__Orders__C3905BCF591ED19A");

            entity.Property(e => e.CreatedAt).HasColumnType("datetime");

            entity.HasOne(d => d.User).WithMany(p => p.Orders)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Orders_Users");
        });

        modelBuilder.Entity<OrderItem>(entity =>
        {
            entity.HasKey(e => e.OrderItemsId).HasName("PK__OrderIte__D5BB2555E439B0B6");

            entity.HasOne(d => d.Order).WithMany(p => p.OrderItems)
                .HasForeignKey(d => d.OrderId)
                .HasConstraintName("FK_OrderItems_Orders");

            entity.HasOne(d => d.Product).WithMany(p => p.OrderItems)
                .HasForeignKey(d => d.ProductId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_OrderItems_Products");

            entity.HasOne(d => d.Store).WithMany(p => p.OrderItems)
                .HasForeignKey(d => d.StoreId)
                .HasConstraintName("FK_OrderItems_Stores");
        });

        modelBuilder.Entity<Product>(entity =>
        {
            entity.HasKey(e => e.ProductId).HasName("PK__Products__B40CC6CDD7BA1DD8");

            entity.Property(e => e.Price).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.ProductName).HasMaxLength(100);

            entity.HasOne(d => d.Store).WithMany(p => p.Products)
                .HasForeignKey(d => d.StoreId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Products_Stores");
        });

        modelBuilder.Entity<ProductsService>(entity =>
        {
            entity.HasKey(e => new { e.ProductId, e.ServiceId }).HasName("PK__Products__085D7DE34C94B474");

            entity.ToTable("ProductsService");

            entity.Property(e => e.ProductId).HasColumnName("ProductID");
            entity.Property(e => e.ServiceId).HasColumnName("ServiceID");
            entity.Property(e => e.CreatedAt).HasColumnType("datetime");

            entity.HasOne(d => d.Product).WithMany(p => p.ProductsServices)
                .HasForeignKey(d => d.ProductId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ProductsS__Produ__4DE98D56");

            entity.HasOne(d => d.Service).WithMany(p => p.ProductsServices)
                .HasForeignKey(d => d.ServiceId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ProductsS__Servi__4EDDB18F");
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

        modelBuilder.Entity<Store>(entity =>
        {
            entity.HasKey(e => e.StoreId).HasName("PK__Stores__3B82F10142B7B44A");

            entity.Property(e => e.Address).HasMaxLength(50);
            entity.Property(e => e.StoreName).HasMaxLength(100);

            entity.HasOne(d => d.Location).WithMany(p => p.Stores)
                .HasForeignKey(d => d.LocationId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Stores__Location__4460231C");

            entity.HasOne(d => d.User).WithMany(p => p.Stores)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Stores_Users");
        });

        modelBuilder.Entity<Tender>(entity =>
        {
            entity.HasKey(e => e.TenderId).HasName("PK__Tender__B21B4268197B2C83");

            entity.ToTable("Tender");

            entity.Property(e => e.JobDate).HasColumnType("datetime");
            entity.Property(e => e.JobDescription).HasMaxLength(255);

            entity.HasOne(d => d.Company).WithMany(p => p.Tenders)
                .HasForeignKey(d => d.CompanyId)
                .HasConstraintName("FK__Tender__CompanyI__5C37ACAD");

            entity.HasOne(d => d.Freelancer).WithMany(p => p.Tenders)
                .HasForeignKey(d => d.FreelancerId)
                .HasConstraintName("FK__Tender__Freelanc__5B438874");

            entity.HasOne(d => d.User).WithMany(p => p.Tenders)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__Tender__UserId__5A4F643B");
        });

        modelBuilder.Entity<TenderBid>(entity =>
        {
            entity.HasKey(e => e.TenderBidId).HasName("PK__TenderBi__5C928D9693AA275C");

            entity.ToTable("TenderBid");

            entity.Property(e => e.BidAmount).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.BidDescription).HasMaxLength(255);
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.DateFinished).HasColumnType("datetime");

            entity.HasOne(d => d.Company).WithMany(p => p.TenderBids)
                .HasForeignKey(d => d.CompanyId)
                .HasConstraintName("FK__TenderBid__Compa__61F08603");

            entity.HasOne(d => d.Freelancer).WithMany(p => p.TenderBids)
                .HasForeignKey(d => d.FreelancerId)
                .HasConstraintName("FK__TenderBid__Freel__60FC61CA");

            entity.HasOne(d => d.Job).WithMany(p => p.TenderBids)
                .HasForeignKey(d => d.JobId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__TenderBid__JobId__6A85CC04");
        });

        modelBuilder.Entity<TenderService>(entity =>
        {
            entity.HasKey(e => new { e.TenderId, e.ServiceId }).HasName("PK__TenderSe__0E4AF96661B872C5");

            entity.ToTable("TenderService");

            entity.Property(e => e.ServiceId).HasColumnName("ServiceID");
            entity.Property(e => e.CreatedAt).HasColumnType("datetime");

            entity.HasOne(d => d.Service).WithMany(p => p.TenderServices)
                .HasForeignKey(d => d.ServiceId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__TenderSer__Servi__67A95F59");

            entity.HasOne(d => d.Tender).WithMany(p => p.TenderServices)
                .HasForeignKey(d => d.TenderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__TenderSer__Tende__66B53B20");
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

        modelBuilder.Entity<UserRating>(entity =>
        {
            entity.HasKey(e => e.UserRatingId).HasName("PK__UserRati__9E5FEAAA63E96E4C");

            entity.Property(e => e.UserRatingId).HasColumnName("UserRatingID");
            entity.Property(e => e.CompanyId).HasColumnName("CompanyID");
            entity.Property(e => e.FreelancerId).HasColumnName("FreelancerID");
            entity.Property(e => e.Rating).HasColumnType("decimal(3, 2)");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.Company).WithMany(p => p.UserRatings)
                .HasForeignKey(d => d.CompanyId)
                .HasConstraintName("FK__UserRatin__Compa__6B79F03D");

            entity.HasOne(d => d.Freelancer).WithMany(p => p.UserRatings)
                .HasForeignKey(d => d.FreelancerId)
                .HasConstraintName("FK__UserRatin__Freel__42ACE4D4");

            entity.HasOne(d => d.Job).WithMany(p => p.UserRatings)
                .HasForeignKey(d => d.JobId)
                .HasConstraintName("FK__UserRatin__JobId__4589517F");

            entity.HasOne(d => d.User).WithMany(p => p.UserRatings)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__UserRatin__UserI__41B8C09B");
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


		try
		{
			Console.WriteLine("Seed podataka");
			modelBuilder.Seed();
		}
		catch (Exception ex)
		{
			Console.WriteLine("Greška");
		}
		OnModelCreatingPartial(modelBuilder);
	
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
public static class ModelBuilderExtensions
{
    public static void Seed(this ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Database.Role>().HasData(
            new Database.Role { RoleId = 1, RoleName = "Admin", RoleDescription = "Administrator for the application", IsDeleted = false },
            new Database.Role { RoleId = 2, RoleName = "User", RoleDescription = "Application User", IsDeleted = false },
            new Database.Role { RoleId = 3, RoleName = "Freelancer", RoleDescription = "Freelance worker", IsDeleted = false },
            new Database.Role { RoleId = 4, RoleName = "Company Admin", RoleDescription = "Company Administrator", IsDeleted = false },
            new Database.Role { RoleId = 5, RoleName = "CompanyEmployee", RoleDescription = "Employee for a company", IsDeleted = false },
            new Database.Role { RoleId = 6, RoleName = "StoreAdministrator", RoleDescription = "Administrator for a store", IsDeleted = false }
        );
        modelBuilder.Entity<Database.Service>().HasData(
            new Database.Service { ServiceId = 1, ServiceName = "Keramika", Image = null, IsDeleted = false },
            new Database.Service { ServiceId = 2, ServiceName = "Elektrika", Image = null, IsDeleted = false },
            new Database.Service { ServiceId = 3, ServiceName = "Molereaj", Image = null, IsDeleted = false },
            new Database.Service { ServiceId = 4, ServiceName = "Mreže", Image = null, IsDeleted = false },
            new Database.Service { ServiceId = 5, ServiceName = "Staklarstvo", Image = null, IsDeleted = false },
            new Database.Service { ServiceId = 6, ServiceName = "Zidarstvo", Image = null, IsDeleted = false },
            new Database.Service { ServiceId = 7, ServiceName = "Higijena", Image = null, IsDeleted = false }
            );
        modelBuilder.Entity<Database.Location>().HasData(
            new Database.Location { LocationId = 1, LocationName = "Mostar", IsDeleted = false },
            new Database.Location { LocationId = 2, LocationName = "Sarajevo", IsDeleted = false }
            );
       



        modelBuilder.Entity<Database.User>().HasData(
            new Database.User
            {
                UserId = 1,
                FirstName = "Admin",
                LastName = "Admin",
                Email = "admin@email.com",
                PasswordHash = "5tJjrb/iLUCEc6wZo/o0Se14Cnk=",
                PasswordSalt = "OUJ+PWXNzP6V9uxMwP7FCg==",
                CreatedAt = new DateTime(2025, 05, 21),
				Image = null,
                LocationId = 1,
                IsDeleted = false,
                PhoneNumber = "+38761223223",
                Address = "Mostar, b.b."

            },
            new Database.User
            {
                UserId = 2,
                FirstName = "Korisnik",
                LastName = "Aplikacije",
                Email = "korisnik@email.com",
                PasswordHash = "oJyCENbGhk5rSYLZRG0FGb32ejw=",
                PasswordSalt = "gYMe5raFyV04jACZCJ7VIQ==",
                CreatedAt = new DateTime(2025, 05, 21),
                Image = null,
                LocationId = 1,
                IsDeleted = false,
                PhoneNumber = "+38761223224",
                Address = "Mostar, b.b."

            },
            new Database.User
            {
                UserId = 3,
                FirstName = "Aplikacijski",
                LastName = "Korisnik",
                Email = "korisnik2@email.com",
                PasswordHash = "XyBQJzXrmRQjLLUJ8rOcYR19T3U=",
                PasswordSalt = "VnkK0uaxVrvoLWcFYztQ6w==",
                CreatedAt = new DateTime(2025, 05, 21),
                Image = null,
                LocationId = 2,
                IsDeleted = false,
                PhoneNumber = "+38761223224",
                Address = "Sarajevo, b.b."

            },
            new Database.User
            {
                UserId = 4,
                FirstName = "Radnik",
                LastName = "Struja",
                Email = "struja@email.com",
                PasswordHash = "7DktpTiYrzrxU9OT0Y8nrAIAmiw=",
                PasswordSalt = "GCzdDsLTTNlcpdbJ9Pl2sg==",
                CreatedAt = new DateTime(2025, 05, 21),
                Image = null,
                LocationId = 1,
                IsDeleted = false,
                PhoneNumber = "+38761223225",
                Address = "Mostar, b.b."

            },
            new Database.User
            {
                UserId = 5,
                FirstName = "Administrator",
                LastName = "Firme",
                Email = "vlasnik@email.com",
                PasswordHash = "XL93jgkZ9pa7tCihSE9kUjULgc4=",
                PasswordSalt = "VlmtnpExEkGWf5mL6bKhRw==",
                CreatedAt = new DateTime(2025, 05, 21),
				Image = null,
                LocationId = 1,
                IsDeleted = false,
                PhoneNumber = "+38761223226",
                Address = "Mostar, b.b."

            },

            new Database.User
            {
                UserId = 6,
                FirstName = "Zaposlenik",
                LastName = "Firme",
                Email = "zaposlenik@email.com",
                PasswordHash = "qb+MAlKTax4Vt2iOyztRSUsL7Bw=",
                PasswordSalt = "lZUxqs+CAHsgVPEB93mriQ==",
                CreatedAt = new DateTime(2025, 05, 21),
				Image = null,
                LocationId = 1,
                IsDeleted = false,
                PhoneNumber = "+38761223227",
                Address = "Mostar, b.b."

            },

            new Database.User
            {
                UserId = 7,
                FirstName = "Administrator",
                LastName = "Trgovine",
                Email = "trgovina@email.com",
                PasswordHash = "zU5py2BrtjOU7FpRw7cBGMCpupM=",
                PasswordSalt = "nEd6qI+j53C4CX+cwbp5Ng==",
                CreatedAt = new DateTime(2025, 05, 21),
				Image = null,
                LocationId = 1,
                IsDeleted = false,
                PhoneNumber = "+38761223228",
                Address = "Mostar, b.b."

            },
            new Database.User
            {
                UserId = 8,
                FirstName = "Keramika",
                LastName = "Trgovina",
                Email = "trgovina2@email.com",
                PasswordHash = "mIYgsIL4940pyHDFceF39fJ9f7o==",
                PasswordSalt = "MfQtlQScHNSWa1cA5lJEHw==",
                CreatedAt = new DateTime(2025, 05, 21),
				Image = null,
                LocationId = 1,
                IsDeleted = false,
                PhoneNumber = "+38761223229",
                Address = "Mostar, b.b."

            },
            new Database.User
            {
                UserId = 9,
                FirstName = "Radnik",
                LastName = "Keramika",
                Email = "keramika@email.com",
                PasswordHash = "mIYgsIL4940pyHDFceF39fJ9f7o==",
                PasswordSalt = "MfQtlQScHNSWa1cA5lJEHw==",
                CreatedAt = new DateTime(2025, 05, 21),
				Image = null,
                LocationId = 2,
                IsDeleted = false,
                PhoneNumber = "+38761223230",
                Address = "Sarajevo, b.b."

            },
            new Database.User
            {
                UserId = 10,
                FirstName = "Radnik",
                LastName = "Moler",
                Email = "moler@email.com",
                PasswordHash = "mIYgsIL4940pyHDFceF39fJ9f7o==",
                PasswordSalt = "MfQtlQScHNSWa1cA5lJEHw==",
                CreatedAt = new DateTime(2025, 05, 21),
				Image = null,
                LocationId = 2,
                IsDeleted = false,
                PhoneNumber = "+38761223230",
                Address = "Sarajevo, b.b."

            },
            new Database.User
            {
                UserId = 11,
                FirstName = "Radnik",
                LastName = "Zidar",
                Email = "zidar@email.com",
                PasswordHash = "mIYgsIL4940pyHDFceF39fJ9f7o==",
                PasswordSalt = "MfQtlQScHNSWa1cA5lJEHw==",
                CreatedAt = new DateTime(2025, 05, 21),
				Image = null,
                LocationId = 2,
                IsDeleted = false,
                PhoneNumber = "+38761223230",
                Address = "Sarajevo, b.b."

            },
            new Database.User
            {
                UserId = 12,
                FirstName = "Radnik",
                LastName = "Staklar",
                Email = "staklar@email.com",
                PasswordHash = "mIYgsIL4940pyHDFceF39fJ9f7o==",
                PasswordSalt = "MfQtlQScHNSWa1cA5lJEHw==",
                CreatedAt = new DateTime(2025, 05, 21),
				Image = null,
                LocationId = 2,
                IsDeleted = false,
                PhoneNumber = "+38761223230",
                Address = "Sarajevo, b.b."

            },
            new Database.User
            {
                UserId = 13,
                FirstName = "Radnik",
                LastName = "Higijena",
                Email = "higijena@email.com",
                PasswordHash = "mIYgsIL4940pyHDFceF39fJ9f7o==",
                PasswordSalt = "MfQtlQScHNSWa1cA5lJEHw==",
                CreatedAt = new DateTime(2025, 05, 21),
				Image = null,
                LocationId = 2,
                IsDeleted = false,
                PhoneNumber = "+38761223230",
                Address = "Sarajevo, b.b."

            },
            new Database.User
            {
                UserId = 14,
                FirstName = "Radnik",
                LastName = "Mreže",
                Email = "mreze@email.com",
                PasswordHash = "mIYgsIL4940pyHDFceF39fJ9f7o==",
                PasswordSalt = "MfQtlQScHNSWa1cA5lJEHw==",
                CreatedAt = new DateTime(2025, 05, 21),
				Image = null,
                LocationId = 2,
                IsDeleted = false,
                PhoneNumber = "+38761223230",
                Address = "Sarajevo, b.b."

            },
            new Database.User
            {
                UserId = 15,
                FirstName = "Vlasnik",
                LastName = "Firme",
                Email = "firma@email.com",
                PasswordHash = "XL93jgkZ9pa7tCihSE9kUjULgc4=",
                PasswordSalt = "VlmtnpExEkGWf5mL6bKhRw==",
                CreatedAt = new DateTime(2025, 05, 21),
				Image = null,
                LocationId = 2,
                IsDeleted = false,
                PhoneNumber = "+38761223226",
                Address = "Mostar, b.b."

            },
            new Database.User
            {
                UserId = 16,
                FirstName = "Terenac",
                LastName = "Firme",
                Email = "terenac@email.com",
                PasswordHash = "XL93jgkZ9pa7tCihSE9kUjULgc4=",
                PasswordSalt = "VlmtnpExEkGWf5mL6bKhRw==",
                CreatedAt = new DateTime(2025, 05, 21),
				Image = null,
                LocationId = 1,
                IsDeleted = false,
                PhoneNumber = "+38761223226",
                Address = "Mostar, b.b."

            },
            new Database.User
            {
                UserId = 17,
                FirstName = "Monter",
                LastName = "Firme",
                Email = "monter@email.com",
                PasswordHash = "XL93jgkZ9pa7tCihSE9kUjULgc4=",
                PasswordSalt = "VlmtnpExEkGWf5mL6bKhRw==",
                CreatedAt = new DateTime(2025, 05, 21),
				Image = null,
                LocationId = 1,
                IsDeleted = false,
                PhoneNumber = "+38761223226",
                Address = "Mostar, b.b."

            },
            new Database.User
            {
                UserId = 18,
                FirstName = "Novi",
                LastName = "Radnik",
                Email = "novi@email.com",
                PasswordHash = "XL93jgkZ9pa7tCihSE9kUjULgc4=",
                PasswordSalt = "VlmtnpExEkGWf5mL6bKhRw==",
                CreatedAt = new DateTime(2025, 05, 21),
				Image = null,
                LocationId = 1,
                IsDeleted = false,
                PhoneNumber = "+38761223226",
                Address = "Mostar, b.b."

            },
            new Database.User
            {
                UserId = 19,
                FirstName = "Zaposlenik",
                LastName = "FirmeDva",
                Email = "dva@email.com",
                PasswordHash = "XL93jgkZ9pa7tCihSE9kUjULgc4=",
                PasswordSalt = "VlmtnpExEkGWf5mL6bKhRw==",
                CreatedAt = new DateTime(2025, 05, 21),
				Image = null,
                LocationId = 1,
                IsDeleted = false,
                PhoneNumber = "+38761223226",
                Address = "Mostar, b.b."

            },
            new Database.User
            {
                UserId = 20,
                FirstName = "Uposlenik",
                LastName = "Firme",
                Email = "uposlenik@email.com",
                PasswordHash = "XL93jgkZ9pa7tCihSE9kUjULgc4=",
                PasswordSalt = "VlmtnpExEkGWf5mL6bKhRw==",
                CreatedAt = new DateTime(2025, 05, 21),
				Image = null,
                LocationId = 1,
                IsDeleted = false,
                PhoneNumber = "+38761223226",
                Address = "Mostar, b.b."

            },
            new Database.User
            {
                UserId = 21,
                FirstName = "Test",
                LastName = "Tester",
                Email = "test@email.com",
                PasswordHash = "XL93jgkZ9pa7tCihSE9kUjULgc4=",
                PasswordSalt = "VlmtnpExEkGWf5mL6bKhRw==",
                CreatedAt = new DateTime(2025, 05, 21),
				Image = null,
                LocationId = 1,
                IsDeleted = false,
                PhoneNumber = "+38761223226",
                Address = "Mostar, b.b.",
            }



			);
		modelBuilder.Entity<Database.UserRole>().HasData(
		   new Database.UserRole
		   {
			   UserRoleId = 1,
			   UserId = 1,
			   RoleId = 1,
			   CreatedAt = new DateTime(2025, 05, 21),
			   ChangedAt = null
		   },
			new Database.UserRole
			{
				UserRoleId = 2,
				UserId = 2,
				RoleId = 2,
				CreatedAt = new DateTime(2025, 05, 21),
				ChangedAt = null
			},
			 new Database.UserRole
			 {
				 UserRoleId = 3,
				 UserId = 3,
				 RoleId = 2,
				 CreatedAt = new DateTime(2025, 05, 21),
				 ChangedAt = null
			 },
			  new Database.UserRole
			  {
				  UserRoleId = 4,
				  UserId = 4,
				  RoleId = 2,
				  CreatedAt = new DateTime(2025, 05, 21),
				  ChangedAt = null
			  },
			   new Database.UserRole
			   {
				   UserRoleId = 5,
				   UserId = 4,
				   RoleId = 3,
				   CreatedAt = new DateTime(2025, 05, 21),
				   ChangedAt = null
			   },
				new Database.UserRole
				{
					UserRoleId = 6,
					UserId = 5,
					RoleId = 2,
					CreatedAt = new DateTime(2025, 05, 21),
					ChangedAt = null
				},
				new Database.UserRole
				{
					UserRoleId = 7,
					UserId = 5,
					RoleId = 4,
					CreatedAt = new DateTime(2025, 05, 21),
					ChangedAt = null
				},
				 new Database.UserRole
				 {
					 UserRoleId = 8,
					 UserId = 6,
					 RoleId = 2,
					 CreatedAt = new DateTime(2025, 05, 21),
					 ChangedAt = null
				 },
				 new Database.UserRole
				 {
					 UserRoleId = 9,
					 UserId = 6,
					 RoleId = 5,
					 CreatedAt = new DateTime(2025, 05, 21),
					 ChangedAt = null
				 },
				  new Database.UserRole
				  {
					  UserRoleId = 10,
					  UserId = 7,
					  RoleId = 2,
					  CreatedAt = new DateTime(2025, 05, 21),
					  ChangedAt = null
				  },
				   new Database.UserRole
				   {
					   UserRoleId = 11,
					   UserId = 7,
					   RoleId = 6,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 12,
					   UserId = 8,
					   RoleId = 2,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 13,
					   UserId = 8,
					   RoleId = 6,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 14,
					   UserId = 9,
					   RoleId = 2,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 15,
					   UserId = 9,
					   RoleId = 3,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 16,
					   UserId = 10,
					   RoleId = 2,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 17,
					   UserId = 10,
					   RoleId = 3,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 18,
					   UserId = 11,
					   RoleId = 2,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 19,
					   UserId = 11,
					   RoleId = 3,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 20,
					   UserId = 12,
					   RoleId = 2,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 21,
					   UserId = 12,
					   RoleId = 3,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 22,
					   UserId = 13,
					   RoleId = 2,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 23,
					   UserId = 13,
					   RoleId = 3,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 24,
					   UserId = 14,
					   RoleId = 2,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 25,
					   UserId = 14,
					   RoleId = 3,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 26,
					   UserId = 15,
					   RoleId = 2,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 27,
					   UserId = 15,
					   RoleId = 4,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 28,
					   UserId = 16,
					   RoleId = 2,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 29,
					   UserId = 16,
					   RoleId = 5,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 30,
					   UserId = 17,
					   RoleId = 2,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 31,
					   UserId = 17,
					   RoleId = 5,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 32,
					   UserId = 18,
					   RoleId = 2,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 33,
					   UserId = 18,
					   RoleId = 5,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 34,
					   UserId = 19,
					   RoleId = 2,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 35,
					   UserId = 19,
					   RoleId = 5,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 36,
					   UserId = 20,
					   RoleId = 2,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
				   new Database.UserRole
				   {
					   UserRoleId = 37,
					   UserId = 20,
					   RoleId = 5,
					   CreatedAt = new DateTime(2025, 05, 21),
					   ChangedAt = null
				   },
					new Database.UserRole
					{
						UserRoleId = 38,
						UserId = 21,
						RoleId = 2,
						CreatedAt = new DateTime(2025, 05, 21),
						ChangedAt = null
					}


		   );




		
        modelBuilder.Entity<Database.Freelancer>().HasData(
            new Database.Freelancer
            {
                FreelancerId = 4,
                Bio = "Iskusan električar sa 6 godina iskustva. Završen zanat u elektrotehničkoj školi u Mostaru.",
                Rating = 3.63m,
                ExperianceYears = 6,
                WorkingDays = 54,
                StartTime = new TimeOnly(8, 0),
                EndTime = new TimeOnly(16, 0),
                IsDeleted = false,
                IsApplicant = false,
                TotalRatings = 0,
                RatingSum = 0

            },
             new Database.Freelancer
             {
                 FreelancerId = 9,
                 Bio = "Iskusan keramičar sa 4 godina iskustva. Završen zanat u Mostaru.",
                 Rating = 4.00m,
                 ExperianceYears = 4,
                 WorkingDays = 54,
                 StartTime = new TimeOnly(8, 0),
                 EndTime = new TimeOnly(16, 0),
                 IsDeleted = false,
                 IsApplicant = false,
                 TotalRatings = 0,
                 RatingSum = 0

             },
              new Database.Freelancer
              {
                  FreelancerId = 10,
                  Bio = "Iskusan moler sa 9 godina iskustva. Završen zanat u Mostaru.",
                  Rating = 4.00m,
                  ExperianceYears = 9,
                  WorkingDays = 54,
                  StartTime = new TimeOnly(8, 0),
                  EndTime = new TimeOnly(16, 0),
                  IsDeleted = false,
                  IsApplicant = false,
                  TotalRatings = 0,
                  RatingSum = 0

              },
              new Database.Freelancer
              {
                  FreelancerId = 11,
                  Bio = "Iskusan zidar sa 5 godina iskustva. Završen zanat u Mostaru.",
                  Rating = 4.00m,
                  ExperianceYears = 5,
                  WorkingDays = 54,
                  StartTime = new TimeOnly(8, 0),
                  EndTime = new TimeOnly(16, 0),
                  IsDeleted = false,
                  IsApplicant = false,
                  TotalRatings = 0,
                  RatingSum = 0

              },
              new Database.Freelancer
              {
                  FreelancerId = 12,
                  Bio = "Iskusan staklar sa 7 godina iskustva. Završen zanat u Mostaru.",
                  Rating = 4.00m,
                  ExperianceYears = 7,
                  WorkingDays = 54,
                  StartTime = new TimeOnly(8, 0),
                  EndTime = new TimeOnly(16, 0),
                  IsDeleted = false,
                  IsApplicant = false,
                  TotalRatings = 0,
                  RatingSum = 0
              },
              new Database.Freelancer
              {
                  FreelancerId = 13,
                  Bio = "Iskusan radnik za higijenu sa 3 godine iskustva. Završen zanat u Mostaru.",
                  Rating = 4.00m,
                  ExperianceYears = 3,
                  WorkingDays = 54,
                  StartTime = new TimeOnly(8, 0),
                  EndTime = new TimeOnly(16, 0),
                  IsDeleted = false,
                  IsApplicant = false,
                  TotalRatings = 0,
                  RatingSum = 0


              },
              new Database.Freelancer
              {
                  FreelancerId = 14,
                  Bio = "Iskusan radnik za mreže sa 4 godine iskustva. Završen zanat u Mostaru.",
                  Rating = 4.00m,
                  ExperianceYears = 4,
                  WorkingDays = 54,
                  StartTime = new TimeOnly(8, 0),
                  EndTime = new TimeOnly(16, 0),
                  IsDeleted = false,
                  IsApplicant = false,
                  TotalRatings = 0,
                  RatingSum = 0
              }

            );
		modelBuilder.Entity<Database.FreelancerService>().HasData(
			new Database.FreelancerService
			{
				FreelancerId = 4,
				ServiceId = 2,
				CreatedAt = new DateTime(2025, 05, 21),
			},
			new Database.FreelancerService
			{
				FreelancerId = 9,
				ServiceId = 1,
				CreatedAt = new DateTime(2025, 05, 21),
			},
			 new Database.FreelancerService
			 {
				 FreelancerId = 9,
				 ServiceId = 2,
				 CreatedAt = new DateTime(2025, 05, 21),
			 },
			new Database.FreelancerService
			{
				FreelancerId = 10,
				ServiceId = 3,
				CreatedAt = new DateTime(2025, 05, 21)
			},
			new Database.FreelancerService
			{
				FreelancerId = 10,
				ServiceId = 2,
				CreatedAt = new DateTime(2025, 05, 21),
			},
			new Database.FreelancerService
			{
				FreelancerId = 11,
				ServiceId = 6,
				CreatedAt = new DateTime(2025, 05, 21),
			},
			new Database.FreelancerService
			{
				FreelancerId = 11,
				ServiceId = 2,
				CreatedAt = new DateTime(2025, 05, 21),
			},
			new Database.FreelancerService
			{
				FreelancerId = 12,
				ServiceId = 5,
				CreatedAt = new DateTime(2025, 05, 21),
			},
			new Database.FreelancerService
			{
				FreelancerId = 12,
				ServiceId = 2,
				CreatedAt = new DateTime(2025, 05, 21),
			},
			new Database.FreelancerService
			{
				FreelancerId = 13,
				ServiceId = 7,
				CreatedAt = new DateTime(2025, 05, 21),
			},
			new Database.FreelancerService
			{
				FreelancerId = 13,
				ServiceId = 2,
				CreatedAt = new DateTime(2025, 05, 21),
			},
			new Database.FreelancerService
			{
				FreelancerId = 14,
				ServiceId = 4,
				CreatedAt = new DateTime(2025, 05, 21),
			},
			new Database.FreelancerService
			{
				FreelancerId = 14,
				ServiceId = 2,
				CreatedAt = new DateTime(2025, 05, 21),
			}

			);
		
        modelBuilder.Entity<Database.Company>().HasData(
            new Database.Company
            {
                CompanyId = 1,
                CompanyName = "Elektroinženjering d.o.o.",
                Bio = "Firma koja se bavi elektroinstalacijama i održavanjem električnih sistema.",
                Email = "elektro@email.com",
                PhoneNumber = "+38761223226",
                ExperianceYears = 5,
                Image = null,
                WorkingDays = 54,
                StartTime = new TimeOnly(8, 0),
                EndTime = new TimeOnly(16, 0),
                LocationId = 1,
                IsDeleted = false,
                IsApplicant = false,
                Rating = 4.00m,
                TotalRatings = 17,
                RatingSum = 72.00m

            },
             new Database.Company
             {
                 CompanyId = 2,
                 CompanyName = "Elektroinženjering i Keramika d.o.o.",
                 Bio = "Firma koja se bavi elektroinstalacijama i održavanjem električnih sistema te keramikom.",
                 Email = "elektroKeramika@email.com",
                 PhoneNumber = "+38761223312",
                 ExperianceYears = 3,
                 Image = null,
                 WorkingDays = 54,
                 StartTime = new TimeOnly(8, 0),
                 EndTime = new TimeOnly(16, 0),
                 LocationId = 1,
                 IsDeleted = false,
                 IsApplicant = false,
                 Rating = 3.00m,
                 TotalRatings = 17,
                 RatingSum = 72.00m

             },
              new Database.Company
              {
                  CompanyId = 3,
                  CompanyName = "Zidarstvo i Moleraj d.o.o.",
                  Bio = "Firma koja se bavi zidarstvom i molerajom.",
                  Email = "zidarmoler@email.com",
                  PhoneNumber = "+38761223317",
                  ExperianceYears = 7,
                  Image = null,
                  WorkingDays = 54,
                  StartTime = new TimeOnly(8, 0),
                  EndTime = new TimeOnly(16, 0),
                  LocationId = 1,
                  IsDeleted = false,
                  IsApplicant = false,
                  Rating = 3.00m,
                  TotalRatings = 17,
                  RatingSum = 72.00m

              },
               new Database.Company
               {
                   CompanyId = 4,
                   CompanyName = "Moleraj i Higijena d.o.o.",
                   Bio = "Firma koja se bavi molerajom i higijenom.",
                   Email = "higijenamoler@email.com",
                   PhoneNumber = "+38761223327",
                   ExperianceYears = 7,
                   Image = null,
                   WorkingDays = 54,
                   StartTime = new TimeOnly(8, 0),
                   EndTime = new TimeOnly(16, 0),
                   LocationId = 2,
                   IsDeleted = false,
                   IsApplicant = false,
                   Rating = 3.00m,
                   TotalRatings = 17,
                   RatingSum = 72.00m

               },
                new Database.Company
                {
                    CompanyId = 5,
                    CompanyName = "Umreži",
                    Bio = "Firma koja se bavi umrežavanjem",
                    Email = "umreži@email.com",
                    PhoneNumber = "+38761423327",
                    ExperianceYears = 7,
                    Image = null,
                    WorkingDays = 54,
                    StartTime = new TimeOnly(8, 0),
                    EndTime = new TimeOnly(16, 0),
                    LocationId = 2,
                    IsDeleted = false,
                    IsApplicant = false,
                    Rating = 3.00m,
                    TotalRatings = 17,
                    RatingSum = 72.00m

                },
                new Database.Company
                {
                    CompanyId = 6,
                    CompanyName = "Staklo Mostar",
                    Bio = "Firma koja se bavi staklarstvom",
                    Email = "staklo@email.com",
                    PhoneNumber = "+38761433327",
                    ExperianceYears = 7,
                    Image = null,
                    WorkingDays = 54,
                    StartTime = new TimeOnly(8, 0),
                    EndTime = new TimeOnly(16, 0),
                    LocationId = 1,
                    IsDeleted = false,
                    IsApplicant = false,
                    Rating = 3.00m,
                    TotalRatings = 17,
                    RatingSum = 72.00m

                },
                new Database.Company
                {
                    CompanyId = 7,
                    CompanyName = "Zidarstvo Sarajevo",
                    Bio = "Firma koja se bavi zidarstvom",
                    Email = "zidari@email.com",
                    PhoneNumber = "+38761434327",
                    ExperianceYears = 7,
                    Image = null,
                    WorkingDays = 54,
                    StartTime = new TimeOnly(8, 0),
                    EndTime = new TimeOnly(16, 0),
                    LocationId = 2,
                    IsDeleted = false,
                    IsApplicant = false,
                    Rating = 3.00m,
                    TotalRatings = 17,
                    RatingSum = 72.00m

                }


            );
		modelBuilder.Entity<Database.CompanyService>().HasData(
			new Database.CompanyService
			{
				CompanyId = 1,
				ServiceId = 2,
				CreatedAt = new DateTime(2025, 05, 21),
			},
			new Database.CompanyService
			{
				CompanyId = 2,
				ServiceId = 1,
				CreatedAt = new DateTime(2025, 05, 21),
			},
			new Database.CompanyService
			{
				CompanyId = 2,
				ServiceId = 2,
				CreatedAt = new DateTime(2025, 05, 21),
			},
			new Database.CompanyService
			{
				CompanyId = 3,
				ServiceId = 2,
				CreatedAt = new DateTime(2025, 05, 21),
			},
			new Database.CompanyService
			{
				CompanyId = 3,
				ServiceId = 4,
				CreatedAt = new DateTime(2025, 05, 21),
			},
			new Database.CompanyService
			{
				CompanyId = 4,
				ServiceId = 2,
				CreatedAt = new DateTime(2025, 05, 21),
			},
			new Database.CompanyService
			{
				CompanyId = 4,
				ServiceId = 5,
				CreatedAt = new DateTime(2025, 05, 21),
			},

			new Database.CompanyService
			{
				CompanyId = 5,
				ServiceId = 2,
				CreatedAt = new DateTime(2025, 05, 21),
			},
			new Database.CompanyService
			{
				CompanyId = 5,
				ServiceId = 5,
				CreatedAt = new DateTime(2025, 05, 21),
			},
			new Database.CompanyService
			{
				CompanyId = 6,
				ServiceId = 2,
				CreatedAt = new DateTime(2025, 05, 21),
			},
			new Database.CompanyService
			{
				CompanyId = 6,
				ServiceId = 6,
				CreatedAt = new DateTime(2025, 05, 21),
			},
			new Database.CompanyService
			{
				CompanyId = 7,
				ServiceId = 2,
				CreatedAt = new DateTime(2025, 05, 21),
			},
			new Database.CompanyService
			{
				CompanyId = 7,
				ServiceId = 1,
				CreatedAt = new DateTime(2025, 05, 21),
			}



			);
		modelBuilder.Entity<Database.CompanyRole>().HasData(
		   new Database.CompanyRole
		   {
			   CompanyRoleId = 1,
			   CompanyId = 1,
			   RoleName = "Vlasnik",


		   },
			new Database.CompanyRole
			{
				CompanyRoleId = 2,
				CompanyId = 1,
				RoleName = "Terenac",


			},
			 new Database.CompanyRole
			 {
				 CompanyRoleId = 3,
				 CompanyId = 2,
				 RoleName = "Administrator",


			 },
			 new Database.CompanyRole
			 {
				 CompanyRoleId = 4,
				 CompanyId = 2,
				 RoleName = "Terenac"
			 }
		   );
		modelBuilder.Entity<Database.CompanyEmployee>().HasData(
            new Database.CompanyEmployee
            {
                CompanyEmployeeId = 1,
                CompanyId = 1,
                UserId = 6,
                CompanyRoleId = 2,
                DateJoined = new DateTime(2025,05,21),
                IsDeleted = false,
                IsApplicant = false,
                IsOwner = false,
            },
            new Database.CompanyEmployee
            {
                CompanyEmployeeId = 2,
                CompanyId = 1,
                UserId = 5,
                CompanyRoleId = 1,
                DateJoined = new DateTime(2025,05,21),
                IsDeleted = false,
                IsApplicant = false,
                IsOwner = true,
            },
			   new Database.CompanyEmployee
			   {
				   CompanyEmployeeId = 3,
				   CompanyId = 3,
				   UserId = 5,
				   CompanyRoleId = 1,
				   DateJoined = new DateTime(2025,05,21),
				   IsDeleted = false,
				   IsApplicant = false,
				   IsOwner = true,
			   },
				 new Database.CompanyEmployee
				 {
					 CompanyEmployeeId = 4,
					 CompanyId = 5,
					 UserId = 5,
					 CompanyRoleId = 1,
					 DateJoined = new DateTime(2025,05,21),
					 IsDeleted = false,
					 IsApplicant = false,
					 IsOwner = true,
				 },
				  new Database.CompanyEmployee
				  {
					  CompanyEmployeeId = 5,
					  CompanyId = 7,
					  UserId = 5,
					  CompanyRoleId = 1,
					  DateJoined = new DateTime(2025,05,21),
					  IsDeleted = false,
					  IsApplicant = false,
					  IsOwner = true,
				  },
			 new Database.CompanyEmployee
             {
                 CompanyEmployeeId = 6,
                 CompanyId = 2,
                 UserId = 15,
                 CompanyRoleId = 3,
                 DateJoined = new DateTime(2025,05,21),
                 IsDeleted = false,
                 IsApplicant = false,
                 IsOwner = true,
             },

			  new Database.CompanyEmployee
			  {
				  CompanyEmployeeId = 7,
				  CompanyId = 4,
				  UserId = 15,
				  CompanyRoleId = 3,
				  DateJoined = new DateTime(2025,05,21),
				  IsDeleted = false,
				  IsApplicant = false,
				  IsOwner = true,
			  },
				new Database.CompanyEmployee
				{
					CompanyEmployeeId = 8,
					CompanyId = 6,
					UserId = 15,
					CompanyRoleId = 3,
					DateJoined = new DateTime(2025,05,21),
					IsDeleted = false,
					IsApplicant = false,
					IsOwner = true,
				},
			  new Database.CompanyEmployee
              {
                  CompanyEmployeeId = 9,
                  CompanyId = 2,
                  UserId = 16,
                  CompanyRoleId = 2,
                  DateJoined = new DateTime(2025,05,21),
                  IsDeleted = false,
                  IsApplicant = false,
                  IsOwner = false,
              },
               new Database.CompanyEmployee
               {
                   CompanyEmployeeId = 10,
                   CompanyId = 1,
                   UserId = 16,
                   CompanyRoleId = 4,
                   DateJoined = new DateTime(2025,05,21),
                   IsDeleted = false,
                   IsApplicant = false,
                   IsOwner = false,
               },

                new Database.CompanyEmployee
                {
                    CompanyEmployeeId = 11,
                    CompanyId = 2,
                    UserId = 17,
                    CompanyRoleId = 2,
                    DateJoined = new DateTime(2025,05,21),
                    IsDeleted = false,
                    IsApplicant = false,
                    IsOwner = false,
                },
               new Database.CompanyEmployee
               {
                   CompanyEmployeeId = 12,
                   CompanyId = 1,
                   UserId = 17,
                   CompanyRoleId = 4,
                   DateJoined = new DateTime(2025,05,21),
                   IsDeleted = false,
                   IsApplicant = false,
                   IsOwner = false,
               },
               new Database.CompanyEmployee
               {
                   CompanyEmployeeId = 13,
                   CompanyId = 2,
                   UserId = 18,
                   CompanyRoleId = 2,
                   DateJoined = new DateTime(2025,05,21),
                   IsDeleted = false,
                   IsApplicant = false,
                   IsOwner = false,
               },
               new Database.CompanyEmployee
               {
                   CompanyEmployeeId = 14,
                   CompanyId = 1,
                   UserId = 18,
                   CompanyRoleId = 4,
                   DateJoined = new DateTime(2025,05,21),
                   IsDeleted = false,
                   IsApplicant = false,
                   IsOwner = false,
               },
               new Database.CompanyEmployee
               {
                   CompanyEmployeeId = 15,
                   CompanyId = 2,
                   UserId = 19,
                   CompanyRoleId = 2,
                   DateJoined = new DateTime(2025,05,21),
                   IsDeleted = false,
                   IsApplicant = false,
                   IsOwner = false,
               },
               new Database.CompanyEmployee
               {
                   CompanyEmployeeId = 16,
                   CompanyId = 1,
                   UserId = 19,
                   CompanyRoleId = 4,
                   DateJoined = new DateTime(2025,05,21),
                   IsDeleted = false,
                   IsApplicant = false,
                   IsOwner = false,
               },
                new Database.CompanyEmployee
                {
                    CompanyEmployeeId = 17,
                    CompanyId = 2,
                    UserId = 20,
                    CompanyRoleId = 2,
                    DateJoined = new DateTime(2025,05,21),
                    IsDeleted = false,
                    IsApplicant = false,
                    IsOwner = false,
                },
               new Database.CompanyEmployee
               {
                   CompanyEmployeeId = 18,
                   CompanyId = 1,
                   UserId = 20,
                   CompanyRoleId = 4,
                   DateJoined = new DateTime(2025,05,21),
                   IsDeleted = false,
                   IsApplicant = false,
                   IsOwner = false,
               },
				new Database.CompanyEmployee
				{
					CompanyEmployeeId = 19,
					CompanyId = 3,
					UserId = 16,
					CompanyRoleId = null,
					DateJoined = new DateTime(2025,05,21),
					IsDeleted = false,
					IsApplicant = false,
					IsOwner = false,
				},
				 new Database.CompanyEmployee
				 {
					 CompanyEmployeeId = 20,
					 CompanyId = 4,
					 UserId = 20,
					 CompanyRoleId = null,
					 DateJoined = new DateTime(2025,05,21),
					 IsDeleted = false,
					 IsApplicant = false,
					 IsOwner = false,
				 },
				   new Database.CompanyEmployee
				   {
					   CompanyEmployeeId = 21,
					   CompanyId = 5,
					   UserId = 20,
					   CompanyRoleId = null,
					   DateJoined = new DateTime(2025,05,21),
					   IsDeleted = false,
					   IsApplicant = false,
					   IsOwner = false,
				   },
					new Database.CompanyEmployee
					{
						CompanyEmployeeId = 22,
						CompanyId = 6,
						UserId = 18,
						CompanyRoleId = null,
						DateJoined = new DateTime(2025,05,21),
						IsDeleted = false,
						IsApplicant = false,
						IsOwner = false,
					},
					 new Database.CompanyEmployee
					 {
						 CompanyEmployeeId = 23,
						 CompanyId = 1,
						 UserId = 7,
						 CompanyRoleId = 2,
						 DateJoined = new DateTime(2025,05,21),
						 IsDeleted = false,
						 IsApplicant = false,
						 IsOwner = false,
					 }


			);
       
        modelBuilder.Entity<Database.Store>().HasData(
            new Database.Store
            {
                StoreId = 1,
                StoreName = "Elektro Materijal",
                Address = "Mostar, b.b.",
                LocationId = 1,
                UserId = 7,
                IsDeleted = false,
                IsApplicant = false,
                Description = "Prodaja elektro materijala i alata.",
                Image = null,

            },
            new Database.Store
            {
                StoreId = 2,
                StoreName = "Keramik Stop",
                Address = "Mostar, b.b.",
                LocationId = 1,
                UserId = 8,
                IsDeleted = false,
                IsApplicant = false,
                Description = "Prodaja keramike",
                Image = null,

            },
            new Database.Store
            {
                StoreId = 3,
                StoreName = "Građevinski Materijal",
                Address = "Sarajevo, b.b.",
                LocationId = 2,
                UserId = 3,
                IsDeleted = false,
                IsApplicant = false,
                Description = "Prodaja građevinskog materijala i alata.",
                Image = null,
            },
            new Database.Store
            {
                StoreId = 4,
                StoreName = "Moleraj Plus",
                Address = "Sarajevo, b.b.",
                LocationId = 2,
                UserId = 3,
                IsDeleted = false,
                IsApplicant = false,
                Description = "Prodaja boja i lakova za molerske radove.",
                Image = null,
            }
            );
		modelBuilder.Entity<Database.Product>().HasData(
		   new Database.Product
		   {
			   ProductId = 1,
			   ProductName = "Produžni kabl 5m",
			   Price = 25.00m,
			   StoreId = 1,
			   IsDeleted = false,
			   Image = null,
			   ProductDescription = " Produžni kabl dužine 5 metara, idealan za kućnu i kancelarijsku upotrebu."

		   },
			new Database.Product
			{
				ProductId = 2,
				ProductName = "Ethernet kabal 20m",
				Price = 45.00m,
				StoreId = 1,
				IsDeleted = false,
				Image = null,
				ProductDescription = "Visokokvalitetni Ethernet kabal dužine 20 metara za pouzdanu mrežnu povezanost.",

			},
			new Database.Product
			{
				ProductId = 3,
				ProductName = "Prekidač naizmenične struje",
				Price = 15.00m,
				StoreId = 1,
				IsDeleted = false,
				Image = null,
				ProductDescription = "Standardni prekidač naizmenične struje za kućnu i industrijsku upotrebu.",
			},
			new Database.Product
			{
				ProductId = 4,
				ProductName = "LED žarulja 9W",
				Price = 10.00m,
				StoreId = 1,
				IsDeleted = false,
				Image = null,
				ProductDescription = "Energetski efikasna LED žarulja snage 9W, pruža jarko svetlo uz nisku potrošnju energije."

			},
			new Database.Product
			{
				ProductId = 5,
				ProductName = "Ravna keramika 30x30cm",
				Price = 20.00m,
				StoreId = 2,
				IsDeleted = false,
				Image = null,
				ProductDescription = "Visokokvalitetna ravna keramika dimenzija 30x30cm, idealna za podove i zidove.",
			},
			 new Database.Product
			 {
				 ProductId = 6,
				 ProductName = "Keramičke pločice 20x20cm",
				 Price = 15.00m,
				 StoreId = 2,
				 IsDeleted = false,
				 Image = null,
				 ProductDescription = "Izdržljive keramičke pločice dimenzija 20x20cm, pogodne za različite površine.",
			 },
			 new Database.Product
			 {
				 ProductId = 7,
				 ProductName = "Fug masa 5kg",
				 Price = 30.00m,
				 StoreId = 2,
				 IsDeleted = false,
				 Image = null,
				 ProductDescription = "Kvalitetna fug masa u pakovanju od 5kg, idealna za popunjavanje spojeva između pločica."
			 },
			 new Database.Product
			 {
				 ProductId = 8,
				 ProductName = "Ljepilo za keramiku 10kg",
				 Price = 50.00m,
				 StoreId = 2,
				 IsDeleted = false,
				 Image = null,
				 ProductDescription = "Snažno ljepilo za keramiku u pakovanju od 10kg, pruža čvrsto prizemljivanje pločica na različite površine."
			 },
			 new Database.Product
			 {
				 ProductId = 9,
				 ProductName = "Cement 25kg",
				 Price = 8.00m,
				 StoreId = 3,
				 IsDeleted = false,
				 Image = null,
				 ProductDescription = "Visokokvalitetni cement u pakovanju od 25kg, pogodan za različite građevinske radove."
			 },
			 new Database.Product
			 {
				 ProductId = 10,
				 ProductName = "Pijesak 50kg",
				 Price = 5.00m,
				 StoreId = 3,
				 IsDeleted = false,
				 Image = null,
				 ProductDescription = "Fini pijesak u pakovanju od 50kg, idealan za malterisanje i druge građevinske primjene."
			 },
			 new Database.Product
			 {
				 ProductId = 11,
				 ProductName = "Malter 30kg",
				 Price = 12.00m,
				 StoreId = 3,
				 IsDeleted = false,
				 Image = null,
				 ProductDescription = "Kvalitetan malter u pakovanju od 30kg, pogodan za unutrašnje i vanjske zidove."
			 },
			 new Database.Product
			 {
				 ProductId = 12,
				 ProductName = "Boja za zidove 5L",
				 Price = 25.00m,
				 StoreId = 4,
				 IsDeleted = false,
				 Image = null,
				 ProductDescription = "Unutrašnja boja za zidove u pakovanju od 5L, dostupna u različitim bojama."
			 },
			  new Database.Product
			  {
				  ProductId = 13,
				  ProductName = "Lak za drvo 1L",
				  Price = 15.00m,
				  StoreId = 4,
				  IsDeleted = false,
				  Image = null,
				  ProductDescription = "Visokokvalitetni lak za drvo u pakovanju od 1L, pruža zaštitu i sjaj drvenim površinama."
			  },
			  new Database.Product
			  {
				  ProductId = 14,
				  ProductName = "Valjak za boju",
				  Price = 7.00m,
				  StoreId = 4,
				  IsDeleted = false,
				  Image = null,
				  ProductDescription = "Kvalitetan valjak za boju, idealan za brzo i ravnomerno nanošenje boje na zidove."
			  },
			  new Database.Product
			  {
				  ProductId = 15,
				  ProductName = "Četka za boju",
				  Price = 5.00m,
				  StoreId = 4,
				  IsDeleted = false,
				  Image = null,
				  ProductDescription = "Izdržljiva četka za boju, pogodna za precizno nanošenje boje na različite površine."
			  },
			  new Database.Product
			  {
				  ProductId = 16,
				  ProductName = "Kanta za boju 10L",
				  Price = 40.00m,
				  StoreId = 4,
				  IsDeleted = false,
				  Image = null,
				  ProductDescription = "Velika kanta za boju u pakovanju od 10L, idealna za veće projekte farbanja."
			  }

		   );

		modelBuilder.Entity<Database.ProductsService>().HasData(
             new Database.ProductsService
             {
                 ProductId = 1,
                 ServiceId = 2,
                 CreatedAt = new DateTime(2025,05,21)
             },
             new Database.ProductsService
             {
                 ProductId = 2,
                 ServiceId = 2,
                 CreatedAt = new DateTime(2025,05,21)
             },
             new Database.ProductsService
             {
                 ProductId = 3,
                 ServiceId = 2,
                 CreatedAt = new DateTime(2025,05,21)
             },
             new Database.ProductsService
             {
                 ProductId = 4,
                 ServiceId = 2,
                 CreatedAt = new DateTime(2025,05,21)
             },
             new Database.ProductsService
             {
                 ProductId = 5,
                 ServiceId = 1,
                 CreatedAt = new DateTime(2025,05,21)
             },
             new Database.ProductsService
             {
                 ProductId = 6,
                 ServiceId = 1,
                 CreatedAt = new DateTime(2025,05,21)
             },
             new Database.ProductsService
             {
                 ProductId = 7,
                 ServiceId = 1,
                 CreatedAt = new DateTime(2025,05,21)
             },
             new Database.ProductsService
             {
                 ProductId = 8,
                 ServiceId = 1,
                 CreatedAt = new DateTime(2025,05,21)
             },
             new Database.ProductsService
             {
                 ProductId = 9,
                 ServiceId = 6,
                 CreatedAt = new DateTime(2025,05,21)
             },
             new Database.ProductsService
             {
                 ProductId = 10,
                 ServiceId = 6,
                 CreatedAt = new DateTime(2025,05,21)
             },
             new Database.ProductsService
             {
                 ProductId = 11,
                 ServiceId = 6,
                 CreatedAt = new DateTime(2025,05,21)
             },
             new Database.ProductsService
             {
                 ProductId = 12,
                 ServiceId = 3,
                 CreatedAt = new DateTime(2025,05,21)
             },
             new Database.ProductsService
             {
                 ProductId = 13,
                 ServiceId = 3,
                 CreatedAt = new DateTime(2025,05,21)
             },
             new Database.ProductsService
             {
                 ProductId = 14,
                 ServiceId = 3,
                 CreatedAt = new DateTime(2025,05,21)
             },
             new Database.ProductsService
             {
                 ProductId = 15,
                 ServiceId = 3,
                 CreatedAt = new DateTime(2025,05,21)
             },
             new Database.ProductsService
             {
                 ProductId = 16,
                 ServiceId = 3,
                 CreatedAt = new DateTime(2025,05,21)
             }

             );
		

		modelBuilder.Entity<Database.Order>().HasData(
            new Database.Order
            {
                OrderId = 1,
                UserId = 2,
                CreatedAt = new DateTime(2025,05,21),
                IsCancelled = false,
                IsShipped = false,
                OrderNumber = 20124,


            },
            new Database.Order
            {
                OrderId = 2,
                UserId = 3,
                CreatedAt = new DateTime(2025,05,21),
                IsCancelled = false,
                IsShipped = false,
                OrderNumber = 20125,
            },
            new Database.Order
            {
                OrderId = 3,
                UserId = 2,
                CreatedAt = new DateTime(2025,05,21),
                IsCancelled = false,
                IsShipped = false,
                OrderNumber = 20126,
            },
            new Database.Order
            {
                OrderId = 4,
                UserId = 3,
                CreatedAt = new DateTime(2025,05,21),
                IsCancelled = false,
                IsShipped = false,
                OrderNumber = 20127,
            }
        

            );
        modelBuilder.Entity<Database.OrderItem>().HasData(
            new Database.OrderItem
            {
                OrderItemsId = 1,
                OrderId = 1,
                ProductId = 1,
                StoreId = 1,
                Quantity = 2,



            },
            new Database.OrderItem
            {
                OrderItemsId = 2,
                OrderId = 1,
                ProductId = 4,
                StoreId = 1,
                Quantity = 5,
            },
            new Database.OrderItem
            {
                OrderItemsId = 3,
                OrderId = 2,
                ProductId = 2,
                StoreId = 1,
                Quantity = 1,
            },
            new Database.OrderItem
            {
                OrderItemsId = 4,
                OrderId = 2,
                ProductId = 3,
                StoreId = 1,
                Quantity = 3,
            },
            new Database.OrderItem
            {
                OrderItemsId = 5,
                OrderId = 3,
                ProductId = 5,
                StoreId = 2,
                Quantity = 4,
            },
            new Database.OrderItem
            {
                OrderItemsId = 6,
                OrderId = 3,
                ProductId = 6,
                StoreId = 2,
                Quantity = 2,
            },
            new Database.OrderItem
            {
                OrderItemsId = 7,
                OrderId = 4,
                ProductId = 7,
                StoreId = 2,
                Quantity = 1,
            },
            new Database.OrderItem
            {
                OrderItemsId = 8,
                OrderId = 4,
                ProductId = 8,
                StoreId = 2,
                Quantity = 3,
            }
        


        );
        modelBuilder.Entity<Database.Job>().HasData(
            new Database.Job
            {
                JobId = 1,
                JobTitle = "Popravka elektroinstalacija",
                JobDescription="Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.",
                FreelancerId = 4,
                UserId=2,
                EndEstimate=new TimeOnly(18,0),
                StartEstimate=new TimeOnly(10,0),
                IsDeleted=false,
                IsDeletedWorker=false,
                Image=null,
                IsEdited=false,
                IsWorkerEdited=false,
                IsRated=true,
                IsInvoiced=true,
                IsTenderFinalized=false,
                JobDate= new DateTime(2025,05,21),
                JobStatus="finished"
                
                

			},
			new Database.Job
			{
				JobId = 2,
				JobTitle = "Postavljanje keramike",
				JobDescription = "Potrebno postavljanje keramike na balkonu",
				FreelancerId= 9,
				UserId = 2,
				EndEstimate = new TimeOnly(18, 0),
				StartEstimate = new TimeOnly(10, 0),
				IsDeleted = false,
				IsDeletedWorker = false,
				Image = null,
				IsEdited = false,
				IsWorkerEdited = false,
				IsRated = true,
				IsInvoiced = true,
				IsTenderFinalized = false,
				JobDate = new DateTime(2025,05,21),
				JobStatus = "finished"



			},
			new Database.Job
			{
				JobId = 3,
				JobTitle = "Popravka elektroinstalacija",
				JobDescription = "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.",
				FreelancerId = 10,
				UserId = 2,
				EndEstimate = new TimeOnly(18, 0),
				StartEstimate = new TimeOnly(10, 0),
				IsDeleted = false,
				IsDeletedWorker = false,
				Image = null,
				IsEdited = false,
				IsWorkerEdited = false,
				IsRated = true,
				IsInvoiced = true,
				IsTenderFinalized = false,
				JobDate = new DateTime(2025,05,21),
				JobStatus = "finished"



			},
			new Database.Job
			{
				JobId = 4,
				JobTitle = "Postavljanje keramike",
				JobDescription = "Potrebno postavljanje keramike na balkonu",
				FreelancerId = 4,
				UserId = 3,
				DateFinished = new DateTime(2025, 8, 24),
				IsDeleted = false,
				IsDeletedWorker = false,
				Image = null,
				IsEdited = false,
				IsWorkerEdited = false,
				IsRated = true,
				IsInvoiced = true,
				IsTenderFinalized = false,
				JobDate = new DateTime(2025,05,21),
				JobStatus = "finished"



			},
			new Database.Job
			{
				JobId = 5,
				JobTitle = "Popravka elektroinstalacija",
				JobDescription = "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.",
				FreelancerId = 11,
				UserId = 3,
				EndEstimate = new TimeOnly(18, 0),
				StartEstimate = new TimeOnly(10, 0),
				IsDeleted = false,
				IsDeletedWorker = false,
				Image = null,
				IsEdited = false,
				IsWorkerEdited = false,
				IsRated = true,
				IsInvoiced = true,
				IsTenderFinalized = false,
				JobDate = new DateTime(2025,05,21),
				JobStatus = "finished"



			},
			new Database.Job
			{
				JobId = 6,
				JobTitle = "Postavljanje keramike",
				JobDescription = "Potrebno postavljanje keramike na balkonu",
				FreelancerId = 12,
				UserId = 3,
				DateFinished = new DateTime(2025, 8, 24),
				IsDeleted = false,
				IsDeletedWorker = false,
				Image = null,
				IsEdited = false,
				IsWorkerEdited = false,
				IsRated = true,
				IsInvoiced = true,
				IsTenderFinalized = false,
				JobDate = new DateTime(2025,05,21),
				JobStatus = "finished"



			},
            new Database.Job
            {
                JobId = 7,
                JobTitle = "Molerski radovi u kući",
                JobDescription = "Potrebno krečenje i farbanje zidova u kući, uključujući pripremu površina i završne radove.",
                FreelancerId = 9,
                UserId = 21,
                EndEstimate = new TimeOnly(17, 0),
                StartEstimate = new TimeOnly(9, 0),
                IsDeleted = false,
                IsDeletedWorker = false,
                Image = null,
                IsEdited = false,
                IsWorkerEdited = false,
                IsRated = true,
                IsInvoiced = true,
                IsTenderFinalized = false,
                JobDate = new DateTime(2025,05,21),
                JobStatus = "finished"
			},
            new Database.Job
            {
                JobId = 8,
                JobTitle = "Popravka krova",
                JobDescription = "Potrebna hitna popravka krova zbog curenja vode, uključujući zamjenu oštećenih delova i hidroizolaciju.",
                FreelancerId = 11,
                UserId = 21,
                EndEstimate = new TimeOnly(16, 0),
                StartEstimate = new TimeOnly(8, 0),
                IsDeleted = false,
                IsDeletedWorker = false,
                Image = null,
                IsEdited = false,
                IsWorkerEdited = false,
                IsRated = true,
                IsInvoiced = true,
                IsTenderFinalized = false,
                JobDate = new DateTime(2025,05,21),
                JobStatus = "finished"
			},
            new Database.Job
            {
                JobId = 9,
                JobTitle = "Instalacija solarnih panela",
                JobDescription = "Potrebna instalacija solarnih panela na krovu kuće, uključujući montažu i povezivanje sa električnim sistemom.",
                FreelancerId = 13,
                UserId = 21,
                EndEstimate = new TimeOnly(15, 0),
                StartEstimate = new TimeOnly(7, 0),
                IsDeleted = false,
                IsDeletedWorker = false,
                Image = null,
                IsEdited = false,
                IsWorkerEdited = false,
                IsRated = true,
                IsInvoiced = true,
                IsTenderFinalized = false,
                JobDate = new DateTime(2025,05,21),
                JobStatus = "finished"
			},
			 new Database.Job
			 {
				 JobId = 10,
				 JobTitle = "Popravka elektroinstalacija",
				 JobDescription = "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.",
				 CompanyId = 1,
				 UserId = 2,
				 DateFinished= new DateTime(2025, 8, 24),
				 IsDeleted = false,
				 IsDeletedWorker = false,
				 Image = null,
				 IsEdited = false,
				 IsWorkerEdited = false,
				 IsRated = true,
				 IsInvoiced = true,
				 IsTenderFinalized = false,
				 JobDate = new DateTime(2025,05,21),
				 JobStatus = "finished"



			 },
			  new Database.Job
			  {
				  JobId = 11,
				  JobTitle = "Popravka elektroinstalacija",
				  JobDescription = "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.",
				  CompanyId = 2,
				  UserId = 2,
				  DateFinished = new DateTime(2025, 8, 24),
				  IsDeleted = false,
				  IsDeletedWorker = false,
				  Image = null,
				  IsEdited = false,
				  IsWorkerEdited = false,
				  IsRated = true,
				  IsInvoiced = true,
				  IsTenderFinalized = false,
				  JobDate = new DateTime(2025,05,21),
				  JobStatus = "finished"



			  },
			   new Database.Job
			   {
				   JobId = 12,
				   JobTitle = "Popravka elektroinstalacija",
				   JobDescription = "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.",
				   CompanyId = 4,
				   UserId = 2,
				   DateFinished = new DateTime(2025, 8, 24),
				   IsDeleted = false,
				   IsDeletedWorker = false,
				   Image = null,
				   IsEdited = false,
				   IsWorkerEdited = false,
				   IsRated = true,
				   IsInvoiced = true,
				   IsTenderFinalized = false,
				   JobDate = new DateTime(2025,05,21),
				   JobStatus = "finished"



			   },
				new Database.Job
				{
					JobId = 13,
					JobTitle = "Popravka elektroinstalacija",
					JobDescription = "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.",
					CompanyId = 1,
					UserId = 3,
					DateFinished = new DateTime(2025, 8, 24),
					IsDeleted = false,
					IsDeletedWorker = false,
					Image = null,
					IsEdited = false,
					IsWorkerEdited = false,
					IsRated = true,
					IsInvoiced = true,
					IsTenderFinalized = false,
					JobDate = new DateTime(2025,05,21),
					JobStatus = "finished"



				},
				new Database.Job
				{
					JobId = 14,
					JobTitle = "Popravka elektroinstalacija",
					JobDescription = "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.",
					CompanyId = 5,
					UserId = 3,
					DateFinished = new DateTime(2025, 8, 24),
					IsDeleted = false,
					IsDeletedWorker = false,
					Image = null,
					IsEdited = false,
					IsWorkerEdited = false,
					IsRated = true,
					IsInvoiced = true,
					IsTenderFinalized = false,
					JobDate = new DateTime(2025,05,21),
					JobStatus = "finished"



				},
				new Database.Job
				{
					JobId = 15,
					JobTitle = "Popravka elektroinstalacija",
					JobDescription = "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.",
					CompanyId = 7,
					UserId = 3,
					DateFinished = new DateTime(2025, 8, 24),
					IsDeleted = false,
					IsDeletedWorker = false,
					Image = null,
					IsEdited = false,
					IsWorkerEdited = false,
					IsRated = true,
					IsInvoiced = true,
					IsTenderFinalized = false,
					JobDate = new DateTime(2025,05,21),
					JobStatus = "finished"



				},
					new Database.Job
					{
						JobId = 16,
						JobTitle = "Popravka elektroinstalacija",
						JobDescription = "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.",
						CompanyId = 1,
						UserId = 21,
						DateFinished = new DateTime(2025, 8, 24),
						IsDeleted = false,
						IsDeletedWorker = false,
						Image = null,
						IsEdited = false,
						IsWorkerEdited = false,
						IsRated = true,
						IsInvoiced = true,
						IsTenderFinalized = false,
						JobDate = new DateTime(2025,05,21),
						JobStatus = "finished"



					},
					new Database.Job
					{
						JobId = 17,
						JobTitle = "Popravka elektroinstalacija",
						JobDescription = "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.",
						CompanyId = 2,
						UserId = 21,
						DateFinished = new DateTime(2025, 8, 24),
						IsDeleted = false,
						IsDeletedWorker = false,
						Image = null,
						IsEdited = false,
						IsWorkerEdited = false,
						IsRated = true,
						IsInvoiced = true,
						IsTenderFinalized = false,
						JobDate = new DateTime(2025,05,21),
						JobStatus = "finished"



					},
					new Database.Job
					{
						JobId = 18,
						JobTitle = "Popravka elektroinstalacija",
						JobDescription = "Potrebna popravka elektroinstalacija u stanu, uključujući zamjenu prekidača i utičnica.",
						CompanyId = 4,
						UserId = 21,
						DateFinished = new DateTime(2025, 8, 24),
						IsDeleted = false,
						IsDeletedWorker = false,
						Image = null,
						IsEdited = false,
						IsWorkerEdited = false,
						IsRated = true,
						IsInvoiced = true,
						IsTenderFinalized = false,
						JobDate = new DateTime(2025,05,21),
						JobStatus = "finished"
					}

		);
        modelBuilder.Entity<Database.JobsService>().HasData(
            new Database.JobsService
            {
                JobId = 1,
                ServiceId = 2,
                CreatedAt = new DateTime(2025,05,21)
            },
            new Database.JobsService
            {
                 JobId = 2,
                 ServiceId = 1,
                 CreatedAt = new DateTime(2025,05,21)
			},
            new Database.JobsService
            {
                JobId = 3,
                ServiceId = 2,
                CreatedAt = new DateTime(2025,05,21)
            },
            new Database.JobsService
            {
                JobId = 4,
                ServiceId = 1,
                CreatedAt = new DateTime(2025,05,21)
            },
            new Database.JobsService
            {
                JobId = 5,
                ServiceId = 2,
                CreatedAt = new DateTime(2025,05,21)
            },
            new Database.JobsService
            {
                JobId = 6,
                ServiceId = 1,
                CreatedAt = new DateTime(2025,05,21)
			},
            new Database.JobsService
            {
                JobId = 7,
                ServiceId = 3,
                CreatedAt = new DateTime(2025,05,21)
            },
            new Database.JobsService
            {
                JobId = 8,
                ServiceId = 5,
                CreatedAt = new DateTime(2025,05,21)
            },
            new Database.JobsService
            {
                JobId = 9,
                ServiceId = 4,
                CreatedAt = new DateTime(2025,05,21)
			},
            new Database.JobsService
            {
                JobId = 10,
                ServiceId = 2,
                CreatedAt = new DateTime(2025,05,21)
            },
            new Database.JobsService
            {
                JobId = 11,
                ServiceId = 2,
                CreatedAt = new DateTime(2025,05,21)
            },
            new Database.JobsService
            {
                JobId = 12,
                ServiceId = 2,
                CreatedAt = new DateTime(2025,05,21)
            },
            new Database.JobsService
            {
                JobId = 13,
                ServiceId = 2,
                CreatedAt = new DateTime(2025,05,21)
            },
            new Database.JobsService
            {
                JobId = 14,
                ServiceId = 2,
                CreatedAt = new DateTime(2025,05,21)
            },
            new Database.JobsService
            {
                JobId = 15,
                ServiceId = 2,
                CreatedAt = new DateTime(2025,05,21)
            },
            new Database.JobsService
            {
                JobId = 16,
                ServiceId = 2,
                CreatedAt = new DateTime(2025,05,21)
            },
            new Database.JobsService
            {
                JobId = 17,
                ServiceId = 2,
                CreatedAt = new DateTime(2025,05,21)
            },
            new Database.JobsService
            {
                JobId = 18,
                ServiceId = 2,
                CreatedAt = new DateTime(2025,05,21)
			}
		);
		modelBuilder.Entity<Database.UserRating>().HasData(
		   new Database.UserRating { UserRatingId = 1, FreelancerId = 4, UserId = 2, Rating = 5, JobId = 1 },
	       new Database.UserRating { UserRatingId = 2, FreelancerId = 9, UserId = 2, Rating = 4, JobId = 2 },
	       new Database.UserRating { UserRatingId = 3, FreelancerId = 10, UserId = 2, Rating = 3, JobId = 3 },


	       new Database.UserRating { UserRatingId = 4, FreelancerId = 4, UserId = 3, Rating = 4, JobId = 4 },
	       new Database.UserRating { UserRatingId = 5, FreelancerId = 11, UserId = 3, Rating = 5, JobId = 5 },
	       new Database.UserRating { UserRatingId = 6, FreelancerId = 12, UserId = 3, Rating = 2, JobId = 6 },

	
	       new Database.UserRating { UserRatingId = 7, FreelancerId = 9, UserId = 21, Rating = 5, JobId = 7 },
	       new Database.UserRating { UserRatingId = 8, FreelancerId = 11, UserId = 21, Rating = 4, JobId = 8 },
	       new Database.UserRating { UserRatingId = 9, FreelancerId = 13, UserId = 21, Rating = 3, JobId = 9 },



		   new Database.UserRating { UserRatingId = 10, CompanyId = 1, UserId = 2, Rating = 5, JobId = 1 },
		   new Database.UserRating { UserRatingId = 11, CompanyId = 2, UserId = 2, Rating = 4, JobId = 2 },
		   new Database.UserRating { UserRatingId = 12, CompanyId = 4, UserId = 2, Rating = 3, JobId = 3 },


		   new Database.UserRating { UserRatingId = 13, CompanyId = 1, UserId = 3, Rating = 4, JobId = 4 },
		   new Database.UserRating { UserRatingId = 14, CompanyId = 5, UserId = 3, Rating = 5, JobId = 5 },
		   new Database.UserRating { UserRatingId = 15, CompanyId = 7, UserId = 3, Rating = 2, JobId = 6 },


		   new Database.UserRating { UserRatingId = 16, CompanyId = 1, UserId = 21, Rating = 5, JobId = 7 },
		   new Database.UserRating { UserRatingId = 17, CompanyId = 2, UserId = 21, Rating = 4, JobId = 8 },
		   new Database.UserRating { UserRatingId = 18, CompanyId = 4, UserId = 21, Rating = 3, JobId = 9 }


		);
    }
}
