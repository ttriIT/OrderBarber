using appcattoc.DTOs.Admin;
using appcattoc.Models.Entities;
using Microsoft.EntityFrameworkCore;

namespace appcattoc.Services;

public interface IAdminStaffService
{
    Task<StaffManagementResponse> CreateStaffAsync(CreateStaffRequest request);
    Task<StaffManagementResponse> GetStaffByIdAsync(int id);
    Task<List<StaffManagementResponse>> GetAllStaffAsync();
    Task<List<StaffManagementResponse>> GetStaffByShopAsync(int shopId);
    Task<StaffManagementResponse> UpdateStaffAsync(int id, UpdateStaffRequest request);
    Task DeleteStaffAsync(int id);
}

public class AdminStaffService : IAdminStaffService
{
    private readonly BarberDbContext _context;

    public AdminStaffService(BarberDbContext context)
    {
        _context = context;
    }

    public async Task<StaffManagementResponse> CreateStaffAsync(CreateStaffRequest request)
    {
        var user = await _context.Users.FindAsync(request.UserId);
        if (user == null)
            throw new InvalidOperationException("User not found");

        var shop = await _context.Shops.FindAsync(request.ShopId);
        if (shop == null)
            throw new InvalidOperationException("Shop not found");

        var staff = new StaffProfile
        {
            UserId = request.UserId,
            ShopId = request.ShopId,
            Position = request.Position,
            Salary = request.Salary
        };

        _context.StaffProfiles.Add(staff);
        await _context.SaveChangesAsync();

        return await MapToResponseAsync(staff);
    }

    public async Task<StaffManagementResponse> GetStaffByIdAsync(int id)
    {
        var staff = await _context.StaffProfiles
            .Include(sp => sp.User)
            .Include(sp => sp.Shop)
            .FirstOrDefaultAsync(sp => sp.Id == id);

        if (staff == null)
            throw new InvalidOperationException("Staff not found");

        return await MapToResponseAsync(staff);
    }

    public async Task<List<StaffManagementResponse>> GetAllStaffAsync()
    {
        var staffs = await _context.StaffProfiles
            .Include(sp => sp.User)
            .Include(sp => sp.Shop)
            .OrderByDescending(sp => sp.CreatedAt)
            .ToListAsync();

        var result = new List<StaffManagementResponse>();
        foreach (var staff in staffs)
        {
            result.Add(await MapToResponseAsync(staff));
        }
        return result;
    }

    public async Task<List<StaffManagementResponse>> GetStaffByShopAsync(int shopId)
    {
        var staffs = await _context.StaffProfiles
            .Where(sp => sp.ShopId == shopId)
            .Include(sp => sp.User)
            .Include(sp => sp.Shop)
            .OrderByDescending(sp => sp.CreatedAt)
            .ToListAsync();

        var result = new List<StaffManagementResponse>();
        foreach (var staff in staffs)
        {
            result.Add(await MapToResponseAsync(staff));
        }
        return result;
    }

    public async Task<StaffManagementResponse> UpdateStaffAsync(int id, UpdateStaffRequest request)
    {
        var staff = await _context.StaffProfiles.FindAsync(id);
        if (staff == null)
            throw new InvalidOperationException("Staff not found");

        if (request.ShopId.HasValue)
        {
            var shop = await _context.Shops.FindAsync(request.ShopId);
            if (shop == null)
                throw new InvalidOperationException("Shop not found");
            staff.ShopId = request.ShopId.Value;
        }

        if (request.Position != null)
            staff.Position = request.Position;
        if (request.Salary.HasValue)
            staff.Salary = request.Salary.Value;

        staff.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        return await MapToResponseAsync(staff);
    }

    public async Task DeleteStaffAsync(int id)
    {
        var staff = await _context.StaffProfiles.FindAsync(id);
        if (staff == null)
            throw new InvalidOperationException("Staff not found");

        _context.StaffProfiles.Remove(staff);
        await _context.SaveChangesAsync();
    }

    private async Task<StaffManagementResponse> MapToResponseAsync(StaffProfile staff)
    {
        var user = await _context.Users.FindAsync(staff.UserId);
        var shop = await _context.Shops.FindAsync(staff.ShopId);

        return new StaffManagementResponse
        {
            Id = staff.Id,
            UserId = staff.UserId,
            StaffName = user?.FullName ?? "Unknown",
            ShopId = staff.ShopId,
            ShopName = shop?.Name ?? "Unknown",
            Position = staff.Position,
            Salary = staff.Salary,
            CreatedAt = staff.CreatedAt,
            UpdatedAt = staff.UpdatedAt
        };
    }
}
