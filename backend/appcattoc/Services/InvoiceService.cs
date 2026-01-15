using Microsoft.EntityFrameworkCore;
using appcattoc.Data;
using appcattoc.DTOs.Invoices;
using appcattoc.Models.Entities;
using appcattoc.Models.Enums;

namespace appcattoc.Services;

public interface IInvoiceService
{
    Task<(bool Success, string Message, InvoiceResponse? Data)> CreateInvoiceAsync(int staffId, CreateInvoiceRequest request);
    Task<List<InvoiceResponse>> GetInvoicesByShopAsync(int shopId, DateTime? startDate, DateTime? endDate);
}

public class InvoiceService : IInvoiceService
{
    private readonly BarberDbContext _context;

    public InvoiceService(BarberDbContext context)
    {
        _context = context;
    }

    public async Task<(bool Success, string Message, InvoiceResponse? Data)> CreateInvoiceAsync(
        int userId, CreateInvoiceRequest request)
    {
        var appointment = await _context.Appointments
            .Include(a => a.Service)
            .Include(a => a.Staff)
            .FirstOrDefaultAsync(a => a.Id == request.AppointmentId);

        if (appointment == null)
        {
            return (false, "Appointment not found", null);
        }

        // Get staff profile for the user
        var staffProfile = await _context.StaffProfiles
            .Include(s => s.User)
            .FirstOrDefaultAsync(s => s.UserId == userId);

        if (staffProfile == null)
        {
            return (false, "You must be a staff member to create invoices", null);
        }

        // Verify staff information exists
        if (appointment.Staff == null)
        {
            return (false, "Staff information not found for this appointment", null);
        }

        // Verify staff has permission (must be same shop)
        if (staffProfile.ShopId != appointment.Staff.ShopId)
        {
            return (false, "You don't have permission to create invoice for this appointment", null);
        }

        if (appointment.Status == AppointmentStatus.Completed)
        {
            return (false, "Appointment already completed and invoiced", null);
        }

        if (await _context.Invoices.AnyAsync(i => i.AppointmentId == request.AppointmentId))
        {
            return (false, "Invoice already exists for this appointment", null);
        }

        if (!Enum.TryParse<PaymentMethod>(request.PaymentMethod, out var paymentMethod))
        {
            return (false, "Invalid payment method", null);
        }

        // Validate total amount
        if (request.TotalAmount <= 0)
        {
            return (false, "Total amount must be greater than zero", null);
        }

        var invoice = new Invoice
        {
            AppointmentId = request.AppointmentId,
            TotalAmount = request.TotalAmount,
            PaymentMethod = paymentMethod,
            CreatedByStaffId = staffProfile.Id,
            CreatedAt = DateTime.UtcNow
        };

        appointment.Status = AppointmentStatus.Completed;
        appointment.UpdatedAt = DateTime.UtcNow;

        _context.Invoices.Add(invoice);
        await _context.SaveChangesAsync();

        var response = new InvoiceResponse
        {
            Id = invoice.Id,
            AppointmentId = invoice.AppointmentId,
            TotalAmount = invoice.TotalAmount,
            PaymentMethod = invoice.PaymentMethod.ToString(),
            CreatedByStaffId = invoice.CreatedByStaffId,
            CreatedByStaffName = staffProfile.User.FullName,
            CreatedAt = invoice.CreatedAt
        };

        return (true, "Invoice created successfully", response);
    }

    public async Task<List<InvoiceResponse>> GetInvoicesByShopAsync(int shopId, DateTime? startDate, DateTime? endDate)
    {
        var query = _context.Invoices
            .Include(i => i.Appointment)
                .ThenInclude(a => a.Staff)
                .ThenInclude(s => s.User)
            .Where(i => i.Appointment.Staff.ShopId == shopId);

        if (startDate.HasValue)
        {
            query = query.Where(i => i.CreatedAt >= startDate.Value);
        }

        if (endDate.HasValue)
        {
            query = query.Where(i => i.CreatedAt <= endDate.Value);
        }

        return await query
            .Select(i => new InvoiceResponse
            {
                Id = i.Id,
                AppointmentId = i.AppointmentId,
                TotalAmount = i.TotalAmount,
                PaymentMethod = i.PaymentMethod.ToString(),
                CreatedByStaffId = i.CreatedByStaffId,
                CreatedByStaffName = i.Appointment.Staff.User.FullName,
                CreatedAt = i.CreatedAt
            })
            .OrderByDescending(i => i.CreatedAt)
            .ToListAsync();
    }
}
