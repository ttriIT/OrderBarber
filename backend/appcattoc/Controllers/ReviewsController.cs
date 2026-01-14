using appcattoc.DTOs.Reviews;
using appcattoc.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace appcattoc.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ReviewsController : ControllerBase
{
    private readonly IReviewService _reviewService;

    public ReviewsController(IReviewService reviewService)
    {
        _reviewService = reviewService;
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 1: GET SHOP REVIEWS                                        ║
    // ║ GET /api/reviews/shop/{shopId}                                 ║
    // ║ Authorization: Anonymous                                       ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Get reviews for a shop
    /// </summary>
    [HttpGet("shop/{shopId}")]
    [AllowAnonymous]
    public async Task<ActionResult<List<ReviewResponse>>> GetShopReviews(int shopId)
    {
        var reviews = await _reviewService.GetShopReviewsAsync(shopId);
        return Ok(reviews);
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 2: CREATE REVIEW                                           ║
    // ║ POST /api/reviews                                              ║
    // ║ Authorization: Required                                        ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Create a review
    /// </summary>
    [HttpPost]
    [Authorize]
    public async Task<ActionResult<ReviewResponse>> CreateReview([FromBody] CreateReviewRequest request)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdStr == null) return Unauthorized();
        
        var userId = int.Parse(userIdStr);
        var result = await _reviewService.CreateReviewAsync(userId, request);
        
        if (!result.Success)
        {
            return BadRequest(new { message = result.Message });
        }
        
        return Ok(result.Data);
    }
}
