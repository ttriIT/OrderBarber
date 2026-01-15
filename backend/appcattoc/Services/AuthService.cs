using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using appcattoc.Models.Entities;
using appcattoc.Models.Enums;
using appcattoc.DTOs.Auth;
using appcattoc.Data;
using Microsoft.EntityFrameworkCore;
using BCrypt.Net;

namespace appcattoc.Services;

public interface IAuthService
{
    Task<LoginResponse?> LoginAsync(LoginRequest request);
    Task<LoginResponse?> RegisterAsync(RegisterRequest request);
    Task<LoginResponse?> GetUserByIdAsync(int userId);
    Task<LoginResponse?> RefreshTokenAsync(string refreshToken);
}

public class AuthService : IAuthService
{
    private readonly BarberDbContext _context;
    private readonly IConfiguration _configuration;
    private readonly ILogger<AuthService> _logger;

    public AuthService(BarberDbContext context, IConfiguration configuration, ILogger<AuthService> logger)
    {
        _context = context;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<LoginResponse?> LoginAsync(LoginRequest request)
    {
        try 
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == request.Username);
            
            if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            {
                return null;
            }

            var token = GenerateJwtToken(user);
            var refreshToken = await GenerateRefreshTokenAsync(user.Id);

            return new LoginResponse
            {
                Token = token,
                RefreshToken = refreshToken,
                UserId = user.Id,
                Username = user.Username,
                Role = MapRoleToFrontend(user.Role), // Map to frontend role
                FullName = user.FullName,
                Email = user.Email,
                Phone = user.Phone,
                AvatarUrl = user.AvatarUrl,
                CreatedAt = user.CreatedAt
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Login failed for username: {Username}", request.Username);
            throw; // Re-throw so controller can handle 500 or similar
        }
    }

    public async Task<LoginResponse?> RegisterAsync(RegisterRequest request)
    {
        if (await _context.Users.AnyAsync(u => u.Username == request.Username))
        {
            return null;
        }

        // Map frontend role to backend role
        // Frontend uses: customer, barber, admin
        // Backend uses: Customer, Staff, ShopManager, Admin
        UserRole role;
        var roleInput = request.Role.ToLower();
        
        if (roleInput == "barber")
        {
            role = UserRole.Staff; // Map barber -> Staff
        }
        else if (!Enum.TryParse<UserRole>(request.Role, true, out role))
        {
            role = UserRole.Customer; // Default to Customer
        }

        var user = new User
        {
            Username = request.Username,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            FullName = request.FullName,
            Phone = request.Phone,
            Email = request.Email,
            Role = role,
            AvatarUrl = request.AvatarUrl,
            CreatedAt = DateTime.UtcNow
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        var token = GenerateJwtToken(user);
        var refreshToken = await GenerateRefreshTokenAsync(user.Id);

        return new LoginResponse
        {
            Token = token,
            RefreshToken = refreshToken,
            UserId = user.Id,
            Username = user.Username,
            Role = MapRoleToFrontend(user.Role), // Map to frontend role
            FullName = user.FullName,
            Email = user.Email,
            Phone = user.Phone,
            AvatarUrl = user.AvatarUrl,
            CreatedAt = user.CreatedAt
        };
    }

    private string GenerateJwtToken(User user)
    {
        var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(
            _configuration["Jwt:Key"] ?? "YourSecretKeyHere_MinimumLength32Characters!"));
        var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Name, user.Username),
            new Claim(ClaimTypes.Role, user.Role.ToString()),
            new Claim("FullName", user.FullName)
        };

        var token = new JwtSecurityToken(
            issuer: _configuration["Jwt:Issuer"] ?? "BarberBookingSystem",
            audience: _configuration["Jwt:Audience"] ?? "BarberBookingSystem",
            claims: claims,
            expires: DateTime.Now.AddDays(7),
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public async Task<LoginResponse?> GetUserByIdAsync(int userId)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null)
        {
            return null;
        }

        return new LoginResponse
        {
            Token = string.Empty, // No new token needed
            RefreshToken = string.Empty,
            UserId = user.Id,
            Username = user.Username,
            Role = MapRoleToFrontend(user.Role), // Map to frontend role
            FullName = user.FullName,
            Email = user.Email,
            Phone = user.Phone,
            AvatarUrl = user.AvatarUrl,
            CreatedAt = user.CreatedAt
        };
    }

    public async Task<LoginResponse?> RefreshTokenAsync(string refreshToken)
    {
        var storedToken = await _context.RefreshTokens
            .Include(rt => rt.User)
            .FirstOrDefaultAsync(rt => rt.Token == refreshToken);

        if (storedToken == null || !storedToken.IsActive)
        {
            return null;
        }

        // Revoke old token
        storedToken.IsRevoked = true;
        storedToken.RevokedAt = DateTime.UtcNow;

        // Generate new tokens
        var newAccessToken = GenerateJwtToken(storedToken.User);
        var newRefreshToken = await GenerateRefreshTokenAsync(storedToken.UserId);

        // Mark replacement
        storedToken.ReplacedByToken = newRefreshToken;
        
        await _context.SaveChangesAsync();

        return new LoginResponse
        {
            Token = newAccessToken,
            RefreshToken = newRefreshToken,
            UserId = storedToken.User.Id,
            Username = storedToken.User.Username,
            Role = MapRoleToFrontend(storedToken.User.Role),
            FullName = storedToken.User.FullName,
            Email = storedToken.User.Email,
            Phone = storedToken.User.Phone,
            AvatarUrl = storedToken.User.AvatarUrl,
            CreatedAt = storedToken.User.CreatedAt
        };
    }

    private async Task<string> GenerateRefreshTokenAsync(int userId)
    {
        var tokenString = Convert.ToBase64String(Guid.NewGuid().ToByteArray()) + 
                         Convert.ToBase64String(Guid.NewGuid().ToByteArray());

        var refreshToken = new RefreshToken
        {
            UserId = userId,
            Token = tokenString,
            ExpiresAt = DateTime.UtcNow.AddDays(30), // 30 days
            CreatedAt = DateTime.UtcNow
        };

        _context.RefreshTokens.Add(refreshToken);
        await _context.SaveChangesAsync();

        return tokenString;
    }

    /// <summary>
    /// Map backend roles to frontend roles
    /// Backend: Admin, ShopManager, Staff, Customer
    /// Frontend: admin, barber, customer
    /// </summary>
    private string MapRoleToFrontend(UserRole role)
    {
        return role switch
        {
            UserRole.Admin => "admin",
            UserRole.ShopManager => "admin", // ShopManager maps to admin in FE
            UserRole.Staff => "barber", // Staff maps to barber in FE
            UserRole.Customer => "customer",
            _ => "customer"
        };
    }
}
