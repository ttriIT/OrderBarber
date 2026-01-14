using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace appcattoc.Data;

public class BarberDbContextFactory : IDesignTimeDbContextFactory<BarberDbContext>
{
    public BarberDbContext CreateDbContext(string[] args)
    {
        var optionsBuilder = new DbContextOptionsBuilder<BarberDbContext>();

        optionsBuilder.UseSqlServer(
            "Server=ADMIN\\SQLEXPRESS;Database=BarberBookingDB;Trusted_Connection=True;TrustServerCertificate=True"
        );

        return new BarberDbContext(optionsBuilder.Options);
    }
}
