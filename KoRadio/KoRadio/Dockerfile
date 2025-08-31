# -----------------
# Build stage
# -----------------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj files first for restore
COPY KoRadio/KoRadio/KoRadio.API.csproj KoRadio/KoRadio/
COPY KoRadio/KoRadio.Model/KoRadio.Model.csproj KoRadio/KoRadio.Model/
COPY KoRadio/KoRadio.Services/KoRadio.Services.csproj KoRadio/KoRadio.Services/
COPY KoRadio/Subscriber/Subscriber.csproj KoRadio/Subscriber/

# Restore dependencies (API + all referenced projects)
RUN dotnet restore KoRadio/KoRadio/KoRadio.API.csproj

# Copy the rest of the source code
COPY KoRadio/KoRadio/ KoRadio/KoRadio/
COPY KoRadio/KoRadio.Model/ KoRadio/KoRadio.Model/
COPY KoRadio/KoRadio.Services/ KoRadio/KoRadio.Services/
COPY KoRadio/Subscriber/ KoRadio/Subscriber/

# Build & publish
WORKDIR /src/KoRadio/KoRadio
RUN dotnet publish -c Release -o /app/publish

# -----------------
# Runtime stage
# -----------------
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "KoRadio.API.dll"]
