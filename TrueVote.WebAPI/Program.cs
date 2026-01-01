using Mapster;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using TrueVote.Model.Responses;
using TrueVote.Services;
using TrueVote.Services.Database;
using TrueVote.WebAPI.Filters;
using Microsoft.AspNetCore.Authentication;

var builder = WebApplication.CreateBuilder(args);

builder.WebHost.ConfigureKestrel(options =>
{
    options.ListenAnyIP(5080); // http bez https-a
});

// Registracija servisa
builder.Services.AddTransient<IPitanjeService, PitanjeService>();
builder.Services.AddTransient<IKorisnikService, KorisnikService>();
builder.Services.AddTransient<IDrzavaService, DrzavaService>();
builder.Services.AddTransient<IGradService, GradService>();
builder.Services.AddTransient<IStrankaService, StrankaService>();
builder.Services.AddTransient<IKategorijaService, KategorijaService>();
builder.Services.AddTransient<IUlogaService, UlogaService>();
builder.Services.AddTransient<ITipIzboraService, TipIzboraService>();
builder.Services.AddTransient<IKandidatService, KandidatService>();
builder.Services.AddTransient<IOpstinaService, OpstinaService>();
builder.Services.AddTransient<IGlasService, GlasService>();
builder.Services.AddTransient<IIzborService, IzborService>();
builder.Services.AddTransient<IReportService, ReportService>();
builder.Services.AddHttpContextAccessor();

// Registracija DbContext
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<BirackiSistemContext>(options =>
    options.UseSqlServer(connectionString));

// Mapster
builder.Services.AddMapster();

// Basic Authentication
builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

// Controllers i filteri
builder.Services.AddControllers(x =>
{
    x.Filters.Add<ExceptionFilter>();
});

// Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("BasicAuthentication", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "basic",
        In = ParameterLocation.Header,
        Description = "Basic Authorization header using the Basic scheme."
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "BasicAuthentication" }
            },
            new string[] { }
        }
    });
});

var app = builder.Build();

// Middleware pipeline
//if (app.Environment.IsDevelopment())
//{
    app.UseSwagger();
    app.UseSwaggerUI();
//}

//app.UseHttpsRedirection();

// **OBAVEZNO** - prvo authentication pa authorization
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
