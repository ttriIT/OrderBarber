using Microsoft.EntityFrameworkCore;
using appcattoc.Models.Entities;
using appcattoc.Models.Enums;

namespace appcattoc.Data;

public class BarberDbContext : DbContext
{
    public BarberDbContext(DbContextOptions<BarberDbContext> options)
        : base(options)
    {
    }

    // ===== CORE ENTITIES =====
    public DbSet<User> Users { get; set; }
    public DbSet<Shop> Shops { get; set; }
    public DbSet<StaffProfile> StaffProfiles { get; set; }
    public DbSet<Service> Services { get; set; }
    public DbSet<Appointment> Appointments { get; set; }
    public DbSet<Invoice> Invoices { get; set; }
    public DbSet<ChatSession> ChatSessions { get; set; }
    public DbSet<ChatMessage> ChatMessages { get; set; }
    public DbSet<Review> Reviews { get; set; }
    public DbSet<Notification> Notifications { get; set; }
    public DbSet<RefreshToken> RefreshTokens { get; set; }

    // ===== MERGE FROM nhom10lor =====
    public DbSet<Barber> Barbers { get; set; }
    public DbSet<Booking> Bookings { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // ===== User =====
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasIndex(e => e.Username).IsUnique();
            entity.HasIndex(e => e.Phone);
            entity.Property(e => e.Role).HasConversion<int>();
        });

        // ===== Shop =====
        modelBuilder.Entity<Shop>(entity =>
        {
            entity.HasOne(s => s.Manager)
                .WithMany(u => u.ManagedShops)
                .HasForeignKey(s => s.ManagerId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasIndex(e => e.Location);
        });

        // ===== StaffProfile =====
        modelBuilder.Entity<StaffProfile>(entity =>
        {
            entity.HasOne(sp => sp.User)
                .WithOne(u => u.StaffProfile)
                .HasForeignKey<StaffProfile>(sp => sp.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(sp => sp.Shop)
                .WithMany(s => s.StaffProfiles)
                .HasForeignKey(sp => sp.ShopId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasIndex(e => new { e.UserId, e.ShopId }).IsUnique();
        });

        // ===== Service =====
        modelBuilder.Entity<Service>(entity =>
        {
            entity.HasOne(s => s.Shop)
                .WithMany(sh => sh.Services)
                .HasForeignKey(s => s.ShopId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasIndex(e => e.ShopId);
        });

        // ===== Appointment =====
        modelBuilder.Entity<Appointment>(entity =>
        {
            entity.HasOne(a => a.Customer)
                .WithMany(u => u.CustomerAppointments)
                .HasForeignKey(a => a.CustomerId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(a => a.Staff)
                .WithMany(sp => sp.Appointments)
                .HasForeignKey(a => a.StaffId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(a => a.Service)
                .WithMany(s => s.Appointments)
                .HasForeignKey(a => a.ServiceId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.Property(e => e.Status).HasConversion<int>();

            entity.HasIndex(e => new { e.StaffId, e.StartTime, e.EndTime });
            entity.HasIndex(e => new { e.CustomerId, e.StartTime });
        });

        // ===== Invoice =====
        modelBuilder.Entity<Invoice>(entity =>
        {
            entity.HasOne(i => i.Appointment)
                .WithOne(a => a.Invoice)
                .HasForeignKey<Invoice>(i => i.AppointmentId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(i => i.CreatedByStaff)
                .WithMany()
                .HasForeignKey(i => i.CreatedByStaffId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.Property(e => e.PaymentMethod).HasConversion<int>();
            entity.HasIndex(e => e.CreatedAt);
        });

        // ===== ChatSession =====
        modelBuilder.Entity<ChatSession>(entity =>
        {
            entity.HasOne(cs => cs.User1)
                .WithMany()
                .HasForeignKey(cs => cs.User1_Id)
                .OnDelete(DeleteBehavior.NoAction);

            entity.HasOne(cs => cs.User2)
                .WithMany()
                .HasForeignKey(cs => cs.User2_Id)
                .OnDelete(DeleteBehavior.NoAction);

            entity.Property(e => e.Type).HasConversion<int>();
            entity.HasIndex(e => new { e.User1_Id, e.User2_Id });
        });

        // ===== ChatMessage =====
        modelBuilder.Entity<ChatMessage>(entity =>
        {
            entity.HasOne(cm => cm.Session)
                .WithMany(cs => cs.Messages)
                .HasForeignKey(cm => cm.SessionId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(cm => cm.Sender)
                .WithMany()
                .HasForeignKey(cm => cm.SenderId)
                .OnDelete(DeleteBehavior.Restrict)
                .IsRequired(false);

            entity.HasIndex(e => new { e.SessionId, e.CreatedAt });
        });

        // ===== Review =====
        modelBuilder.Entity<Review>(entity =>
        {
            entity.HasOne(r => r.User)
                .WithMany()
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(r => r.Shop)
                .WithMany()
                .HasForeignKey(r => r.ShopId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(r => r.Staff)
                .WithMany()
                .HasForeignKey(r => r.StaffId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // ===== Notification =====
        modelBuilder.Entity<Notification>(entity =>
        {
            entity.HasOne(n => n.User)
                .WithMany()
                .HasForeignKey(n => n.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // ===== RefreshToken =====
        modelBuilder.Entity<RefreshToken>(entity =>
        {
            entity.HasOne(rt => rt.User)
                .WithMany()
                .HasForeignKey(rt => rt.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasIndex(e => e.Token).IsUnique();
            entity.HasIndex(e => e.UserId);
        });

        // ===== Barber =====
        modelBuilder.Entity<Barber>(entity =>
        {
            entity.HasMany(b => b.Bookings)
                .WithOne(bk => bk.Barber)
                .HasForeignKey(bk => bk.BarberId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // ===== Booking =====
        modelBuilder.Entity<Booking>(entity =>
        {
            entity.HasOne(b => b.Shop)
                .WithMany(s => s.Bookings)
                .HasForeignKey(b => b.ShopId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(b => b.Service)
                .WithMany()
                .HasForeignKey(b => b.ServiceId)
                .OnDelete(DeleteBehavior.Restrict);
        });
    }
}
