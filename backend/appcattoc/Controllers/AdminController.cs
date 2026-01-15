using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using appcattoc.DTOs.Admin;
using appcattoc.Services;
using appcattoc.Data;

namespace appcattoc.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin")]
public class AdminController : ControllerBase
{
    private readonly IAdminVoucherService _voucherService;
    private readonly IAdminUserService _userService;
    private readonly IAdminServiceService _serviceService;
    private readonly IAdminBarberService _barberService;
    private readonly IAdminShopService _shopService;
    private readonly IAdminStaffService _staffService;
    private readonly BarberDbContext _context;

    public AdminController(
        IAdminVoucherService voucherService,
        IAdminUserService userService,
        IAdminServiceService serviceService,
        IAdminBarberService barberService,
        IAdminShopService shopService,
        IAdminStaffService staffService,
        BarberDbContext context)
    {
        _voucherService = voucherService;
        _userService = userService;
        _serviceService = serviceService;
        _barberService = barberService;
        _shopService = shopService;
        _staffService = staffService;
        _context = context;
    }

    // ===== VOUCHER MANAGEMENT =====

    /// <summary>
    /// Create a new voucher
    /// </summary>
    [HttpPost("vouchers")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<VoucherResponse>> CreateVoucher([FromBody] CreateVoucherRequest request)
    {
        try
        {
            var voucher = await _voucherService.CreateVoucherAsync(request);
            return CreatedAtAction(nameof(GetVoucher), new { id = voucher.Id }, voucher);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Get voucher by ID
    /// </summary>
    [HttpGet("vouchers/{id}")]
    public async Task<ActionResult<VoucherResponse>> GetVoucher(int id)
    {
        try
        {
            var voucher = await _voucherService.GetVoucherByIdAsync(id);
            return Ok(voucher);
        }
        catch (Exception ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Get all vouchers
    /// </summary>
    [HttpGet("vouchers")]
    public async Task<ActionResult<List<VoucherResponse>>> GetAllVouchers()
    {
        var vouchers = await _voucherService.GetAllVouchersAsync();
        return Ok(vouchers);
    }

    /// <summary>
    /// Get only active vouchers
    /// </summary>
    [HttpGet("vouchers/active/list")]
    public async Task<ActionResult<List<VoucherResponse>>> GetActiveVouchers()
    {
        var vouchers = await _voucherService.GetActiveVouchersAsync();
        return Ok(vouchers);
    }

    /// <summary>
    /// Update voucher
    /// </summary>
    [HttpPut("vouchers/{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<VoucherResponse>> UpdateVoucher(int id, [FromBody] UpdateVoucherRequest request)
    {
        try
        {
            var voucher = await _voucherService.UpdateVoucherAsync(id, request);
            return Ok(voucher);
        }
        catch (Exception ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Delete voucher
    /// </summary>
    [HttpDelete("vouchers/{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteVoucher(int id)
    {
        try
        {
            await _voucherService.DeleteVoucherAsync(id);
            return NoContent();
        }
        catch (Exception ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    // ===== USER MANAGEMENT =====

    /// <summary>
    /// Get all users
    /// </summary>
    [HttpGet("users")]
    public async Task<ActionResult<List<UserManagementResponse>>> GetAllUsers()
    {
        var users = await _userService.GetAllUsersAsync();
        return Ok(users);
    }

    /// <summary>
    /// Get user by ID
    /// </summary>
    [HttpGet("users/{id}")]
    public async Task<ActionResult<UserManagementResponse>> GetUser(int id)
    {
        try
        {
            var user = await _userService.GetUserByIdAsync(id);
            return Ok(user);
        }
        catch (Exception ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Update user information
    /// </summary>
    [HttpPut("users/{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<UserManagementResponse>> UpdateUser(int id, [FromBody] UserManagementRequest request)
    {
        try
        {
            var user = await _userService.UpdateUserAsync(id, request);
            return Ok(user);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Delete user
    /// </summary>
    [HttpDelete("users/{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteUser(int id)
    {
        try
        {
            await _userService.DeleteUserAsync(id);
            return NoContent();
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Get user statistics
    /// </summary>
    [HttpGet("users/statistics/dashboard")]
    public async Task<ActionResult<UserStatisticsResponse>> GetUserStatistics()
    {
        var statistics = await _userService.GetUserStatisticsAsync();
        return Ok(statistics);
    }

    // ===== SERVICE MANAGEMENT =====

    /// <summary>
    /// Create a new service
    /// </summary>
    [HttpPost("services")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<ServiceManagementResponse>> CreateService([FromBody] CreateServiceRequest request)
    {
        try
        {
            var service = await _serviceService.CreateServiceAsync(request);
            return CreatedAtAction(nameof(GetService), new { id = service.Id }, service);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Get service by ID
    /// </summary>
    [HttpGet("services/{id}")]
    public async Task<ActionResult<ServiceManagementResponse>> GetService(int id)
    {
        try
        {
            var service = await _serviceService.GetServiceByIdAsync(id);
            return Ok(service);
        }
        catch (Exception ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Get all services
    /// </summary>
    [HttpGet("services")]
    public async Task<ActionResult<List<ServiceManagementResponse>>> GetAllServices()
    {
        var services = await _serviceService.GetAllServicesAsync();
        return Ok(services);
    }

    /// <summary>
    /// Get services by shop
    /// </summary>
    [HttpGet("services/shop/{shopId}")]
    public async Task<ActionResult<List<ServiceManagementResponse>>> GetServicesByShop(int shopId)
    {
        try
        {
            var services = await _serviceService.GetServicesByShopAsync(shopId);
            return Ok(services);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Update service
    /// </summary>
    [HttpPut("services/{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<ServiceManagementResponse>> UpdateService(int id, [FromBody] UpdateServiceRequest request)
    {
        try
        {
            var service = await _serviceService.UpdateServiceAsync(id, request);
            return Ok(service);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Delete service
    /// </summary>
    [HttpDelete("services/{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteService(int id)
    {
        try
        {
            await _serviceService.DeleteServiceAsync(id);
            return NoContent();
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    // ===== BARBER MANAGEMENT =====

    /// <summary>
    /// Create a new barber
    /// </summary>
    [HttpPost("barbers")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<BarberManagementResponse>> CreateBarber([FromBody] CreateBarberRequest request)
    {
        try
        {
            var barber = await _barberService.CreateBarberAsync(request);
            return CreatedAtAction(nameof(GetBarber), new { id = barber.Id }, barber);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Get barber by ID
    /// </summary>
    [HttpGet("barbers/{id}")]
    public async Task<ActionResult<BarberManagementResponse>> GetBarber(int id)
    {
        try
        {
            var barber = await _barberService.GetBarberByIdAsync(id);
            return Ok(barber);
        }
        catch (Exception ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Get all barbers
    /// </summary>
    [HttpGet("barbers")]
    public async Task<ActionResult<List<BarberManagementResponse>>> GetAllBarbers()
    {
        var barbers = await _barberService.GetAllBarbersAsync();
        return Ok(barbers);
    }

    /// <summary>
    /// Get barbers by shop
    /// </summary>
    [HttpGet("barbers/shop/{shopId}")]
    public async Task<ActionResult<List<BarberManagementResponse>>> GetBarbersByShop(int shopId)
    {
        try
        {
            var barbers = await _barberService.GetBarbersByShopAsync(shopId);
            return Ok(barbers);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Update barber
    /// </summary>
    [HttpPut("barbers/{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<BarberManagementResponse>> UpdateBarber(int id, [FromBody] UpdateBarberRequest request)
    {
        try
        {
            var barber = await _barberService.UpdateBarberAsync(id, request);
            return Ok(barber);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Delete barber
    /// </summary>
    [HttpDelete("barbers/{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteBarber(int id)
    {
        try
        {
            await _barberService.DeleteBarberAsync(id);
            return NoContent();
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    // ===== SHOP MANAGEMENT =====

    /// <summary>
    /// Create a new shop
    /// </summary>
    [HttpPost("shops")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<ShopManagementResponse>> CreateShop([FromBody] CreateShopRequest request)
    {
        try
        {
            var shop = await _shopService.CreateShopAsync(request);
            return CreatedAtAction(nameof(GetShop), new { id = shop.Id }, shop);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Get shop by ID
    /// </summary>
    [HttpGet("shops/{id}")]
    public async Task<ActionResult<ShopManagementResponse>> GetShop(int id)
    {
        try
        {
            var shop = await _shopService.GetShopByIdAsync(id);
            return Ok(shop);
        }
        catch (Exception ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Get all shops
    /// </summary>
    [HttpGet("shops")]
    public async Task<ActionResult<List<ShopManagementResponse>>> GetAllShops()
    {
        var shops = await _shopService.GetAllShopsAsync();
        return Ok(shops);
    }

    /// <summary>
    /// Get shops by manager
    /// </summary>
    [HttpGet("shops/manager/{managerId}")]
    public async Task<ActionResult<List<ShopManagementResponse>>> GetShopsByManager(int managerId)
    {
        try
        {
            var shops = await _shopService.GetShopsByManagerAsync(managerId);
            return Ok(shops);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Update shop
    /// </summary>
    [HttpPut("shops/{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<ShopManagementResponse>> UpdateShop(int id, [FromBody] UpdateShopRequest request)
    {
        try
        {
            var shop = await _shopService.UpdateShopAsync(id, request);
            return Ok(shop);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Delete shop
    /// </summary>
    [HttpDelete("shops/{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteShop(int id)
    {
        try
        {
            await _shopService.DeleteShopAsync(id);
            return NoContent();
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    // ===== STAFF MANAGEMENT =====

    /// <summary>
    /// Create a new staff member
    /// </summary>
    [HttpPost("staff")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<StaffManagementResponse>> CreateStaff([FromBody] CreateStaffRequest request)
    {
        try
        {
            var staff = await _staffService.CreateStaffAsync(request);
            return CreatedAtAction(nameof(GetStaff), new { id = staff.Id }, staff);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Get staff by ID
    /// </summary>
    [HttpGet("staff/{id}")]
    public async Task<ActionResult<StaffManagementResponse>> GetStaff(int id)
    {
        try
        {
            var staff = await _staffService.GetStaffByIdAsync(id);
            return Ok(staff);
        }
        catch (Exception ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Get all staff members
    /// </summary>
    [HttpGet("staff")]
    public async Task<ActionResult<List<StaffManagementResponse>>> GetAllStaff()
    {
        var staffs = await _staffService.GetAllStaffAsync();
        return Ok(staffs);
    }

    /// <summary>
    /// Get staff by shop
    /// </summary>
    [HttpGet("staff/shop/{shopId}")]
    public async Task<ActionResult<List<StaffManagementResponse>>> GetStaffByShop(int shopId)
    {
        try
        {
            var staffs = await _staffService.GetStaffByShopAsync(shopId);
            return Ok(staffs);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Update staff member
    /// </summary>
    [HttpPut("staff/{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<StaffManagementResponse>> UpdateStaff(int id, [FromBody] UpdateStaffRequest request)
    {
        try
        {
            var staff = await _staffService.UpdateStaffAsync(id, request);
            return Ok(staff);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Delete staff member
    /// </summary>
    [HttpDelete("staff/{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteStaff(int id)
    {
        try
        {
            await _staffService.DeleteStaffAsync(id);
            return NoContent();
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    // ===== DASHBOARD & STATISTICS =====

    /// <summary>
    /// Get admin dashboard with key statistics
    /// </summary>
    [HttpGet("dashboard")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<AdminDashboardResponse>> GetDashboard()
    {
        var totalUsers = _context.Users.Count();
        var totalShops = _context.Shops.Count();
        var totalServices = _context.Services.Count();
        var totalStaff = _context.StaffProfiles.Count();
        var activeVouchers = _context.Vouchers.Count(v => v.IsActive);
        var totalRevenue = _context.Invoices.Sum(i => i.TotalAmount);
        var totalAppointments = _context.Appointments.Count();
        var totalBarbers = _context.Barbers.Count();

        var dashboard = new AdminDashboardResponse
        {
            TotalUsers = totalUsers,
            TotalShops = totalShops,
            TotalServices = totalServices,
            TotalStaff = totalStaff,
            ActiveVouchers = activeVouchers,
            TotalRevenue = totalRevenue,
            TotalAppointments = totalAppointments,
            TotalBarbers = totalBarbers
        };

        return Ok(dashboard);
    }
}
