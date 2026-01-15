using appcattoc.DTOs.Admin;
using appcattoc.Models.Entities;
using Microsoft.EntityFrameworkCore;

namespace appcattoc.Services;

public interface IAdminBarberService
{
    Task<BarberManagementResponse> CreateBarberAsync(CreateBarberRequest request);
    Task<BarberManagementResponse> GetBarberByIdAsync(int id);
    Task<List<BarberManagementResponse>> GetAllBarbersAsync();
    Task<List<BarberManagementResponse>> GetBarbersByShopAsync(int shopId);
    Task<BarberManagementResponse> UpdateBarberAsync(int id, UpdateBarberRequest request);
    Task DeleteBarberAsync(int id);
}

public class AdminBarberService : IAdminBarberService
{
    private readonly BarberDbContext _context;

    public AdminBarberService(BarberDbContext context)
    {
        _context = context;
    }

    public async Task<BarberManagementResponse> CreateBarberAsync(CreateBarberRequest request)
    {
        var user = await _context.Users.FindAsync(request.UserId);
        if (user == null)
            throw new InvalidOperationException("User not found");

        var shop = await _context.Shops.FindAsync(request.ShopId);
        if (shop == null)
            throw new InvalidOperationException("Shop not found");

        var barber = new Barber
        {
            UserId = request.UserId,
            ShopId = request.ShopId,
            Specialization = request.Specialization,
            Rating = request.Rating,
            ExperienceYears = request.ExperienceYears
        };

        _context.Barbers.Add(barber);
        await _context.SaveChangesAsync();

        barber.User = user;
        barber.Shop = shop;
        return MapToResponse(barber);
    }

    public async Task<BarberManagementResponse> GetBarberByIdAsync(int id)
    {
        var barber = await _context.Barbers
            .Include(b => b.User)
            .Include(b => b.Shop)
            .FirstOrDefaultAsync(b => b.Id == id);

        if (barber == null)
            throw new InvalidOperationException("Barber not found");

        return await MapToResponseAsync(barber);
    }

    public async Task<List<BarberManagementResponse>> GetAllBarbersAsync()
    {
        var barbers = await _context.Barbers
            .Include(b => b.User)
            .Include(b => b.Shop)
            .OrderByDescending(b => b.CreatedAt)
            .ToListAsync();

        return barbers.Select(b => MapToResponse(b)).ToList();
    }

    public async Task<List<BarberManagementResponse>> GetBarbersByShopAsync(int shopId)
    {
        var barbers = await _context.Barbers
            .Where(b => b.ShopId == shopId)
            .Include(b => b.User)
            .Include(b => b.Shop)
            .OrderByDescending(b => b.CreatedAt)
            .ToListAsync();

        return barbers.Select(b => MapToResponse(b)).ToList();
    }

    public async Task<BarberManagementResponse> UpdateBarberAsync(int id, UpdateBarberRequest request)
    {
        var barber = await _context.Barbers
            .Include(b => b.User)
            .Include(b => b.Shop)
            .FirstOrDefaultAsync(b => b.Id == id);
        
        if (barber == null)
            throw new InvalidOperationException("Barber not found");

        if (request.ShopId.HasValue)
        {
            var shop = await _context.Shops.FindAsync(request.ShopId);
            if (shop == null)
                throw new InvalidOperationException("Shop not found");
            barber.ShopId = request.ShopId.Value;
            barber.Shop = shop;
        }

        if (request.Specialization != null)
            barber.Specialization = request.Specialization;
        if (request.Rating.HasValue)
            barber.Rating = request.Rating.Value;
        if (request.ExperienceYears.HasValue)
            barber.ExperienceYears = request.ExperienceYears.Value;

        barber.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        return MapToResponse(barber);
    }

    public async Task DeleteBarberAsync(int id)
    {
        var barber = await _context.Barbers.FindAsync(id);
        if (barber == null)
            throw new InvalidOperationException("Barber not found");

        _context.Barbers.Remove(barber);
        await _context.SaveChangesAsync();
    }

    private BarberManagementResponse MapToResponse(Barber barber)
    {
        return new BarberManagementResponse
        {
            Id = barber.Id,
            UserId = barber.UserId,
            BarberName = barber.User?.FullName ?? "Unknown",
            ShopId = barber.ShopId,
            ShopName = barber.Shop?.Name ?? "Unknown",
            Specialization = barber.Specialization,
            Rating = barber.Rating,
            ExperienceYears = barber.ExperienceYears,
            CreatedAt = barber.CreatedAt,
            UpdatedAt = barber.UpdatedAt
        };
    }
}
