using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using appcattoc.Data;
using appcattoc.Models.Entities;
using appcattoc.Models.Enums;

namespace appcattoc.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BarbersController : ControllerBase
{
    private readonly BarberDbContext _context;

    public BarbersController(BarberDbContext context)
    {
        _context = context;
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 1: GET ALL BARBERS                                         ║
    // ║ GET /api/barbers                                               ║
    // ║ Authorization: Anonymous                                       ║
    // ╚════════════════════════════════════════════════════════════════╝
    // =====================================================
    // GET ALL BARBERS (BACKEND GỐC)
    // =====================================================
    [HttpGet]
    [AllowAnonymous]
    public async Task<ActionResult<IEnumerable<object>>> GetBarbers()
    {
        var barbers = await _context.StaffProfiles
            .Include(s => s.User)
            .Include(s => s.Shop)
            .Where(s => s.IsActive)
            .Select(s => new
            {
                Id = s.Id,
                UserId = s.UserId,
                Name = s.User.FullName,
                Phone = s.User.Phone,
                Bio = s.Bio ?? "Chuyên nghiệp",
                Position = s.Position ?? "Stylist",
                Rating = s.Rating,
                ReviewCount = s.ReviewCount,
                AvatarUrl = s.User.AvatarUrl,
                ShopId = s.ShopId,
                ShopName = s.Shop.Name,
                ExperienceYears = s.ExperienceYears
            })
            .ToListAsync();

        return Ok(barbers);
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 2: GET BARBER TIMELINE                                     ║
    // ║ GET /api/barbers/{barberId}/timeline?date=YYYY-MM-DD           ║
    // ║ Authorization: Anonymous                                       ║
    // ╚════════════════════════════════════════════════════════════════╝
    // =====================================================
    // TIMELINE RẢNH / BẬN CHO BARBER (GỘP TỪ nhom10lor)
    // =====================================================
    // GET: api/Barbers/{barberId}/timeline?date=2026-01-13
    [HttpGet("{barberId}/timeline")]
    [AllowAnonymous]
    public async Task<IActionResult> GetTimeline(int barberId, DateTime date)
    {
        // 1️⃣ Check barber (map Barber -> StaffProfile)
        var barber = await _context.StaffProfiles
            .Include(s => s.Shop)
            .FirstOrDefaultAsync(s => s.Id == barberId && s.IsActive);

        if (barber == null)
            return BadRequest("Barber không tồn tại hoặc không nhận khách");

        // 2️⃣ Lấy shop
        var shop = barber.Shop;
        if (shop == null)
            return BadRequest("Shop không tồn tại");

        // 3️⃣ Lấy appointment trong ngày (THAY Booking)
        var appointments = await _context.Appointments
            .Where(a =>
                a.StaffId == barberId &&
                a.StartTime.Date == date.Date &&
                a.Status != AppointmentStatus.Cancelled
            )
            .ToListAsync();

        // 4️⃣ Build timeline 30 phút
        var timeline = new List<object>();

        var currentTime = shop.OpenTime;
        while (currentTime.Add(TimeSpan.FromMinutes(30)) <= shop.CloseTime)
        {
            var slotStart = currentTime;
            var slotEnd = currentTime.Add(TimeSpan.FromMinutes(30));

            var slotStartDt = date.Date.Add(slotStart);
            var slotEndDt = date.Date.Add(slotEnd);

            bool isBusy = appointments.Any(a =>
                slotStartDt < a.EndTime &&
                slotEndDt > a.StartTime
            );

            timeline.Add(new
            {
                Time = slotStart.ToString(@"HH\:mm"),
                Status = isBusy ? "busy" : "free"
            });

            currentTime = slotEnd;
        }

        return Ok(timeline);
    }
}
