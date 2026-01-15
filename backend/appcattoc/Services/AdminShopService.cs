using appcattoc.DTOs.Admin;
using appcattoc.Models.Entities;
using Microsoft.EntityFrameworkCore;

namespace appcattoc.Services;

public interface IAdminShopService
{
    Task<ShopManagementResponse> CreateShopAsync(CreateShopRequest request);
    Task<ShopManagementResponse> GetShopByIdAsync(int id);
    Task<List<ShopManagementResponse>> GetAllShopsAsync();
    Task<List<ShopManagementResponse>> GetShopsByManagerAsync(int managerId);
    Task<ShopManagementResponse> UpdateShopAsync(int id, UpdateShopRequest request);
    Task DeleteShopAsync(int id);
}

public class AdminShopService : IAdminShopService
{
    private readonly BarberDbContext _context;

    public AdminShopService(BarberDbContext context)
    {
        _context = context;
    }

    public async Task<ShopManagementResponse> CreateShopAsync(CreateShopRequest request)
    {
        var manager = await _context.Users.FindAsync(request.ManagerId);
        if (manager == null)
            throw new InvalidOperationException("Manager not found");

        var shop = new Shop
        {
            ManagerId = request.ManagerId,
            Name = request.Name,
            Location = request.Location,
            Phone = request.Phone,
            Description = request.Description,
            ImageUrl = request.ImageUrl,
            OpenTime = request.OpenTime,
            CloseTime = request.CloseTime
        };

        _context.Shops.Add(shop);
        await _context.SaveChangesAsync();

        return await MapToResponseAsync(shop);
    }

    public async Task<ShopManagementResponse> GetShopByIdAsync(int id)
    {
        var shop = await _context.Shops
            .Include(s => s.Manager)
            .FirstOrDefaultAsync(s => s.Id == id);

        if (shop == null)
            throw new InvalidOperationException("Shop not found");

        return await MapToResponseAsync(shop);
    }

    public async Task<List<ShopManagementResponse>> GetAllShopsAsync()
    {
        var shops = await _context.Shops
            .Include(s => s.Manager)
            .OrderByDescending(s => s.CreatedAt)
            .ToListAsync();

        var result = new List<ShopManagementResponse>();
        foreach (var shop in shops)
        {
            result.Add(await MapToResponseAsync(shop));
        }
        return result;
    }

    public async Task<List<ShopManagementResponse>> GetShopsByManagerAsync(int managerId)
    {
        var shops = await _context.Shops
            .Where(s => s.ManagerId == managerId)
            .Include(s => s.Manager)
            .OrderByDescending(s => s.CreatedAt)
            .ToListAsync();

        var result = new List<ShopManagementResponse>();
        foreach (var shop in shops)
        {
            result.Add(await MapToResponseAsync(shop));
        }
        return result;
    }

    public async Task<ShopManagementResponse> UpdateShopAsync(int id, UpdateShopRequest request)
    {
        var shop = await _context.Shops.FindAsync(id);
        if (shop == null)
            throw new InvalidOperationException("Shop not found");

        if (!string.IsNullOrEmpty(request.Name))
            shop.Name = request.Name;
        if (!string.IsNullOrEmpty(request.Location))
            shop.Location = request.Location;
        if (request.Phone != null)
            shop.Phone = request.Phone;
        if (request.Description != null)
            shop.Description = request.Description;
        if (request.ImageUrl != null)
            shop.ImageUrl = request.ImageUrl;
        if (request.OpenTime != default)
            shop.OpenTime = request.OpenTime;
        if (request.CloseTime != default)
            shop.CloseTime = request.CloseTime;

        shop.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        return await MapToResponseAsync(shop);
    }

    public async Task DeleteShopAsync(int id)
    {
        var shop = await _context.Shops.FindAsync(id);
        if (shop == null)
            throw new InvalidOperationException("Shop not found");

        _context.Shops.Remove(shop);
        await _context.SaveChangesAsync();
    }

    private async Task<ShopManagementResponse> MapToResponseAsync(Shop shop)
    {
        var manager = await _context.Users.FindAsync(shop.ManagerId);

        return new ShopManagementResponse
        {
            Id = shop.Id,
            ManagerId = shop.ManagerId,
            ManagerName = manager?.FullName ?? "Unknown",
            Name = shop.Name,
            Location = shop.Location,
            Phone = shop.Phone,
            Description = shop.Description,
            ImageUrl = shop.ImageUrl,
            Rating = shop.Rating,
            ReviewCount = shop.ReviewCount,
            OpenTime = shop.OpenTime,
            CloseTime = shop.CloseTime,
            CreatedAt = shop.CreatedAt,
            UpdatedAt = shop.UpdatedAt
        };
    }
}
