using FluentValidation;
using appcattoc.DTOs.Appointments;

namespace appcattoc.Validators;

public class CreateBookingRequestValidator : AbstractValidator<CreateBookingRequest>
{
    public CreateBookingRequestValidator()
    {
        RuleFor(x => x.BarberId)
            .GreaterThan(0)
            .WithMessage("Barber ID must be greater than 0");

        RuleFor(x => x.ShopId)
            .GreaterThan(0)
            .WithMessage("Shop ID must be greater than 0");

        RuleFor(x => x.CustomerName)
            .NotEmpty()
            .WithMessage("Customer name is required")
            .MaximumLength(100)
            .WithMessage("Customer name must not exceed 100 characters");

        RuleFor(x => x.CustomerPhone)
            .NotEmpty()
            .WithMessage("Customer phone is required")
            .Matches(@"^(0|\+84)[0-9]{9,10}$")
            .WithMessage("Invalid Vietnamese phone number format");

        RuleFor(x => x.BookingDate)
            .GreaterThanOrEqualTo(DateTime.Today)
            .WithMessage("Booking date must be today or in the future");

        RuleFor(x => x.StartTime)
            .NotEmpty()
            .WithMessage("Start time is required")
            .Matches(@"^([0-1][0-9]|2[0-3]):[0-5][0-9]$")
            .WithMessage("Start time must be in HH:mm format");

        RuleFor(x => x.EndTime)
            .NotEmpty()
            .WithMessage("End time is required")
            .Matches(@"^([0-1][0-9]|2[0-3]):[0-5][0-9]$")
            .WithMessage("End time must be in HH:mm format");

        RuleFor(x => x.Note)
            .MaximumLength(500)
            .WithMessage("Note must not exceed 500 characters");

        RuleFor(x => x.ServiceIds)
            .NotEmpty()
            .WithMessage("At least one service must be selected")
            .Must(ids => ids.All(id => id > 0))
            .WithMessage("All service IDs must be greater than 0");
    }
}
