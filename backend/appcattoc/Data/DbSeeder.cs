using appcattoc.Models.Entities;
using appcattoc.Models.Enums;
using Microsoft.EntityFrameworkCore;

namespace appcattoc.Data;

public static class DbSeeder
{
    public static async Task SeedAsync(BarberDbContext context)
    {
        try
        {
            // Ensure database is created
            await context.Database.EnsureCreatedAsync();

            // Seed Users
            if (!await context.Users.AnyAsync())
            {
                var admin = new User
                {
                    Username = "admin",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("admin123"),
                    FullName = "System Administrator",
                    Phone = "0000000000",
                    Role = UserRole.Admin,
                    CreatedAt = DateTime.UtcNow
                };

                var customer = new User
                {
                    Username = "customer",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("123456"),
                    FullName = "Test Customer",
                    Phone = "0987654321",
                    Role = UserRole.Customer,
                    CreatedAt = DateTime.UtcNow
                };

                // Create a Staff User
                var staffUser = new User
                {
                    Username = "barber1",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("123456"),
                    FullName = "Tiến Đạt Barber",
                    Phone = "0901234567",
                    Role = UserRole.Staff,
                    CreatedAt = DateTime.UtcNow
                };

                // Create a Manager User
                var managerUser = new User
                {
                    Username = "manager1",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("123456"),
                    FullName = "Quản lý Shop",
                    Phone = "0909999999",
                    Role = UserRole.ShopManager, // Assuming UserRole enum has ShopManager or Manager
                    CreatedAt = DateTime.UtcNow
                };

                context.Users.AddRange(admin, customer, staffUser, managerUser);
                await context.SaveChangesAsync();

                // Seed Shop (Use ManagerId, Location instead of Address)
                var shop = new Shop
                {
                    Name = "Gentleman Barbershop",
                    Location = "123 Nguyễn Huệ, Quận 1, TP.HCM",
                    OpenTime = new TimeSpan(8, 0, 0),
                    CloseTime = new TimeSpan(21, 0, 0),
                    ManagerId = managerUser.Id,
                    CreatedAt = DateTime.UtcNow
                    // Missing in Shop: Phone, Description, ImageUrl, Rating, ReviewCount
                };
                context.Shops.Add(shop);
                await context.SaveChangesAsync();

                // Seed Staff Profile
                var staffProfile = new StaffProfile
                {
                    UserId = staffUser.Id,
                    ShopId = shop.Id,
                    SkillSet = "Cắt tóc, Cạo râu, Tạo kiểu",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                    // Missing in StaffProfile: Bio, Position, ExperienceYears, Rating, ReviewCount
                };
                context.StaffProfiles.Add(staffProfile);

                // Seed Services
                // Service: Name, Price, DurationMinutes, ImageUrl
                // Missing: Description, Category
                var services = new List<Service>
                {
                    new Service { Name = "Cắt tóc Classic", Price = 100000, DurationMinutes = 30, ImageUrl = "https://example.com/cut.jpg", ShopId = shop.Id },
                    new Service { Name = "Cạo râu khăn nóng", Price = 80000, DurationMinutes = 20, ImageUrl = "https://example.com/shave.jpg", ShopId = shop.Id },
                    new Service { Name = "Full Combo", Price = 250000, DurationMinutes = 60, ImageUrl = "https://example.com/combo.jpg", ShopId = shop.Id }
                };
                context.Services.AddRange(services);
                await context.SaveChangesAsync();
            }
        }
        catch (Exception)
        {
            // Log error or rethrow depending on needs. 
            // For now we just suppress to avoid crashing if DB connection is totally wrong
            // but in a real app we might want to log this.
            throw; 
        }
    }
}
