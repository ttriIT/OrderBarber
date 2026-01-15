using appcattoc.Data;
using appcattoc.DTOs.Reviews;
using appcattoc.Models.Entities;
using appcattoc.Models.Enums;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace appcattoc.Services;

public class ReviewService : IReviewService
{
    private readonly BarberDbContext _context;
    private readonly ILogger<ReviewService> _logger;

    public ReviewService(BarberDbContext context, ILogger<ReviewService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<List<ReviewResponse>> GetShopReviewsAsync(int shopId)
    {
        var reviews = await _context.Reviews
            .Include(r => r.User)
            .Where(r => r.ShopId == shopId)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();

        return reviews.Select(r => new ReviewResponse
        {
            Id = r.Id,
            UserId = r.UserId,
            UserName = r.User.FullName,
            AvatarUrl = r.User.AvatarUrl,
            Rating = r.Rating,
            Comment = r.Comment,
            CreatedAt = r.CreatedAt
        }).ToList();
    }

    public async Task<ServiceResult<ReviewResponse>> CreateReviewAsync(int userId, CreateReviewRequest request)
    {
        try
        {
            // ✅ VALIDATION 1: Check if appointment exists and belongs to user
            var appointment = await _context.Appointments
                .Include(a => a.Service)
                .Include(a => a.Staff)
                .FirstOrDefaultAsync(a => a.Id == request.AppointmentId);

            if (appointment == null)
            {
                return ServiceResult<ReviewResponse>.Failure("Appointment not found");
            }

            // ✅ VALIDATION 2: User must own the appointment
            if (appointment.CustomerId != userId)
            {
                return ServiceResult<ReviewResponse>.Failure("You can only review your own appointments");
            }

            // ✅ VALIDATION 3: Appointment must be completed
            if (appointment.Status != AppointmentStatus.Completed)
            {
                return ServiceResult<ReviewResponse>.Failure($"You can only review completed appointments. Current status: {appointment.Status}");
            }

            // ✅ VALIDATION 4: Prevent duplicate reviews
            var existingReview = await _context.Reviews
                .FirstOrDefaultAsync(r => r.AppointmentId == request.AppointmentId && r.UserId == userId);

            if (existingReview != null)
            {
                return ServiceResult<ReviewResponse>.Failure("You have already reviewed this appointment");
            }

            // ✅ VALIDATION 5: Check Staff exists
            if (appointment.Staff == null)
            {
                return ServiceResult<ReviewResponse>.Failure("Staff information not found for this appointment");
            }

            // ✅ VALIDATION 6: Validate ShopId and StaffId match appointment
            if (request.ShopId != appointment.Staff.ShopId)
            {
                return ServiceResult<ReviewResponse>.Failure("ShopId does not match the appointment");
            }

            if (request.StaffId.HasValue && request.StaffId.Value != appointment.StaffId)
            {
                return ServiceResult<ReviewResponse>.Failure("StaffId does not match the appointment");
            }

            // Create review
            var review = new Review
            {
                UserId = userId,
                ShopId = request.ShopId,
                StaffId = request.StaffId ?? appointment.StaffId,
                AppointmentId = request.AppointmentId,
                ServiceId = request.ServiceId ?? appointment.ServiceId, // ✅ Link to Service
                Rating = request.Rating,
                Comment = request.Comment,
                CreatedAt = DateTime.UtcNow
            };

            _context.Reviews.Add(review);
            await _context.SaveChangesAsync();

            // ✅ AUTO-UPDATE RATINGS
            await UpdateShopRatingAsync(request.ShopId);
            if (request.StaffId.HasValue)
            {
                await UpdateStaffRatingAsync(request.StaffId.Value);
            }

            _logger.LogInformation(
                "Review created: User {UserId}, Appointment {AppointmentId}, Rating {Rating}",
                userId, request.AppointmentId, request.Rating
            );

            // Reload to get User details
            await _context.Entry(review).Reference(r => r.User).LoadAsync();

            return ServiceResult<ReviewResponse>.SuccessResult(new ReviewResponse
            {
                Id = review.Id,
                UserId = review.UserId,
                UserName = review.User.FullName,
                AvatarUrl = review.User.AvatarUrl,
                ShopId = review.ShopId,
                StaffId = review.StaffId,
                ServiceId = review.ServiceId,
                Rating = review.Rating,
                Comment = review.Comment,
                CreatedAt = review.CreatedAt
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating review for user {UserId}", userId);
            return ServiceResult<ReviewResponse>.Failure($"Error creating review: {ex.Message}");
        }
    }

    private async Task UpdateShopRatingAsync(int shopId)
    {
        var shopReviews = await _context.Reviews
            .Where(r => r.ShopId == shopId)
            .ToListAsync();

        if (shopReviews.Any())
        {
            var shop = await _context.Shops.FindAsync(shopId);
            if (shop != null)
            {
                shop.Rating = shopReviews.Average(r => r.Rating);
                shop.ReviewCount = shopReviews.Count;
                shop.UpdatedAt = DateTime.UtcNow;
                await _context.SaveChangesAsync();

                _logger.LogInformation(
                    "Updated shop {ShopId} rating to {Rating} ({ReviewCount} reviews)",
                    shopId, shop.Rating, shop.ReviewCount
                );
            }
        }
    }

    private async Task UpdateStaffRatingAsync(int staffId)
    {
        var staffReviews = await _context.Reviews
            .Where(r => r.StaffId == staffId)
            .ToListAsync();

        if (staffReviews.Any())
        {
            var staff = await _context.StaffProfiles.FindAsync(staffId);
            if (staff != null)
            {
                staff.Rating = staffReviews.Average(r => r.Rating);
                staff.ReviewCount = staffReviews.Count;
                staff.UpdatedAt = DateTime.UtcNow;
                await _context.SaveChangesAsync();

                _logger.LogInformation(
                    "Updated staff {StaffId} rating to {Rating} ({ReviewCount} reviews)",
                    staffId, staff.Rating, staff.ReviewCount
                );
            }
        }
    }
}
