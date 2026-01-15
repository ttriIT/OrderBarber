namespace appcattoc.DTOs.Admin;

// ========== VOUCHER DTOs ==========

public class CreateVoucherRequest
{
    public string Code { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal DiscountAmount { get; set; }
    public int DiscountType { get; set; } = 0; // 0 = Fixed, 1 = Percentage
    public decimal? MaxDiscountAmount { get; set; }
    public decimal MinimumAmount { get; set; } = 0;
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public int MaxUsage { get; set; }
    public int MaxUsagePerUser { get; set; } = 1;
    public int? ShopId { get; set; }
    public string? Notes { get; set; }
}

public class UpdateVoucherRequest
{
    public string? Code { get; set; }
    public string? Description { get; set; }
    public decimal? DiscountAmount { get; set; }
    public int? DiscountType { get; set; }
    public decimal? MaxDiscountAmount { get; set; }
    public decimal? MinimumAmount { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public int? MaxUsage { get; set; }
    public int? MaxUsagePerUser { get; set; }
    public bool? IsActive { get; set; }
    public string? Notes { get; set; }
}

public class VoucherResponse
{
    public int Id { get; set; }
    public string Code { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal DiscountAmount { get; set; }
    public int DiscountType { get; set; }
    public decimal? MaxDiscountAmount { get; set; }
    public decimal MinimumAmount { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public int MaxUsage { get; set; }
    public int CurrentUsage { get; set; }
    public int MaxUsagePerUser { get; set; }
    public bool IsActive { get; set; }
    public int? ShopId { get; set; }
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

// ========== USER MANAGEMENT DTOs ==========

public class UserManagementRequest
{
    public string? FullName { get; set; }
    public string? Email { get; set; }
    public string? Phone { get; set; }
    public string? AvatarUrl { get; set; }
    public int? Role { get; set; }
}

public class UserManagementResponse
{
    public int Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string? AvatarUrl { get; set; }
    public int Role { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

// ========== SERVICE MANAGEMENT DTOs ==========

public class CreateServiceRequest
{
    public int ShopId { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int DurationMinutes { get; set; }
    public string? Description { get; set; }
    public string? Category { get; set; }
    public string? ImageUrl { get; set; }
}

public class UpdateServiceRequest
{
    public string? Name { get; set; }
    public decimal? Price { get; set; }
    public int? DurationMinutes { get; set; }
    public string? Description { get; set; }
    public string? Category { get; set; }
    public string? ImageUrl { get; set; }
}

public class ServiceManagementResponse
{
    public int Id { get; set; }
    public int ShopId { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int DurationMinutes { get; set; }
    public string? Description { get; set; }
    public string? Category { get; set; }
    public string? ImageUrl { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

// ========== BARBER MANAGEMENT DTOs ==========

public class CreateBarberRequest
{
    public int UserId { get; set; }
    public int ShopId { get; set; }
    public string? Specialization { get; set; }
    public double Rating { get; set; } = 0.0;
    public int ExperienceYears { get; set; } = 0;
}

public class UpdateBarberRequest
{
    public int? ShopId { get; set; }
    public string? Specialization { get; set; }
    public double? Rating { get; set; }
    public int? ExperienceYears { get; set; }
}

public class BarberManagementResponse
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string BarberName { get; set; } = string.Empty;
    public int ShopId { get; set; }
    public string ShopName { get; set; } = string.Empty;
    public string? Specialization { get; set; }
    public double Rating { get; set; }
    public int ExperienceYears { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

// ========== SHOP MANAGEMENT DTOs ==========

public class CreateShopRequest
{
    public int ManagerId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string? Description { get; set; }
    public string? ImageUrl { get; set; }
    public TimeSpan OpenTime { get; set; }
    public TimeSpan CloseTime { get; set; }
}

public class UpdateShopRequest
{
    public string? Name { get; set; }
    public string? Location { get; set; }
    public string? Phone { get; set; }
    public string? Description { get; set; }
    public string? ImageUrl { get; set; }
    public TimeSpan? OpenTime { get; set; }
    public TimeSpan? CloseTime { get; set; }
}

public class ShopManagementResponse
{
    public int Id { get; set; }
    public int ManagerId { get; set; }
    public string ManagerName { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string? Description { get; set; }
    public string? ImageUrl { get; set; }
    public double Rating { get; set; }
    public int ReviewCount { get; set; }
    public TimeSpan OpenTime { get; set; }
    public TimeSpan CloseTime { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

// ========== STAFF MANAGEMENT DTOs ==========

public class CreateStaffRequest
{
    public int UserId { get; set; }
    public int ShopId { get; set; }
    public string? Position { get; set; }
    public decimal? Salary { get; set; }
}

public class UpdateStaffRequest
{
    public int? ShopId { get; set; }
    public string? Position { get; set; }
    public decimal? Salary { get; set; }
}

public class StaffManagementResponse
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string StaffName { get; set; } = string.Empty;
    public int ShopId { get; set; }
    public string ShopName { get; set; } = string.Empty;
    public string? Position { get; set; }
    public decimal? Salary { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

// ========== ADMIN STATISTICS DTOs ==========

public class AdminDashboardResponse
{
    public int TotalUsers { get; set; }
    public int TotalShops { get; set; }
    public int TotalServices { get; set; }
    public int TotalStaff { get; set; }
    public int ActiveVouchers { get; set; }
    public decimal TotalRevenue { get; set; }
    public int TotalAppointments { get; set; }
    public int TotalBarbers { get; set; }
}

public class UserStatisticsResponse
{
    public int TotalUsers { get; set; }
    public int ActiveUsers { get; set; }
    public int CustomersCount { get; set; }
    public int BarbersCount { get; set; }
    public int ManagersCount { get; set; }
    public int AdminsCount { get; set; }
}
