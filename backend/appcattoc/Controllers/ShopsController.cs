using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using appcattoc.Data;
using appcattoc.Models.Entities;

namespace appcattoc.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ShopsController : ControllerBase
{
    private readonly BarberDbContext _context;

    public ShopsController(BarberDbContext context)
    {
        _context = context;
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 1: GET ALL SHOPS                                           ║
    // ║ GET /api/shops                                                 ║
    // ║ Authorization: Anonymous                                       ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Get all shops
    /// </summary>
    [HttpGet]
    [AllowAnonymous]
    public async Task<ActionResult<IEnumerable<object>>> GetShops()
    {
        var shops = await _context.Shops
            .Include(s => s.Manager)
            .Include(s => s.Services)
            .Include(s => s.StaffProfiles)
            .Select(s => new
            {
                Id = s.Id,
                Name = s.Name,
                Location = s.Location,
                Phone = s.Phone ?? "",
                Description = s.Description ?? "",
                ImageUrl = s.ImageUrl ?? "",
                Rating = s.Rating,
                ReviewCount = s.ReviewCount,
                OpenTime = s.OpenTime.ToString(@"hh\:mm"),
                CloseTime = s.CloseTime.ToString(@"hh\:mm"),
                ManagerId = s.ManagerId,
                ManagerName = s.Manager.FullName,
                ServiceCount = s.Services.Count,
                StaffCount = s.StaffProfiles.Count(sp => sp.IsActive),
                CreatedAt = s.CreatedAt
            })
            .ToListAsync();

        return Ok(shops);
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 2: GET SHOP DETAILS                                        ║
    // ║ GET /api/shops/{id}                                            ║
    // ║ Authorization: Anonymous                                       ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Get shop by ID with details
    /// </summary>
    [HttpGet("{id}")]
    [AllowAnonymous]
    public async Task<ActionResult<object>> GetShop(int id)
    {
        var shop = await _context.Shops
            .Include(s => s.Manager)
            .Include(s => s.Services)
            .Include(s => s.StaffProfiles)
                .ThenInclude(sp => sp.User)
            .Where(s => s.Id == id)
            .Select(s => new
            {
                Id = s.Id,
                Name = s.Name,
                Location = s.Location,
                Phone = s.Phone ?? "",
                Description = s.Description ?? "",
                ImageUrl = s.ImageUrl ?? "",
                Rating = s.Rating,
                ReviewCount = s.ReviewCount,
                OpenTime = s.OpenTime.ToString(@"hh\:mm"),
                CloseTime = s.CloseTime.ToString(@"hh\:mm"),
                ManagerId = s.ManagerId,
                ManagerName = s.Manager.FullName,
                Services = s.Services.Select(sv => new
                {
                    Id = sv.Id,
                    Name = sv.Name,
                    Description = sv.Description ?? "",
                    Category = sv.Category ?? "",
                    Price = sv.Price,
                    DurationMinutes = sv.DurationMinutes,
                    ImageUrl = sv.ImageUrl ?? ""
                }),
                Staff = s.StaffProfiles.Where(sp => sp.IsActive).Select(sp => new
                {
                    Id = sp.Id,
                    UserId = sp.UserId,
                    Name = sp.User.FullName,
                    Phone = sp.User.Phone,
                    Bio = sp.Bio ?? "Chuyên nghiệp",
                    Position = sp.Position ?? "Stylist",
                    SkillSet = sp.SkillSet ?? "",
                    ExperienceYears = sp.ExperienceYears,
                    Rating = sp.Rating,
                    ReviewCount = sp.ReviewCount,
                    AvatarUrl = sp.User.AvatarUrl
                }),
                CreatedAt = s.CreatedAt
            })
            .FirstOrDefaultAsync();

        if (shop == null)
        {
            return NotFound(new { message = "Shop not found" });
        }

        return Ok(shop);
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 3: GET SHOP SERVICES                                       ║
    // ║ GET /api/shops/{id}/services                                   ║
    // ║ Authorization: Anonymous                                       ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Get services for a shop
    /// </summary>
    [HttpGet("{id}/services")]
    [AllowAnonymous]
    public async Task<ActionResult<IEnumerable<Service>>> GetShopServices(int id)
    {
        var services = await _context.Services
            .Where(s => s.ShopId == id)
            .ToListAsync();

        return Ok(services);
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 4: GET SHOP STAFF                                          ║
    // ║ GET /api/shops/{id}/staff                                      ║
    // ║ Authorization: Anonymous                                       ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Get staff for a shop
    /// </summary>
    [HttpGet("{id}/staff")]
    [AllowAnonymous]
    public async Task<ActionResult<IEnumerable<object>>> GetShopStaff(int id)
    {
        var staff = await _context.StaffProfiles
            .Include(sp => sp.User)
            .Where(sp => sp.ShopId == id && sp.IsActive)
            .Select(sp => new
            {
                Id = sp.Id,
                UserId = sp.UserId,
                Name = sp.User.FullName,
                Phone = sp.User.Phone,
                Bio = sp.Bio ?? "Chuyên nghiệp",
                Position = sp.Position ?? "Stylist",
                SkillSet = sp.SkillSet ?? "",
                ExperienceYears = sp.ExperienceYears,
                Rating = sp.Rating,
                ReviewCount = sp.ReviewCount,
                AvatarUrl = sp.User.AvatarUrl
            })
            .ToListAsync();

        return Ok(staff);
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 5: CREATE SHOP                                             ║
    // ║ POST /api/shops                                                ║
    // ║ Authorization: Required (Admin, ShopManager)                   ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Create a new shop (Admin/Manager only)
    /// </summary>
    [HttpPost]
    [Authorize(Roles = "Admin,ShopManager")]
    public async Task<ActionResult<Shop>> CreateShop([FromBody] Shop shop)
    {
        shop.CreatedAt = DateTime.UtcNow;
        _context.Shops.Add(shop);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetShop), new { id = shop.Id }, shop);
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 6: UPDATE SHOP                                             ║
    // ║ PUT /api/shops/{id}                                            ║
    // ║ Authorization: Required (Admin, ShopManager)                   ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Update shop (Admin/Manager only)
    /// </summary>
    [HttpPut("{id}")]
    [Authorize(Roles = "Admin,ShopManager")]
    public async Task<ActionResult> UpdateShop(int id, [FromBody] Shop shop)
    {
        if (id != shop.Id)
        {
            return BadRequest(new { message = "ID mismatch" });
        }

        // 🔒 SECURITY FIX: Load existing shop to prevent data corruption
        var existingShop = await _context.Shops.FindAsync(id);
        if (existingShop == null)
        {
            return NotFound(new { message = "Shop not found" });
        }

        // Only update allowed fields
        existingShop.Name = shop.Name;
        existingShop.Location = shop.Location;
        existingShop.Phone = shop.Phone;
        existingShop.Description = shop.Description;
        existingShop.ImageUrl = shop.ImageUrl;
        existingShop.OpenTime = shop.OpenTime;
        existingShop.CloseTime = shop.CloseTime;
        existingShop.UpdatedAt = DateTime.UtcNow;
        // Note: ManagerId should be updated via separate endpoint for security

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!await _context.Shops.AnyAsync(e => e.Id == id))
            {
                return NotFound();
            }
            throw;
        }

        return NoContent();
    }
}
