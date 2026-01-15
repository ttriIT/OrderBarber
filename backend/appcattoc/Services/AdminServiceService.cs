using appcattoc.DTOs.Admin;
using appcattoc.Models.Entities;
using Microsoft.EntityFrameworkCore;

namespace appcattoc.Services;

public interface IAdminServiceService
{
    Task<ServiceManagementResponse> CreateServiceAsync(CreateServiceRequest request);
    Task<ServiceManagementResponse> GetServiceByIdAsync(int id);
    Task<List<ServiceManagementResponse>> GetAllServicesAsync();
    Task<List<ServiceManagementResponse>> GetServicesByShopAsync(int shopId);
    Task<ServiceManagementResponse> UpdateServiceAsync(int id, UpdateServiceRequest request);
    Task DeleteServiceAsync(int id);
}

public class AdminServiceService : IAdminServiceService
{
    private readonly BarberDbContext _context;

    public AdminServiceService(BarberDbContext context)
    {
        _context = context;
    }

    public async Task<ServiceManagementResponse> CreateServiceAsync(CreateServiceRequest request)
    {
        var shop = await _context.Shops.FindAsync(request.ShopId);
        if (shop == null)
            throw new InvalidOperationException("Shop not found");

        var service = new Service
        {
            ShopId = request.ShopId,
            Name = request.Name,
            Price = request.Price,
            DurationMinutes = request.DurationMinutes,
            Description = request.Description,
            Category = request.Category,
            ImageUrl = request.ImageUrl
        };

        _context.Services.Add(service);
        await _context.SaveChangesAsync();

        return MapToResponse(service);
    }

    public async Task<ServiceManagementResponse> GetServiceByIdAsync(int id)
    {
        var service = await _context.Services.FindAsync(id);
        if (service == null)
            throw new InvalidOperationException("Service not found");

        return MapToResponse(service);
    }

    public async Task<List<ServiceManagementResponse>> GetAllServicesAsync()
    {
        var services = await _context.Services
            .OrderByDescending(s => s.CreatedAt)
            .ToListAsync();

        return services.Select(MapToResponse).ToList();
    }

    public async Task<List<ServiceManagementResponse>> GetServicesByShopAsync(int shopId)
    {
        var services = await _context.Services
            .Where(s => s.ShopId == shopId)
            .OrderByDescending(s => s.CreatedAt)
            .ToListAsync();

        return services.Select(MapToResponse).ToList();
    }

    public async Task<ServiceManagementResponse> UpdateServiceAsync(int id, UpdateServiceRequest request)
    {
        var service = await _context.Services.FindAsync(id);
        if (service == null)
            throw new InvalidOperationException("Service not found");

        if (!string.IsNullOrEmpty(request.Name))
            service.Name = request.Name;
        if (request.Price.HasValue)
            service.Price = request.Price.Value;
        if (request.DurationMinutes.HasValue)
            service.DurationMinutes = request.DurationMinutes.Value;
        if (request.Description != null)
            service.Description = request.Description;
        if (request.Category != null)
            service.Category = request.Category;
        if (request.ImageUrl != null)
            service.ImageUrl = request.ImageUrl;

        service.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        return MapToResponse(service);
    }

    public async Task DeleteServiceAsync(int id)
    {
        var service = await _context.Services.FindAsync(id);
        if (service == null)
            throw new InvalidOperationException("Service not found");

        _context.Services.Remove(service);
        await _context.SaveChangesAsync();
    }

    private ServiceManagementResponse MapToResponse(Service service)
    {
        return new ServiceManagementResponse
        {
            Id = service.Id,
            ShopId = service.ShopId,
            Name = service.Name,
            Price = service.Price,
            DurationMinutes = service.DurationMinutes,
            Description = service.Description,
            Category = service.Category,
            ImageUrl = service.ImageUrl,
            CreatedAt = service.CreatedAt,
            UpdatedAt = service.UpdatedAt
        };
    }
}
