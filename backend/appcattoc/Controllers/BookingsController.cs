// ⚠️ LEGACY CONTROLLER - NOW ENABLED
// This controller uses old entities (Barber, Booking) from nhom10lor merge
// Works alongside AppointmentsController for compatibility

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using appcattoc.DTOs.Appointments;
using appcattoc.Models.Entities;
using appcattoc.Models.Enums;
using appcattoc.Data;
namespace appcattoc.Controllers;

[ApiController]
[Route("api/bookings")]
[Microsoft.AspNetCore.Authorization.Authorize] // ✅ BẢO MẬT: YÊU CẦU ĐĂNG NHẬP
public class BookingsController : ControllerBase
{
    private readonly BarberDbContext _context;

    public BookingsController(BarberDbContext context)
    {
        _context = context;
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 1: CREATE BOOKING                                          ║
    // ║ POST /api/bookings                                             ║
    // ║ Authorization: Required                                        ║
    // ╚════════════════════════════════════════════════════════════════╝
    [HttpPost]
    public async Task<IActionResult> CreateBooking([FromBody] CreateBookingRequest request)
        {
            if (!TimeSpan.TryParse(request.StartTime, out var startTime) ||
                !TimeSpan.TryParse(request.EndTime, out var endTime))
            {
                return BadRequest("Định dạng thời gian không hợp lệ (HH:mm)");
            }

            if (startTime >= endTime)
                return BadRequest("Giờ bắt đầu phải nhỏ hơn giờ kết thúc");

            var barber = await _context.Barbers.FindAsync(request.BarberId);
            if (barber == null || !barber.IsActive)
                return BadRequest("Barber không tồn tại hoặc không nhận khách");

            var shop = await _context.Shops.FindAsync(request.ShopId);
            if (shop == null)
                return BadRequest("Shop không tồn tại");

            if (startTime < shop.OpenTime || endTime > shop.CloseTime)
                return BadRequest("Ngoài giờ làm việc");

            bool isConflict = _context.Bookings.Any(b =>
                b.BarberId == request.BarberId &&
                b.BookingDate.Date == request.BookingDate.Date &&
                startTime < b.EndTime &&
                endTime > b.StartTime &&
                b.Status != BookingStatus.Cancelled
            );

            if (isConflict)
                return BadRequest("Khung giờ đã có người đặt");

            var booking = new Booking
            {
                BarberId = request.BarberId,
                Barber = barber,
                ShopId = request.ShopId,
                Shop = shop,
                CustomerName = request.CustomerName,
                CustomerPhone = request.CustomerPhone,
                BookingDate = request.BookingDate.Date,
                StartTime = startTime,
                EndTime = endTime,
                Status = 0, // pending
                
                // Map only the first service for now (since DB only supports one)
                ServiceId = (request.ServiceIds != null && request.ServiceIds.Any()) ? request.ServiceIds.First() : null
            };

            _context.Bookings.Add(booking);
            _context.SaveChanges();

            return Ok(new { booking.BookingId });
        }

        // ╔════════════════════════════════════════════════════════════════╗
        // ║ API 2: CANCEL BOOKING                                          ║
        // ║ PUT /api/bookings/{id}/cancel                                  ║
        // ║ Authorization: Required                                        ║
        // ╚════════════════════════════════════════════════════════════════╝
        [HttpPut("{id}/cancel")]
        public async Task<IActionResult> CancelBooking(int id)
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null)
                return NotFound();

            booking.Status = BookingStatus.Cancelled;

            _context.Notifications.Add(new Notification
            {
                BarberId = booking.BarberId,
                Title = "Lịch hẹn đã bị huỷ",
                Content = $"Lịch hẹn lúc {booking.StartTime:hh\\:mm} ngày {booking.BookingDate:dd/MM/yyyy} đã bị huỷ",
                Type = "booking_cancelled",
                CreatedAt = DateTime.UtcNow,
                IsRead = false
            });

