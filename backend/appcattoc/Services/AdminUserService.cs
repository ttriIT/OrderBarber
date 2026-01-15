using appcattoc.DTOs.Admin;
using appcattoc.Models.Entities;
using appcattoc.Models.Enums;
using Microsoft.EntityFrameworkCore;

namespace appcattoc.Services;

public interface IAdminUserService
{
    Task<List<UserManagementResponse>> GetAllUsersAsync();
    Task<UserManagementResponse> GetUserByIdAsync(int id);
    Task<UserManagementResponse> UpdateUserAsync(int id, UserManagementRequest request);
    Task DeleteUserAsync(int id);
    Task<UserStatisticsResponse> GetUserStatisticsAsync();
    Task<bool> DeactivateUserAsync(int id);
}

public class AdminUserService : IAdminUserService
{
    private readonly BarberDbContext _context;

    public AdminUserService(BarberDbContext context)
    {
        _context = context;
    }

    public async Task<List<UserManagementResponse>> GetAllUsersAsync()
    {
        var users = await _context.Users
            .OrderByDescending(u => u.CreatedAt)
            .ToListAsync();

        return users.Select(MapToResponse).ToList();
    }

    public async Task<UserManagementResponse> GetUserByIdAsync(int id)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null)
            throw new InvalidOperationException("User not found");

        return MapToResponse(user);
    }

    public async Task<UserManagementResponse> UpdateUserAsync(int id, UserManagementRequest request)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null)
            throw new InvalidOperationException("User not found");

        if (!string.IsNullOrEmpty(request.FullName))
            user.FullName = request.FullName;
        if (!string.IsNullOrEmpty(request.Email))
            user.Email = request.Email;
        if (!string.IsNullOrEmpty(request.Phone))
            user.Phone = request.Phone;
        if (request.AvatarUrl != null)
            user.AvatarUrl = request.AvatarUrl;
        if (request.Role.HasValue)
            user.Role = (UserRole)request.Role;

        user.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        return MapToResponse(user);
    }

    public async Task DeleteUserAsync(int id)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null)
            throw new InvalidOperationException("User not found");

        _context.Users.Remove(user);
        await _context.SaveChangesAsync();
    }

    public async Task<UserStatisticsResponse> GetUserStatisticsAsync()
    {
        var totalUsers = await _context.Users.CountAsync();
        var customersCount = await _context.Users.CountAsync(u => u.Role == UserRole.Customer);
        var barbersCount = await _context.StaffProfiles.CountAsync();
        var managersCount = await _context.Users.CountAsync(u => u.Role == UserRole.Manager);
        var adminsCount = await _context.Users.CountAsync(u => u.Role == UserRole.Admin);

        return new UserStatisticsResponse
        {
            TotalUsers = totalUsers,
            ActiveUsers = totalUsers, // Can be enhanced with logic
            CustomersCount = customersCount,
            BarbersCount = barbersCount,
            ManagersCount = managersCount,
            AdminsCount = adminsCount
        };
    }

    public async Task<bool> DeactivateUserAsync(int id)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null)
            return false;

        // Implement deactivation logic based on your requirements
        user.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();
        return true;
    }

    private UserManagementResponse MapToResponse(User user)
    {
        return new UserManagementResponse
        {
            Id = user.Id,
            Username = user.Username,
            FullName = user.FullName,
            Email = user.Email,
            Phone = user.Phone,
            AvatarUrl = user.AvatarUrl,
            Role = (int)user.Role,
            CreatedAt = user.CreatedAt,
            UpdatedAt = user.UpdatedAt
        };
    }
}
