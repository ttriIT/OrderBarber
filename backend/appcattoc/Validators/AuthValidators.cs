using FluentValidation;
using appcattoc.DTOs.Auth;

namespace appcattoc.Validators;

public class RegisterRequestValidator : AbstractValidator<RegisterRequest>
{
    public RegisterRequestValidator()
    {
        RuleFor(x => x.Username)
            .NotEmpty()
            .WithMessage("Username is required")
            .MinimumLength(3)
            .WithMessage("Username must be at least 3 characters")
            .MaximumLength(50)
            .WithMessage("Username must not exceed 50 characters")
            .Matches(@"^[a-zA-Z0-9_]+$")
            .WithMessage("Username can only contain letters, numbers, and underscores");

        RuleFor(x => x.Password)
            .NotEmpty()
            .WithMessage("Password is required")
            .MinimumLength(6)
            .WithMessage("Password must be at least 6 characters")
            .MaximumLength(100)
            .WithMessage("Password must not exceed 100 characters");

        RuleFor(x => x.FullName)
            .NotEmpty()
            .WithMessage("Full name is required")
            .MaximumLength(100)
            .WithMessage("Full name must not exceed 100 characters");

        RuleFor(x => x.Phone)
            .NotEmpty()
            .WithMessage("Phone number is required")
            .Matches(@"^(0|\+84)[0-9]{9,10}$")
            .WithMessage("Invalid Vietnamese phone number format");

        RuleFor(x => x.Email)
            .EmailAddress()
            .When(x => !string.IsNullOrEmpty(x.Email))
            .WithMessage("Invalid email format");

        RuleFor(x => x.Role)
            .NotEmpty()
            .WithMessage("Role is required")
            .Must(role => new[] { "customer", "barber", "admin", "shopmanager" }.Contains(role.ToLower()))
            .WithMessage("Invalid role. Must be customer, barber, admin, or shopmanager");
    }
}

public class LoginRequestValidator : AbstractValidator<LoginRequest>
{
    public LoginRequestValidator()
    {
        RuleFor(x => x.Username)
            .NotEmpty()
            .WithMessage("Username is required");

        RuleFor(x => x.Password)
            .NotEmpty()
            .WithMessage("Password is required");
    }
}