            await _context.SaveChangesAsync();
            return Ok();
        }

        // ╔════════════════════════════════════════════════════════════════╗
        // ║ API 3: GET BOOKINGS BY BARBER AND DATE                         ║
        // ║ GET /api/bookings?barberId={id}&date={date}                    ║
        // ║ Authorization: Required                                        ║
        // ╚════════════════════════════════════════════════════════════════╝
        [HttpGet]
        public IActionResult GetBookings(int barberId, DateTime date)
        {
            var bookings = _context.Bookings
                .Include(b => b.Barber)
                .Include(b => b.Shop)
                .Where(b =>
                    b.BarberId == barberId &&
                    b.BookingDate.Date == date.Date &&
                    b.Status != BookingStatus.Cancelled
                )
                .Select(b => new BookingResponse
                {
                    BookingId = b.BookingId,
                    BarberName = b.Barber.Name,
                    ShopName = b.Shop.Name,
                    BookingDate = b.BookingDate,
                    StartTime = b.StartTime,
                    EndTime = b.EndTime,
                    Status = (int)b.Status
                })
                .ToList();

            return Ok(bookings);
        }

        // ╔════════════════════════════════════════════════════════════════╗
        // ║ API 4: GET BOOKINGS BY SHOP AND DATE                           ║
        // ║ GET /api/bookings/shop/{shopId}?date={date}                    ║
        // ║ Authorization: Required (Shop Manager)                         ║
        // ╚════════════════════════════════════════════════════════════════╝
        [HttpGet("shop/{shopId}")]
        public IActionResult GetShopBookings(int shopId, DateTime date)
        {
            var bookings = _context.Bookings
                .Include(b => b.Barber)
                .Include(b => b.Shop)
                .Where(b =>
                    b.ShopId == shopId &&
                    b.BookingDate.Date == date.Date &&
                    b.Status != BookingStatus.Cancelled
                )
                .Select(b => new BookingResponse
                {
                    BookingId = b.BookingId,
                    BarberName = b.Barber.Name,
                    ShopName = b.Shop.Name,
                    BookingDate = b.BookingDate,
                    StartTime = b.StartTime,
                    EndTime = b.EndTime,
                    Status = (int)b.Status,
                    CustomerId = b.CustomerId ?? 0,
                    CustomerName = b.CustomerName,
                    ServiceId = b.ServiceId ?? 0,
                    ServiceName = b.Service != null ? b.Service.Name : "",
                    ServicePrice = b.Service != null ? b.Service.Price : 0
                })
                .ToList();

            return Ok(bookings);
        }

        // ╔════════════════════════════════════════════════════════════════╗
        // ║ API 5: GET ALL BOOKINGS (ADMIN ONLY)                           ║
        // ║ GET /api/bookings/all?page={page}&pageSize={pageSize}          ║
        // ║ Authorization: Admin Role Required                             ║
        // ╚════════════════════════════════════════════════════════════════╝
        [HttpGet("all")]
        [Authorize(Roles = "Admin")]
        public IActionResult GetAllBookings([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
        {
            var query = _context.Bookings
                .Include(b => b.Barber)
                .Include(b => b.Shop)
                .OrderByDescending(b => b.BookingDate)
                .ThenByDescending(b => b.StartTime);

            var totalItems = query.Count();
            var bookings = query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(b => new BookingResponse
                {
                    BookingId = b.BookingId,
                    BarberName = b.Barber.Name,
                    ShopName = b.Shop.Name,
                    BookingDate = b.BookingDate,
                    StartTime = b.StartTime,
                    EndTime = b.EndTime,
                    Status = (int)b.Status,
                    CustomerId = b.CustomerId ?? 0,
                    CustomerName = b.CustomerName,
                    ServiceId = b.ServiceId ?? 0,
                    ServiceName = b.Service != null ? b.Service.Name : "",
                    ServicePrice = b.Service != null ? b.Service.Price : 0
                })
                .ToList();

            return Ok(new { TotalItems = totalItems, Page = page, PageSize = pageSize, Data = bookings });
        }

        // ╔════════════════════════════════════════════════════════════════╗
        // ║ API 6: BARBER CONFIRM BOOKING                                  ║
        // ║ PUT /api/bookings/{id}/confirm                                 ║
        // ║ Authorization: Required (Barber/Staff)                         ║
        // ╚════════════════════════════════════════════════════════════════╝
        [HttpPut("{id}/confirm")]
        public async Task<IActionResult> ConfirmBooking(int id)
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null)
                return NotFound("Booking không tồn tại");

            if (booking.Status != BookingStatus.Pending)
                return BadRequest("Chỉ được xác nhận booking đang chờ");

            booking.Status = BookingStatus.Confirmed;

            _context.Notifications.Add(new Notification
            {
                BarberId = booking.BarberId,
                Title = "Lịch hẹn được xác nhận",
                Content = $"Lịch hẹn lúc {booking.StartTime:hh\\:mm} ngày {booking.BookingDate:dd/MM/yyyy} đã được xác nhận",
                Type = "booking_confirmed",
                CreatedAt = DateTime.UtcNow,
                IsRead = false
            });

            await _context.SaveChangesAsync();
            return Ok("Đã xác nhận lịch");
        }

        // ╔════════════════════════════════════════════════════════════════╗
        // ║ API 7: BARBER REJECT BOOKING                                   ║
        // ║ PUT /api/bookings/{id}/reject                                  ║
        // ║ Authorization: Required (Barber/Staff)                         ║
        // ╚════════════════════════════════════════════════════════════════╝
        [HttpPut("{id}/reject")]
        public async Task<IActionResult> RejectBooking(int id)
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null)
                return NotFound("Booking không tồn tại");

            if (booking.Status == BookingStatus.Done)
                return BadRequest("Không thể huỷ booking đã hoàn thành");

            booking.Status = BookingStatus.Cancelled;

            _context.Notifications.Add(new Notification
            {
                BarberId = booking.BarberId,
                Title = "Lịch hẹn bị từ chối",
                Content = $"Lịch hẹn lúc {booking.StartTime:hh\\:mm} đã bị từ chối",
                Type = "booking_rejected",
                CreatedAt = DateTime.UtcNow,
                IsRead = false
            });

            await _context.SaveChangesAsync();
            return Ok("Đã huỷ lịch");
        }

        // ╔════════════════════════════════════════════════════════════════╗
        // ║ API 8: BARBER COMPLETE BOOKING                                 ║
        // ║ PUT /api/bookings/{id}/done                                    ║
        // ║ Authorization: Required (Barber/Staff)                         ║
        // ╚════════════════════════════════════════════════════════════════╝
        [HttpPut("{id}/done")]
        public async Task<IActionResult> CompleteBooking(int id)
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null)
                return NotFound("Booking không tồn tại");

            if (booking.Status != BookingStatus.Confirmed)
                return BadRequest("Chỉ hoàn thành booking đã xác nhận");

            booking.Status = BookingStatus.Done;

            _context.Notifications.Add(new Notification
            {
                BarberId = booking.BarberId,
                Title = "Hoàn thành dịch vụ",
                Content = $"Bạn đã hoàn thành lịch hẹn lúc {booking.StartTime:hh\\:mm}",
                Type = "booking_done",
                CreatedAt = DateTime.UtcNow,
                IsRead = false
            });

            await _context.SaveChangesAsync();
            return Ok("Đã hoàn thành dịch vụ");
        }
}
