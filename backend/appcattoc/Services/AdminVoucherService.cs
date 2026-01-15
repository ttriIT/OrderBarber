using appcattoc.DTOs.Admin;
using appcattoc.Models.Entities;

namespace appcattoc.Services;

public interface IAdminVoucherService
{
    Task<VoucherResponse> CreateVoucherAsync(CreateVoucherRequest request);
    Task<VoucherResponse> GetVoucherByIdAsync(int id);
    Task<List<VoucherResponse>> GetAllVouchersAsync();
    Task<List<VoucherResponse>> GetActiveVouchersAsync();
    Task<VoucherResponse> UpdateVoucherAsync(int id, UpdateVoucherRequest request);
    Task DeleteVoucherAsync(int id);
    Task<bool> CheckVoucherValidityAsync(int voucherId);
}

public class AdminVoucherService : IAdminVoucherService
{
    private readonly BarberDbContext _context;

    public AdminVoucherService(BarberDbContext context)
    {
        _context = context;
    }

    public async Task<VoucherResponse> CreateVoucherAsync(CreateVoucherRequest request)
    {
        var voucher = new Voucher
        {
            Code = request.Code,
            Description = request.Description,
            DiscountAmount = request.DiscountAmount,
            DiscountType = request.DiscountType,
            MaxDiscountAmount = request.MaxDiscountAmount,
            MinimumAmount = request.MinimumAmount,
            StartDate = request.StartDate,
            EndDate = request.EndDate,
            MaxUsage = request.MaxUsage,
            MaxUsagePerUser = request.MaxUsagePerUser,
            ShopId = request.ShopId,
            Notes = request.Notes,
            IsActive = true
        };

        _context.Vouchers.Add(voucher);
        await _context.SaveChangesAsync();

        return MapToResponse(voucher);
    }

    public async Task<VoucherResponse> GetVoucherByIdAsync(int id)
    {
        var voucher = await _context.Vouchers.FindAsync(id);
        if (voucher == null)
            throw new InvalidOperationException("Voucher not found");

        return MapToResponse(voucher);
    }

    public async Task<List<VoucherResponse>> GetAllVouchersAsync()
    {
        var vouchers = await _context.Vouchers.ToListAsync();
        return vouchers.Select(MapToResponse).ToList();
    }

    public async Task<List<VoucherResponse>> GetActiveVouchersAsync()
    {
        var now = DateTime.UtcNow;
        var vouchers = await _context.Vouchers
            .Where(v => v.IsActive && v.StartDate <= now && v.EndDate >= now)
            .ToListAsync();

        return vouchers.Select(MapToResponse).ToList();
    }

    public async Task<VoucherResponse> UpdateVoucherAsync(int id, UpdateVoucherRequest request)
    {
        var voucher = await _context.Vouchers.FindAsync(id);
        if (voucher == null)
            throw new InvalidOperationException("Voucher not found");

        if (!string.IsNullOrEmpty(request.Code))
            voucher.Code = request.Code;
        if (!string.IsNullOrEmpty(request.Description))
            voucher.Description = request.Description;
        if (request.DiscountAmount.HasValue)
            voucher.DiscountAmount = request.DiscountAmount.Value;
        if (request.DiscountType.HasValue)
            voucher.DiscountType = request.DiscountType.Value;
        if (request.MaxDiscountAmount.HasValue)
            voucher.MaxDiscountAmount = request.MaxDiscountAmount.Value;
        if (request.MinimumAmount.HasValue)
            voucher.MinimumAmount = request.MinimumAmount.Value;
        if (request.StartDate != default)
            voucher.StartDate = request.StartDate;
        if (request.EndDate != default)
            voucher.EndDate = request.EndDate;
        if (request.MaxUsage.HasValue)
            voucher.MaxUsage = request.MaxUsage.Value;
        if (request.MaxUsagePerUser.HasValue)
            voucher.MaxUsagePerUser = request.MaxUsagePerUser.Value;
        if (request.IsActive.HasValue)
            voucher.IsActive = request.IsActive.Value;
        if (request.Notes != null)
            voucher.Notes = request.Notes;

        voucher.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        return MapToResponse(voucher);
    }

    public async Task DeleteVoucherAsync(int id)
    {
        var voucher = await _context.Vouchers.FindAsync(id);
        if (voucher == null)
            throw new InvalidOperationException("Voucher not found");

        _context.Vouchers.Remove(voucher);
        await _context.SaveChangesAsync();
    }

    public async Task<bool> CheckVoucherValidityAsync(int voucherId)
    {
        var voucher = await _context.Vouchers.FindAsync(voucherId);
        if (voucher == null)
            return false;

        var now = DateTime.UtcNow;
        return voucher.IsActive &&
               voucher.StartDate <= now &&
               voucher.EndDate >= now &&
               voucher.CurrentUsage < voucher.MaxUsage;
    }

    private VoucherResponse MapToResponse(Voucher voucher)
    {
        return new VoucherResponse
        {
            Id = voucher.Id,
            Code = voucher.Code,
            Description = voucher.Description,
            DiscountAmount = voucher.DiscountAmount,
            DiscountType = voucher.DiscountType,
            MaxDiscountAmount = voucher.MaxDiscountAmount,
            MinimumAmount = voucher.MinimumAmount,
            StartDate = voucher.StartDate,
            EndDate = voucher.EndDate,
            MaxUsage = voucher.MaxUsage,
            CurrentUsage = voucher.CurrentUsage,
            MaxUsagePerUser = voucher.MaxUsagePerUser,
            IsActive = voucher.IsActive,
            ShopId = voucher.ShopId,
            Notes = voucher.Notes,
            CreatedAt = voucher.CreatedAt,
            UpdatedAt = voucher.UpdatedAt
        };
    }
}
