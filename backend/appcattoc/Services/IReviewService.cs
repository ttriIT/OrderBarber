using appcattoc.DTOs.Reviews;

namespace appcattoc.Services;

public interface IReviewService
{
    Task<List<ReviewResponse>> GetShopReviewsAsync(int shopId);
    Task<ServiceResult<ReviewResponse>> CreateReviewAsync(int userId, CreateReviewRequest request);
}
