using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using appcattoc.Data;
using appcattoc.Models.Entities;

namespace appcattoc.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ServicesController : ControllerBase
{
    private readonly BarberDbContext _context;

    public ServicesController(BarberDbContext context)
    {
        _context = context;
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 1: GET ALL SERVICES                                        ║
    // ║ GET /api/services                                              ║
    // ║ Authorization: Anonymous                                       ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Get all services
    /// </summary>
    [HttpGet]
    [AllowAnonymous] // Allow browsing without login
    public async Task<ActionResult<IEnumerable<Service>>> GetServices()
    {
        return await _context.Services.ToListAsync();
    }
}
