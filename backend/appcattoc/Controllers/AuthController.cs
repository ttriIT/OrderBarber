using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using appcattoc.DTOs.Auth;
using appcattoc.Services;

namespace appcattoc.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }
    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 1: LOGIN                                                   ║
    // ║ POST /api/auth/login                                           ║
    // ║ Authorization: Anonymous                                       ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Login with username and password
    /// </summary>
    [HttpPost("login")]
    public async Task<ActionResult<LoginResponse>> Login([FromBody] LoginRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        try
        {
            var response = await _authService.LoginAsync(request);
            if (response == null)
            {
                return Unauthorized(new { message = "Invalid username or password" });
            }
            return Ok(response);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "An error occurred during login", error = ex.Message });
        }
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 2: REGISTER                                                ║
    // ║ POST /api/auth/register                                        ║
    // ║ Authorization: Anonymous                                       ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Register a new user
    /// </summary>
    [HttpPost("register")]
    public async Task<ActionResult<LoginResponse>> Register([FromBody] RegisterRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        try
        {
            var response = await _authService.RegisterAsync(request);
            if (response == null)
            {
                return BadRequest(new { message = "Username already exists" });
            }
            return Ok(response);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "An error occurred during registration", error = ex.Message });
        }
    }
    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 3: GET CURRENT USER                                        ║
    // ║ GET /api/auth/me                                               ║
    // ║ Authorization: Required                                        ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Get current authenticated user info
    /// </summary>
    [HttpGet("me")]
    [Authorize]
    public async Task<ActionResult<LoginResponse>> GetCurrentUser()
    {
        var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        if (userId == null)
        {
            return Unauthorized();
        }

        try
        {
            var response = await _authService.GetUserByIdAsync(int.Parse(userId));
            if (response == null)
            {
                return NotFound(new { message = "User not found" });
            }

            return Ok(response);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "An error occurred while fetching user info", error = ex.Message });
        }
    }

    // ╔════════════════════════════════════════════════════════════════╗
    // ║ API 4: REFRESH TOKEN                                           ║
    // ║ POST /api/auth/refresh                                         ║
    // ║ Authorization: Anonymous                                       ║
    // ╚════════════════════════════════════════════════════════════════╝
    /// <summary>
    /// Refresh access token using refresh token
    /// </summary>
    [HttpPost("refresh")]
    public async Task<ActionResult<LoginResponse>> RefreshToken([FromBody] RefreshTokenRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        try
        {
            var response = await _authService.RefreshTokenAsync(request.RefreshToken);
            if (response == null)
            {
                return Unauthorized(new { message = "Invalid or expired refresh token" });
            }
            return Ok(response);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "An error occurred during token refresh", error = ex.Message });
        }
    }
}
